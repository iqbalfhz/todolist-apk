import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/time/space_clock.dart';
import '../../../core/utils/money.dart';
import '../../comments/domain/comment.dart';
import '../../memories/domain/memory.dart';
import '../../memories/domain/memory_photo.dart';
import '../../savings/domain/savings_entry.dart';
import '../../savings/domain/savings_goal.dart';
import '../../spaces/domain/household.dart';
import '../../spaces/domain/space.dart';
import '../../special_dates/domain/special_date.dart';
import '../../tasks/domain/task.dart';
import '../../trips/domain/trip.dart';

/// Jenis kejadian di feed aktivitas (kontrak, bagian Aktivitas).
enum ActivityKind {
  taskAdded,

  /// Tugas baru yang dititipkan ke anggota lain.
  taskAssigned,
  taskCompleted,
  deposit,
  withdrawal,
  goalCreated,

  /// Tanpa pelaku: tercapai karena setoran siapa pun.
  goalAchieved,
  tripPlanned,
  specialDateAdded,
  memorySaved,

  /// Foto yang ditambahkan ke kenangan yang sudah ada, digabung per kenangan per hari.
  photosAdded,
  commented,
  reacted,
  joined,
}

/// Satu baris di feed aktivitas.
class ActivityEvent {
  const ActivityEvent({
    required this.key,
    required this.kind,
    required this.time,
    required this.actorId,
    this.title,
    this.amount,
    this.text,
    this.count = 1,
    this.subjectType,
    this.subjectEntryType,
    this.assigneeId,
    this.route,
  });

  /// Kunci unik di feed.
  final String key;
  final ActivityKind kind;
  final DateTime time;

  /// Pelakunya; `null` untuk target yang tercapai.
  final String? actorId;

  /// Judul yang disebut: tugas, target, perjalanan, tanggal penting, atau kenangan. Untuk
  /// setoran, komentar, dan reaksi di setoran: nama targetnya.
  final String? title;

  /// Nominal setoran atau penarikan yang sudah diformat, juga untuk subjek komentar dan reaksi.
  final String? amount;

  /// Isi komentar atau emoji reaksi.
  final String? text;

  /// Banyaknya foto yang ditambahkan.
  final int count;

  /// Subjek komentar dan reaksi.
  final SubjectType? subjectType;

  /// `deposit` atau `withdrawal` kalau subjeknya setoran.
  final String? subjectEntryType;

  /// Orang yang dititipi tugas, untuk [ActivityKind.taskAssigned].
  final String? assigneeId;

  /// Layar yang dibuka saat barisnya diketuk, sama dengan notifikasinya; `null` kalau tidak ada.
  final String? route;
}

/// Feed hanya mencakup kegiatan 30 hari terakhir.
const Duration activityWindow = Duration(days: 30);

/// Semua isi feed untuk Ruang Bersama [shared], terbaru di atas. Data yang sudah dihapus tidak
/// punya kejadian; perubahan dan penghapusan tidak tersimpan sebagai riwayat, jadi tidak tampil.
List<ActivityEvent> activityEvents({
  required Space shared,
  required DateTime now,
  required SpaceClock clock,
  required List<Task> tasks,
  required List<SavingsGoal> goals,
  required List<SavingsEntry> entries,
  required List<Trip> trips,
  required List<SpecialDate> dates,
  required List<Memory> memories,
  required List<MemoryPhoto> photos,
  required List<Comment> comments,
  required List<Reaction> reactions,
}) {
  final since = now.subtract(activityWindow);
  bool inWindow(DateTime? time) => time != null && time.isAfter(since) && !time.isAfter(now.add(_clockSkew));
  bool inShared(String spaceId) => spaceId == shared.id;

  final liveTasks = {
    for (final task in tasks)
      if (task.deletedAt == null && inShared(task.spaceId)) task.id: task,
  };
  final liveGoals = {
    for (final goal in goals)
      if (goal.deletedAt == null && inShared(goal.spaceId)) goal.id: goal,
  };
  final liveEntries = {
    for (final entry in entries)
      if (entry.deletedAt == null && inShared(entry.spaceId) && liveGoals.containsKey(entry.savingsGoalId))
        entry.id: entry,
  };
  final liveMemories = {
    for (final memory in memories)
      if (memory.deletedAt == null && inShared(memory.spaceId)) memory.id: memory,
  };

  final events = <ActivityEvent>[];

  for (final task in liveTasks.values) {
    final creator = task.createdBy;
    if (creator != null && inWindow(task.createdAt)) {
      final assignee = _assignedTo(task, creator);
      events.add(
        ActivityEvent(
          key: 'task-${task.id}',
          kind: assignee == null ? ActivityKind.taskAdded : ActivityKind.taskAssigned,
          time: task.createdAt,
          actorId: creator,
          title: task.title,
          assigneeId: assignee,
          route: Routes.task(task.id),
        ),
      );
    }
    final completedBy = task.completedBy;
    if (completedBy != null && inWindow(task.completedAt)) {
      events.add(
        ActivityEvent(
          key: 'done-${task.id}',
          kind: ActivityKind.taskCompleted,
          time: task.completedAt!,
          actorId: completedBy,
          title: task.title,
          route: Routes.task(task.id),
        ),
      );
    }
  }

  for (final entry in liveEntries.values) {
    final goal = liveGoals[entry.savingsGoalId]!;
    if (entry.userId == null || !inWindow(entry.createdAt)) continue;
    events.add(
      ActivityEvent(
        key: 'entry-${entry.id}',
        kind: entry.type == 'withdrawal' ? ActivityKind.withdrawal : ActivityKind.deposit,
        time: entry.createdAt,
        actorId: entry.userId,
        title: goal.name,
        amount: formatMoney(entry.amount, goal.currency),
        route: Routes.goal(goal.id),
      ),
    );
  }

  for (final goal in liveGoals.values) {
    if (goal.createdBy != null && inWindow(goal.createdAt)) {
      events.add(
        ActivityEvent(
          key: 'goal-${goal.id}',
          kind: ActivityKind.goalCreated,
          time: goal.createdAt,
          actorId: goal.createdBy,
          title: goal.name,
          route: Routes.goal(goal.id),
        ),
      );
    }
    if (inWindow(goal.achievedAt)) {
      events.add(
        ActivityEvent(
          key: 'achieved-${goal.id}',
          kind: ActivityKind.goalAchieved,
          time: goal.achievedAt!,
          actorId: null,
          title: goal.name,
          route: Routes.goal(goal.id),
        ),
      );
    }
  }

  for (final trip in trips) {
    if (trip.deletedAt != null || !inShared(trip.spaceId) || trip.createdBy == null || !inWindow(trip.createdAt)) {
      continue;
    }
    events.add(
      ActivityEvent(
        key: 'trip-${trip.id}',
        kind: ActivityKind.tripPlanned,
        time: trip.createdAt,
        actorId: trip.createdBy,
        title: trip.title,
        route: Routes.trip(trip.id),
      ),
    );
  }

  for (final date in dates) {
    if (date.deletedAt != null || !inShared(date.spaceId) || date.createdBy == null || !inWindow(date.createdAt)) {
      continue;
    }
    events.add(
      ActivityEvent(
        key: 'date-${date.id}',
        kind: ActivityKind.specialDateAdded,
        time: date.createdAt,
        actorId: date.createdBy,
        title: date.title,
        route: Routes.specialDates,
      ),
    );
  }

  for (final memory in liveMemories.values) {
    if (memory.createdBy == null || !inWindow(memory.createdAt)) continue;
    events.add(
      ActivityEvent(
        key: 'memory-${memory.id}',
        kind: ActivityKind.memorySaved,
        time: memory.createdAt,
        actorId: memory.createdBy,
        title: memory.title,
        route: Routes.memory(memory.id),
      ),
    );
  }

  // Foto yang ditambahkan ke kenangan yang sudah ada: per kenangan, per pengunggah, per hari di
  // zona waktu ruang. Foto yang diunggah di hari kenangannya dibuat ikut kejadian kenangan itu.
  String dayOf(DateTime time) => clock.wallClock(time, shared.timezone).date;
  final photoGroups = <String, List<MemoryPhoto>>{};
  for (final photo in photos) {
    final memory = liveMemories[photo.memoryId];
    final uploader = photo.uploadedBy;
    if (photo.deletedAt != null || memory == null || uploader == null || !inWindow(photo.createdAt)) continue;
    final day = dayOf(photo.createdAt);
    if (day == dayOf(memory.createdAt)) continue;
    photoGroups.putIfAbsent('${memory.id}|$uploader|$day', () => []).add(photo);
  }
  for (final MapEntry(:key, value: group) in photoGroups.entries) {
    final memory = liveMemories[group.first.memoryId]!;
    final latest = group.map((photo) => photo.createdAt).reduce((a, b) => a.isAfter(b) ? a : b);
    events.add(
      ActivityEvent(
        key: 'photos-$key',
        kind: ActivityKind.photosAdded,
        time: latest,
        actorId: group.first.uploadedBy,
        title: memory.title,
        count: group.length,
        route: Routes.memory(memory.id),
      ),
    );
  }

  // Komentar dan reaksi menyebut subjeknya; yang subjeknya sudah dihapus tidak tampil.
  ActivityEvent? onSubject({
    required String key,
    required ActivityKind kind,
    required String subjectType,
    required String subjectId,
    required String? userId,
    required DateTime time,
    required String text,
  }) {
    if (userId == null || !inWindow(time)) return null;
    switch (SubjectType.tryParse(subjectType)) {
      case SubjectType.task:
        final task = liveTasks[subjectId];
        if (task == null) return null;
        return ActivityEvent(
          key: key,
          kind: kind,
          time: time,
          actorId: userId,
          title: task.title,
          text: text,
          subjectType: SubjectType.task,
          route: Routes.task(task.id, comments: true),
        );
      case SubjectType.memory:
        final memory = liveMemories[subjectId];
        if (memory == null) return null;
        return ActivityEvent(
          key: key,
          kind: kind,
          time: time,
          actorId: userId,
          title: memory.title,
          text: text,
          subjectType: SubjectType.memory,
          route: Routes.memory(memory.id, comments: true),
        );
      case SubjectType.savingsEntry:
        final entry = liveEntries[subjectId];
        if (entry == null) return null;
        final goal = liveGoals[entry.savingsGoalId]!;
        return ActivityEvent(
          key: key,
          kind: kind,
          time: time,
          actorId: userId,
          title: goal.name,
          amount: formatMoney(entry.amount, goal.currency),
          text: text,
          subjectType: SubjectType.savingsEntry,
          subjectEntryType: entry.type,
          route: Routes.goal(goal.id, entryId: entry.id),
        );
      case null:
        return null;
    }
  }

  for (final comment in comments) {
    if (comment.deletedAt != null || !inShared(comment.spaceId)) continue;
    final event = onSubject(
      key: 'comment-${comment.id}',
      kind: ActivityKind.commented,
      subjectType: comment.subjectType,
      subjectId: comment.subjectId,
      userId: comment.userId,
      time: comment.createdAt,
      text: comment.body,
    );
    if (event != null) events.add(event);
  }

  for (final reaction in reactions) {
    if (reaction.deletedAt != null || !inShared(reaction.spaceId)) continue;
    final event = onSubject(
      key: 'reaction-${reaction.id}',
      kind: ActivityKind.reacted,
      subjectType: reaction.subjectType,
      subjectId: reaction.subjectId,
      userId: reaction.userId,
      time: reaction.createdAt,
      text: reaction.emoji,
    );
    if (event != null) events.add(event);
  }

  for (final member in shared.members) {
    if (!inWindow(member.joinedAt)) continue;
    events.add(
      ActivityEvent(key: 'joined-${member.id}', kind: ActivityKind.joined, time: member.joinedAt, actorId: member.id),
    );
  }

  events.sort((a, b) {
    final byTime = b.time.compareTo(a.time);
    return byTime != 0 ? byTime : a.key.compareTo(b.key);
  });
  return events;
}

/// Jam HP dan server bisa sedikit berbeda; kejadian "dari masa depan" yang masih dalam batas ini
/// tetap ditampilkan.
const Duration _clockSkew = Duration(minutes: 5);

/// Anggota yang dititipi tugas: satu-satunya penanggung jawab, dan bukan pembuatnya.
String? _assignedTo(Task task, String creator) {
  final assignees = task.assigneeIds;
  if (assignees.length != 1 || assignees.single == creator) return null;
  return assignees.single;
}

/// Isi feed aktivitas dari cache lokal; `null` selama datanya belum terbaca, kosong kalau belum
/// berpasangan.
final activityEventsProvider = Provider<List<ActivityEvent>?>((ref) {
  final household = ref.watch(householdProvider);
  final tasks = ref.watch(tasksProvider).value;
  final goals = ref.watch(goalsProvider).value;
  final entries = ref.watch(entriesProvider).value;
  final trips = ref.watch(tripsProvider).value;
  final dates = ref.watch(specialDatesProvider).value;
  final memories = ref.watch(memoriesProvider).value;
  final photos = ref.watch(memoryPhotosProvider).value;
  final comments = ref.watch(commentsProvider).value;
  final reactions = ref.watch(reactionsProvider).value;
  final now = ref.watch(nowProvider);
  if (household == null ||
      tasks == null ||
      goals == null ||
      entries == null ||
      trips == null ||
      dates == null ||
      memories == null ||
      photos == null ||
      comments == null ||
      reactions == null) {
    return null;
  }
  final shared = household.shared;
  if (shared == null) return const [];

  return activityEvents(
    shared: shared,
    now: now,
    clock: ref.watch(spaceClockProvider),
    tasks: tasks,
    goals: goals,
    entries: entries,
    trips: trips,
    dates: dates,
    memories: memories,
    photos: photos,
    comments: comments,
    reactions: reactions,
  );
});

/// Waktu feed aktivitas terakhir dibuka di HP ini, per akun; `null` kalau belum pernah.
final activitySeenAtProvider = StreamProvider<DateTime?>((ref) {
  final account = ref.watch(accountProvider);
  if (account == null) return Stream.value(null);
  return account.store.watchMeta(activitySeenKey).map((raw) => raw == null ? null : DateTime.tryParse(raw));
});

/// Kunci meta waktu feed terakhir dibuka.
const String activitySeenKey = 'activity_seen_at';

/// Ada kegiatan pasangan sejak feed terakhir dibuka: titik di ikon lonceng Beranda.
final activityUnseenProvider = Provider<bool>((ref) {
  final events = ref.watch(activityEventsProvider);
  final partner = ref.watch(householdProvider)?.partner;
  final seen = ref.watch(activitySeenAtProvider);
  if (events == null || partner == null || seen.isLoading) return false;
  final seenAt = seen.value;
  return events.any((event) => event.actorId == partner.id && (seenAt == null || event.time.isAfter(seenAt)));
});
