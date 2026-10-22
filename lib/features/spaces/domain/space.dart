import 'package:freezed_annotation/freezed_annotation.dart';

part 'space.freezed.dart';
part 'space.g.dart';

/// Sumber ruang di kontrak. `type` berisi `personal` atau `shared`.
@freezed
abstract class Space with _$Space {
  const Space._();

  const factory Space({
    required String id,
    required String name,
    required String type,
    required String timezone,
    required String ownerId,
    @Default(<SpaceMember>[]) List<SpaceMember> members,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _Space;

  factory Space.fromJson(Map<String, dynamic> json) => _$SpaceFromJson(json);

  bool get isShared => type == 'shared';

  bool get isPersonal => type == 'personal';
}

/// Profil anggota ruang seperti yang dilihat anggota lain.
@freezed
abstract class SpaceMember with _$SpaceMember {
  const factory SpaceMember({
    required String id,
    required String name,
    required String color,
    String? avatarUrl,
    @Default(0) int avatarVersion,

    /// `YYYY-MM-DD`, atau `--MM-DD` kalau tahun tidak diisi (v0.2). Dipakai HP pasangan
    /// untuk menghitung mundur ulang tahun.
    String? birthDate,
    required String role,
    required DateTime joinedAt,
  }) = _SpaceMember;

  factory SpaceMember.fromJson(Map<String, dynamic> json) => _$SpaceMemberFromJson(json);
}
