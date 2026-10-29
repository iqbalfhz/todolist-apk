import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todolist/core/api/api_error.dart';
import 'package:todolist/core/database/app_database.dart';
import 'package:todolist/core/database/entity_type.dart';
import 'package:todolist/core/database/local_store.dart';
import 'package:todolist/core/database/mappers.dart';
import 'package:todolist/core/notifications/push_service.dart';
import 'package:todolist/core/queue/outbox.dart';
import 'package:todolist/core/sync/sync_engine.dart';
import 'package:todolist/features/comments/domain/comment.dart';
import 'package:todolist/features/comments/domain/conversation.dart';
import 'package:todolist/features/tasks/domain/task.dart';

import 'helpers/fake_api.dart';
import 'helpers/fixtures.dart';

const String _otherReaction = '01m4dt3f80g7mnp2xs6ty8vk2e';
const String _otherComment = '01m4dt2k70f3qzr8vw5hx9cy5c';

/// Komentar dan reaksi (v1.x): perhitungan, antrean, sync, dan push.
void main() {
  Map<String, dynamic> payload(OutboxRow op) => jsonDecode(op.payload!) as Map<String, dynamic>;

  Future<Harness> seeded() async {
    final h = Harness();
    addTearDown(h.dispose);
    await h.seed(withTask: true);
    return h;
  }

  group('percakapan', () {
    test('komentar urut waktu; reaksi terbaru tiap orang, dikelompokkan per emoji', () {
      final conversations = buildConversations(
        comments: [
          Comment.fromJson(commentJson(id: _otherComment, body: 'kedua', createdAt: t1)),
          Comment.fromJson(commentJson(body: 'pertama')),
          Comment.fromJson(commentJson(id: '01m4dt2k70f3qzr8vw5hx9cy6d', body: 'terhapus', deletedAt: t2)),
        ],
        reactions: [
          Reaction.fromJson(reactionJson(emoji: '😂')),
          // Reaksi baru pasangan menggantikan yang lama.
          Reaction.fromJson(reactionJson(id: _otherReaction, emoji: '❤️', createdAt: t1)),
          Reaction.fromJson(reactionJson(id: '01m4dt3f80g7mnp2xs6ty8vk3f', userId: null, emoji: '❤️', createdAt: t2)),
        ],
        meId: meId,
      );

      final conversation = conversations[taskId]!;
      expect([for (final comment in conversation.comments) comment.body], ['pertama', 'kedua']);
      expect([for (final group in conversation.reactions) group.emoji], ['❤️']);
      expect(conversation.reactions.single.userIds, [partnerId, meId]);
      expect(conversation.mine?.id, '01m4dt3f80g7mnp2xs6ty8vk3f');
      expect(conversation.reactionCount, 2);
      expect(conversationOf(conversations, memoryId).isEmpty, isTrue);
    });

    test('komentar yang updated_at-nya lebih baru dari created_at ditandai diedit', () {
      expect(Comment.fromJson(commentJson()).isEdited, isFalse);
      expect(Comment.fromJson(commentJson(updatedAt: t1)).isEdited, isTrue);
    });
  });

  group('antrean', () {
    test('tulis, ubah, dan hapus komentar dengan Urungkan', () async {
      final h = await seeded();

      final comment = await h.account.comments.addComment(
        subject: const Subject(SubjectType.task, taskId),
        spaceId: sharedSpaceId,
        body: '  Beli yang 19 liter, ya  ',
      );
      final put = (await h.ops()).single;
      expect('${put.method} ${put.entityType}', 'PUT comment');
      expect(payload(put), {'subject_type': 'task', 'subject_id': taskId, 'body': 'Beli yang 19 liter, ya'});
      expect((await h.local(EntityType.comment, comment.id))!['user_id'], meId);

      await h.account.outbox.flush();
      expect(h.api.row('comments', comment.id)!['body'], 'Beli yang 19 liter, ya');

      h.clock.advance(const Duration(minutes: 1));
      await h.account.comments.editComment(comment.id, 'Yang 19 liter dua galon');
      expect(payload((await h.ops()).single), {'body': 'Yang 19 liter dua galon'});
      expect(Comment.fromJson((await h.local(EntityType.comment, comment.id))!).isEdited, isTrue);
      await h.account.outbox.flush();

      final opId = await h.account.comments.deleteComment(comment.id);
      expect((await h.local(EntityType.comment, comment.id))!['deleted_at'], isNotNull);
      expect(await h.account.comments.undo(opId!), isTrue);
      expect((await h.local(EntityType.comment, comment.id))!['deleted_at'], isNull);
      expect(await h.ops(), isEmpty);
    });

    test('komentar kosong atau lebih dari 1.000 karakter ditolak di HP', () async {
      final h = await seeded();
      const subject = Subject(SubjectType.task, taskId);

      expect(
        () => h.account.comments.addComment(subject: subject, spaceId: sharedSpaceId, body: '   '),
        throwsArgumentError,
      );
      expect(
        () => h.account.comments.addComment(subject: subject, spaceId: sharedSpaceId, body: 'a' * 1001),
        throwsArgumentError,
      );
      await h.account.comments.addComment(subject: subject, spaceId: sharedSpaceId, body: '😀' * 1000);
      expect(await h.ops(), hasLength(1), reason: 'panjang dihitung per code point');
    });

    test('ganti reaksi yang belum terkirim: yang lama batal tanpa request', () async {
      final h = await seeded();
      const subject = Subject(SubjectType.task, taskId);

      await h.account.comments.react(subject: subject, spaceId: sharedSpaceId, emoji: '😂');
      await h.account.comments.react(subject: subject, spaceId: sharedSpaceId, emoji: '❤️');

      final ops = await h.ops();
      expect([for (final op in ops) '${op.method} ${op.entityType} ${payload(op)['emoji']}'], ['PUT reaction ❤️']);
      final mine = await h.account.store.reactionsBy(meId, taskId);
      expect([for (final reaction in mine) reaction.emoji], ['❤️']);

      // Emoji yang sama tidak membuat reaksi baru.
      await h.account.comments.react(subject: subject, spaceId: sharedSpaceId, emoji: '❤️');
      expect(await h.ops(), hasLength(1));
    });

    test('ganti reaksi yang sudah terkirim: hanya PUT baru; yang lama cukup ditandai terhapus', () async {
      final h = await seeded();
      const subject = Subject(SubjectType.task, taskId);

      await h.account.comments.react(subject: subject, spaceId: sharedSpaceId, emoji: '😂');
      await h.account.outbox.flush();
      final old = (await h.account.store.reactionsBy(meId, taskId)).single;

      await h.account.comments.react(subject: subject, spaceId: sharedSpaceId, emoji: '❤️');
      final ops = await h.ops();
      expect([for (final op in ops) '${op.method} ${op.entityType}'], ['PUT reaction']);
      expect((await h.local(EntityType.reaction, old.id))!['deleted_at'], isNotNull);
    });

    test('cabut reaksi: DELETE kalau sudah terkirim, batal saja kalau belum', () async {
      final h = await seeded();
      const subject = Subject(SubjectType.task, taskId);

      await h.account.comments.react(subject: subject, spaceId: sharedSpaceId, emoji: '😂');
      await h.account.comments.removeReaction(taskId);
      expect(await h.ops(), isEmpty);
      expect(await h.account.store.reactionsBy(meId, taskId), isEmpty);

      await h.account.comments.react(subject: subject, spaceId: sharedSpaceId, emoji: '😂');
      await h.account.outbox.flush();
      final sent = (await h.account.store.reactionsBy(meId, taskId)).single;
      await h.account.comments.removeReaction(taskId);
      expect(
        [for (final op in await h.ops()) '${op.method} ${op.entityType} ${op.entityId}'],
        ['DELETE reaction ${sent.id}'],
      );
    });

    test('subjek sudah dihapus: komentar dibuang dan diberi tahu, reaksi dibuang diam-diam', () async {
      final h = await seeded();
      const subject = Subject(SubjectType.task, taskId);
      final events = <OutboxEvent>[];
      final subscription = h.account.outbox.events.listen(events.add);
      addTearDown(subscription.cancel);

      h.api.failNext(apiError(409, ApiErrorCode.parentDeleted, message: 'Tugas ini sudah dihapus.'));
      final comment = await h.account.comments.addComment(subject: subject, spaceId: sharedSpaceId, body: 'Halo');
      await h.account.outbox.flush();
      expect(await h.local(EntityType.comment, comment.id), isNull);

      h.api.failNext(apiError(409, ApiErrorCode.parentDeleted, message: 'Tugas ini sudah dihapus.'));
      await h.account.comments.react(subject: subject, spaceId: sharedSpaceId, emoji: '❤️');
      await h.account.outbox.flush();
      expect(await h.account.store.reactionsBy(meId, taskId), isEmpty);

      await Future<void>.delayed(Duration.zero);
      expect([for (final event in events.whereType<OutboxRejected>()) event.message], ['Tugas ini sudah dihapus.']);
    });

    test('mengubah komentar orang lain ditolak 403: dibuang dan isi server dipakai lagi', () async {
      final h = await seeded();
      await h.account.store.write(EntityType.comment, commentJson(userId: meId), serverUpdatedAt: t0);

      await h.account.comments.editComment(commentId, 'Diubah di HP');
      h.api.failNext(apiError(403, ApiErrorCode.forbidden, message: 'Hanya penulis.', current: commentJson()));
      await h.account.outbox.flush();

      expect(await h.ops(), isEmpty);
      expect((await h.local(EntityType.comment, commentId))!['body'], 'Jangan lupa yang isi ulang, ya.');
    });
  });

  group('sync', () {
    test('koleksi baru: sync penuh sekali, lalu komentar dan reaksi tersimpan', () async {
      final h = Harness();
      addTearDown(h.dispose);
      await h.account.store.setMeta(MetaKeys.syncSince, 'T-lama');
      await h.account.store.setMeta(MetaKeys.syncCollections, '6');
      h.api.syncPages.add(
        h.api.syncPage(serverTime: 'T-1', tasks: [taskJson()], comments: [commentJson()], reactions: [reactionJson()]),
      );

      expect(SyncEngine.collectionsVersion, 7);
      await h.account.sync.sync();

      expect(
        [
          for (final request in h.api.requests)
            if (request.path == '/sync') request.query,
        ],
        [null],
      );
      expect((await h.local(EntityType.comment, commentId))!['body'], 'Jangan lupa yang isi ulang, ya.');
      expect((await h.local(EntityType.reaction, reactionId))!['emoji'], '❤️');
      expect(await h.account.store.meta(MetaKeys.syncCollections), '7');
    });

    test('subjek tiba terhapus: komentar dan reaksinya ikut terhapus, kecuali yang masih di antrean', () async {
      final h = await seeded();
      await h.account.store.write(EntityType.comment, commentJson(), serverUpdatedAt: t0);
      await h.account.store.write(EntityType.reaction, reactionJson(), serverUpdatedAt: t0);
      final mine = await h.account.comments.addComment(
        subject: const Subject(SubjectType.task, taskId),
        spaceId: sharedSpaceId,
        body: 'Belum terkirim',
      );

      // Antrean ditahan supaya hanya penarikan yang berjalan.
      h.api.enqueue((_) => throw const NetworkFailure());
      h.api.syncPages.add(
        h.api.syncPage(
          tasks: [taskJson(deletedAt: t1, updatedAt: t1)],
        ),
      );
      await h.account.store.setMeta(MetaKeys.syncSince, 'T-0');
      await h.account.store.setMeta(MetaKeys.syncCollections, '${SyncEngine.collectionsVersion}');
      await h.account.sync.sync();

      expect((await h.local(EntityType.comment, commentId))!['deleted_at'], isNotNull);
      expect((await h.local(EntityType.reaction, reactionId))!['deleted_at'], isNotNull);
      expect((await h.local(EntityType.comment, mine.id))!['deleted_at'], isNull);
    });

    test('database versi 6 dinaikkan ke versi 7: tabel komentar dan reaksi, isi lama tetap ada', () async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      final dir = await Directory.systemTemp.createTemp('denly_migrasi7');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/akun.sqlite');

      final old = AppDatabase(NativeDatabase(file));
      await old.into(old.tasks).insert(taskCompanion(Task.fromJson(taskJson())));
      for (final statement in ['DROP TABLE comments', 'DROP TABLE reactions', 'PRAGMA user_version = 6']) {
        await old.customStatement(statement);
      }
      await old.close();

      final upgraded = AppDatabase(NativeDatabase(file));
      addTearDown(upgraded.close);
      expect((await upgraded.select(upgraded.tasks).getSingle()).title, 'Beli galon');
      await upgraded.into(upgraded.comments).insert(commentCompanion(Comment.fromJson(commentJson())));
      expect((await upgraded.select(upgraded.comments).getSingle()).toModel().body, 'Jangan lupa yang isi ulang, ya.');
    });
  });

  group('push', () {
    test('komentar pada setoran: tag per subjek dan isinya disembunyikan di layar kunci', () {
      const push = PushMessage(
        title: 'Dana Liburan',
        body: 'Sari: Mantap!',
        data: {
          'type': 'comment_created',
          'space_id': sharedSpaceId,
          'subject_type': 'savings_entry',
          'subject_id': entryId,
          'savings_goal_id': goalId,
        },
      );
      expect(push.isAboutConversation, isTrue);
      expect(push.isPrivate, isTrue);
      expect(push.tag, 'comment-$entryId');
      expect(push.channel, PushChannels.activity);

      const reaction = PushMessage(
        title: 'Beli galon',
        body: 'Sari memberi reaksi ❤️',
        data: {'type': 'reaction_created', 'space_id': sharedSpaceId, 'subject_type': 'task', 'subject_id': taskId},
      );
      expect(reaction.isPrivate, isFalse);
      expect(reaction.tag, 'reaction-$taskId');
    });
  });
}
