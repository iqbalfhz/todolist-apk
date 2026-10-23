// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SpacesTable extends Spaces with TableInfo<$SpacesTable, SpaceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta('timezone');
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _membersMeta = const VerificationMeta('members');
  @override
  late final GeneratedColumn<String> members = GeneratedColumn<String>(
    'members',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<String> serverUpdatedAt = GeneratedColumn<String>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    timezone,
    ownerId,
    members,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spaces';
  @override
  VerificationContext validateIntegrity(Insertable<SpaceRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(_timezoneMeta, timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta));
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta, ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('members')) {
      context.handle(_membersMeta, members.isAcceptableOrUnknown(data['members']!, _membersMeta));
    } else if (isInserting) {
      context.missing(_membersMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(data['server_updated_at']!, _serverUpdatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpaceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpaceRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      timezone: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}timezone'])!,
      ownerId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      members: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}members'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $SpacesTable createAlias(String alias) {
    return $SpacesTable(attachedDatabase, alias);
  }
}

class SpaceRow extends DataClass implements Insertable<SpaceRow> {
  final String id;
  final String name;
  final String type;
  final String timezone;
  final String ownerId;

  /// JSON larik anggota, sama bentuknya dengan `members` di kontrak.
  final String members;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? serverUpdatedAt;
  const SpaceRow({
    required this.id,
    required this.name,
    required this.type,
    required this.timezone,
    required this.ownerId,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['timezone'] = Variable<String>(timezone);
    map['owner_id'] = Variable<String>(ownerId);
    map['members'] = Variable<String>(members);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt);
    }
    return map;
  }

  SpacesCompanion toCompanion(bool nullToAbsent) {
    return SpacesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      timezone: Value(timezone),
      ownerId: Value(ownerId),
      members: Value(members),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent ? const Value.absent() : Value(serverUpdatedAt),
    );
  }

  factory SpaceRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpaceRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      timezone: serializer.fromJson<String>(json['timezone']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      members: serializer.fromJson<String>(json['members']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'timezone': serializer.toJson<String>(timezone),
      'ownerId': serializer.toJson<String>(ownerId),
      'members': serializer.toJson<String>(members),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'serverUpdatedAt': serializer.toJson<String?>(serverUpdatedAt),
    };
  }

  SpaceRow copyWith({
    String? id,
    String? name,
    String? type,
    String? timezone,
    String? ownerId,
    String? members,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> serverUpdatedAt = const Value.absent(),
  }) => SpaceRow(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    timezone: timezone ?? this.timezone,
    ownerId: ownerId ?? this.ownerId,
    members: members ?? this.members,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverUpdatedAt: serverUpdatedAt.present ? serverUpdatedAt.value : this.serverUpdatedAt,
  );
  SpaceRow copyWithCompanion(SpacesCompanion data) {
    return SpaceRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      members: data.members.present ? data.members.value : this.members,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverUpdatedAt: data.serverUpdatedAt.present ? data.serverUpdatedAt.value : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpaceRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('timezone: $timezone, ')
          ..write('ownerId: $ownerId, ')
          ..write('members: $members, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, type, timezone, ownerId, members, createdAt, updatedAt, deletedAt, serverUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpaceRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.timezone == this.timezone &&
          other.ownerId == this.ownerId &&
          other.members == this.members &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class SpacesCompanion extends UpdateCompanion<SpaceRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> timezone;
  final Value<String> ownerId;
  final Value<String> members;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> serverUpdatedAt;
  final Value<int> rowid;
  const SpacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.timezone = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.members = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpacesCompanion.insert({
    required String id,
    required String name,
    required String type,
    required String timezone,
    required String ownerId,
    required String members,
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       timezone = Value(timezone),
       ownerId = Value(ownerId),
       members = Value(members),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SpaceRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? timezone,
    Expression<String>? ownerId,
    Expression<String>? members,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (timezone != null) 'timezone': timezone,
      if (ownerId != null) 'owner_id': ownerId,
      if (members != null) 'members': members,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpacesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String>? timezone,
    Value<String>? ownerId,
    Value<String>? members,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return SpacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      timezone: timezone ?? this.timezone,
      ownerId: ownerId ?? this.ownerId,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (members.present) {
      map['members'] = Variable<String>(members.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('timezone: $timezone, ')
          ..write('ownerId: $ownerId, ')
          ..write('members: $members, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskListsTable extends TaskLists with TableInfo<$TaskListsTable, TaskListRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta('spaceId');
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta('position');
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta('archivedAt');
  @override
  late final GeneratedColumn<String> archivedAt = GeneratedColumn<String>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<String> serverUpdatedAt = GeneratedColumn<String>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    name,
    emoji,
    color,
    position,
    archivedAt,
    tripId,
    createdBy,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_lists';
  @override
  VerificationContext validateIntegrity(Insertable<TaskListRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(_spaceIdMeta, spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta));
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(_emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    }
    if (data.containsKey('color')) {
      context.handle(_colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta, position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(_archivedAtMeta, archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta));
    }
    if (data.containsKey('trip_id')) {
      context.handle(_tripIdMeta, tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta, createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(data['server_updated_at']!, _serverUpdatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskListRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskListRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      spaceId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}space_id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      emoji: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}emoji']),
      color: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      position: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}position'])!,
      archivedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}archived_at']),
      tripId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}trip_id']),
      createdBy: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $TaskListsTable createAlias(String alias) {
    return $TaskListsTable(attachedDatabase, alias);
  }
}

class TaskListRow extends DataClass implements Insertable<TaskListRow> {
  final String id;
  final String spaceId;
  final String name;
  final String? emoji;
  final String color;
  final double position;
  final String? archivedAt;

  /// Terisi berarti daftar ini checklist persiapan sebuah perjalanan (v0.2).
  final String? tripId;
  final String? createdBy;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? serverUpdatedAt;
  const TaskListRow({
    required this.id,
    required this.spaceId,
    required this.name,
    this.emoji,
    required this.color,
    required this.position,
    this.archivedAt,
    this.tripId,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || emoji != null) {
      map['emoji'] = Variable<String>(emoji);
    }
    map['color'] = Variable<String>(color);
    map['position'] = Variable<double>(position);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<String>(archivedAt);
    }
    if (!nullToAbsent || tripId != null) {
      map['trip_id'] = Variable<String>(tripId);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt);
    }
    return map;
  }

  TaskListsCompanion toCompanion(bool nullToAbsent) {
    return TaskListsCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      name: Value(name),
      emoji: emoji == null && nullToAbsent ? const Value.absent() : Value(emoji),
      color: Value(color),
      position: Value(position),
      archivedAt: archivedAt == null && nullToAbsent ? const Value.absent() : Value(archivedAt),
      tripId: tripId == null && nullToAbsent ? const Value.absent() : Value(tripId),
      createdBy: createdBy == null && nullToAbsent ? const Value.absent() : Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent ? const Value.absent() : Value(serverUpdatedAt),
    );
  }

  factory TaskListRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskListRow(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String?>(json['emoji']),
      color: serializer.fromJson<String>(json['color']),
      position: serializer.fromJson<double>(json['position']),
      archivedAt: serializer.fromJson<String?>(json['archivedAt']),
      tripId: serializer.fromJson<String?>(json['tripId']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String?>(emoji),
      'color': serializer.toJson<String>(color),
      'position': serializer.toJson<double>(position),
      'archivedAt': serializer.toJson<String?>(archivedAt),
      'tripId': serializer.toJson<String?>(tripId),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'serverUpdatedAt': serializer.toJson<String?>(serverUpdatedAt),
    };
  }

  TaskListRow copyWith({
    String? id,
    String? spaceId,
    String? name,
    Value<String?> emoji = const Value.absent(),
    String? color,
    double? position,
    Value<String?> archivedAt = const Value.absent(),
    Value<String?> tripId = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> serverUpdatedAt = const Value.absent(),
  }) => TaskListRow(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    name: name ?? this.name,
    emoji: emoji.present ? emoji.value : this.emoji,
    color: color ?? this.color,
    position: position ?? this.position,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    tripId: tripId.present ? tripId.value : this.tripId,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverUpdatedAt: serverUpdatedAt.present ? serverUpdatedAt.value : this.serverUpdatedAt,
  );
  TaskListRow copyWithCompanion(TaskListsCompanion data) {
    return TaskListRow(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      color: data.color.present ? data.color.value : this.color,
      position: data.position.present ? data.position.value : this.position,
      archivedAt: data.archivedAt.present ? data.archivedAt.value : this.archivedAt,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverUpdatedAt: data.serverUpdatedAt.present ? data.serverUpdatedAt.value : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskListRow(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color, ')
          ..write('position: $position, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('tripId: $tripId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    spaceId,
    name,
    emoji,
    color,
    position,
    archivedAt,
    tripId,
    createdBy,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskListRow &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.color == this.color &&
          other.position == this.position &&
          other.archivedAt == this.archivedAt &&
          other.tripId == this.tripId &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class TaskListsCompanion extends UpdateCompanion<TaskListRow> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> name;
  final Value<String?> emoji;
  final Value<String> color;
  final Value<double> position;
  final Value<String?> archivedAt;
  final Value<String?> tripId;
  final Value<String?> createdBy;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> serverUpdatedAt;
  final Value<int> rowid;
  const TaskListsCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.color = const Value.absent(),
    this.position = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.tripId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskListsCompanion.insert({
    required String id,
    required String spaceId,
    required String name,
    this.emoji = const Value.absent(),
    required String color,
    required double position,
    this.archivedAt = const Value.absent(),
    this.tripId = const Value.absent(),
    this.createdBy = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spaceId = Value(spaceId),
       name = Value(name),
       color = Value(color),
       position = Value(position),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaskListRow> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<String>? color,
    Expression<double>? position,
    Expression<String>? archivedAt,
    Expression<String>? tripId,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (color != null) 'color': color,
      if (position != null) 'position': position,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (tripId != null) 'trip_id': tripId,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskListsCompanion copyWith({
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? name,
    Value<String?>? emoji,
    Value<String>? color,
    Value<double>? position,
    Value<String?>? archivedAt,
    Value<String?>? tripId,
    Value<String?>? createdBy,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return TaskListsCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      position: position ?? this.position,
      archivedAt: archivedAt ?? this.archivedAt,
      tripId: tripId ?? this.tripId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (position.present) {
      map['position'] = Variable<double>(position.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<String>(archivedAt.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskListsCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color, ')
          ..write('position: $position, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('tripId: $tripId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskListIdMeta = const VerificationMeta('taskListId');
  @override
  late final GeneratedColumn<String> taskListId = GeneratedColumn<String>(
    'task_list_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta('spaceId');
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueTimeMeta = const VerificationMeta('dueTime');
  @override
  late final GeneratedColumn<String> dueTime = GeneratedColumn<String>(
    'due_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta('position');
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assigneeIdsMeta = const VerificationMeta('assigneeIds');
  @override
  late final GeneratedColumn<String> assigneeIds = GeneratedColumn<String>(
    'assignee_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remindAtMeta = const VerificationMeta('remindAt');
  @override
  late final GeneratedColumn<String> remindAt = GeneratedColumn<String>(
    'remind_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<String> completedAt = GeneratedColumn<String>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedByMeta = const VerificationMeta('completedBy');
  @override
  late final GeneratedColumn<String> completedBy = GeneratedColumn<String>(
    'completed_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta('updatedBy');
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<String> serverUpdatedAt = GeneratedColumn<String>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskListId,
    spaceId,
    title,
    notes,
    dueDate,
    dueTime,
    priority,
    position,
    assigneeIds,
    remindAt,
    completedAt,
    completedBy,
    createdBy,
    updatedBy,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<TaskRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_list_id')) {
      context.handle(_taskListIdMeta, taskListId.isAcceptableOrUnknown(data['task_list_id']!, _taskListIdMeta));
    } else if (isInserting) {
      context.missing(_taskListIdMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(_spaceIdMeta, spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta));
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta, dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('due_time')) {
      context.handle(_dueTimeMeta, dueTime.isAcceptableOrUnknown(data['due_time']!, _dueTimeMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta, priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta, position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('assignee_ids')) {
      context.handle(_assigneeIdsMeta, assigneeIds.isAcceptableOrUnknown(data['assignee_ids']!, _assigneeIdsMeta));
    } else if (isInserting) {
      context.missing(_assigneeIdsMeta);
    }
    if (data.containsKey('remind_at')) {
      context.handle(_remindAtMeta, remindAt.isAcceptableOrUnknown(data['remind_at']!, _remindAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(_completedAtMeta, completedAt.isAcceptableOrUnknown(data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('completed_by')) {
      context.handle(_completedByMeta, completedBy.isAcceptableOrUnknown(data['completed_by']!, _completedByMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta, createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta, updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(data['server_updated_at']!, _serverUpdatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      taskListId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}task_list_id'])!,
      spaceId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}space_id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes']),
      dueDate: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}due_date']),
      dueTime: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}due_time']),
      priority: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      position: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}position'])!,
      assigneeIds: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}assignee_ids'])!,
      remindAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}remind_at']),
      completedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}completed_at']),
      completedBy: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}completed_by']),
      createdBy: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      updatedBy: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}updated_by']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final String id;
  final String taskListId;
  final String spaceId;
  final String title;
  final String? notes;
  final String? dueDate;
  final String? dueTime;
  final int priority;
  final double position;

  /// JSON larik ID penanggung jawab.
  final String assigneeIds;
  final String? remindAt;
  final String? completedAt;
  final String? completedBy;
  final String? createdBy;
  final String? updatedBy;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? serverUpdatedAt;
  const TaskRow({
    required this.id,
    required this.taskListId,
    required this.spaceId,
    required this.title,
    this.notes,
    this.dueDate,
    this.dueTime,
    required this.priority,
    required this.position,
    required this.assigneeIds,
    this.remindAt,
    this.completedAt,
    this.completedBy,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_list_id'] = Variable<String>(taskListId);
    map['space_id'] = Variable<String>(spaceId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<String>(dueDate);
    }
    if (!nullToAbsent || dueTime != null) {
      map['due_time'] = Variable<String>(dueTime);
    }
    map['priority'] = Variable<int>(priority);
    map['position'] = Variable<double>(position);
    map['assignee_ids'] = Variable<String>(assigneeIds);
    if (!nullToAbsent || remindAt != null) {
      map['remind_at'] = Variable<String>(remindAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<String>(completedAt);
    }
    if (!nullToAbsent || completedBy != null) {
      map['completed_by'] = Variable<String>(completedBy);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      taskListId: Value(taskListId),
      spaceId: Value(spaceId),
      title: Value(title),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      dueDate: dueDate == null && nullToAbsent ? const Value.absent() : Value(dueDate),
      dueTime: dueTime == null && nullToAbsent ? const Value.absent() : Value(dueTime),
      priority: Value(priority),
      position: Value(position),
      assigneeIds: Value(assigneeIds),
      remindAt: remindAt == null && nullToAbsent ? const Value.absent() : Value(remindAt),
      completedAt: completedAt == null && nullToAbsent ? const Value.absent() : Value(completedAt),
      completedBy: completedBy == null && nullToAbsent ? const Value.absent() : Value(completedBy),
      createdBy: createdBy == null && nullToAbsent ? const Value.absent() : Value(createdBy),
      updatedBy: updatedBy == null && nullToAbsent ? const Value.absent() : Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent ? const Value.absent() : Value(serverUpdatedAt),
    );
  }

  factory TaskRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<String>(json['id']),
      taskListId: serializer.fromJson<String>(json['taskListId']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      dueDate: serializer.fromJson<String?>(json['dueDate']),
      dueTime: serializer.fromJson<String?>(json['dueTime']),
      priority: serializer.fromJson<int>(json['priority']),
      position: serializer.fromJson<double>(json['position']),
      assigneeIds: serializer.fromJson<String>(json['assigneeIds']),
      remindAt: serializer.fromJson<String?>(json['remindAt']),
      completedAt: serializer.fromJson<String?>(json['completedAt']),
      completedBy: serializer.fromJson<String?>(json['completedBy']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskListId': serializer.toJson<String>(taskListId),
      'spaceId': serializer.toJson<String>(spaceId),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'dueDate': serializer.toJson<String?>(dueDate),
      'dueTime': serializer.toJson<String?>(dueTime),
      'priority': serializer.toJson<int>(priority),
      'position': serializer.toJson<double>(position),
      'assigneeIds': serializer.toJson<String>(assigneeIds),
      'remindAt': serializer.toJson<String?>(remindAt),
      'completedAt': serializer.toJson<String?>(completedAt),
      'completedBy': serializer.toJson<String?>(completedBy),
      'createdBy': serializer.toJson<String?>(createdBy),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'serverUpdatedAt': serializer.toJson<String?>(serverUpdatedAt),
    };
  }

  TaskRow copyWith({
    String? id,
    String? taskListId,
    String? spaceId,
    String? title,
    Value<String?> notes = const Value.absent(),
    Value<String?> dueDate = const Value.absent(),
    Value<String?> dueTime = const Value.absent(),
    int? priority,
    double? position,
    String? assigneeIds,
    Value<String?> remindAt = const Value.absent(),
    Value<String?> completedAt = const Value.absent(),
    Value<String?> completedBy = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> serverUpdatedAt = const Value.absent(),
  }) => TaskRow(
    id: id ?? this.id,
    taskListId: taskListId ?? this.taskListId,
    spaceId: spaceId ?? this.spaceId,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    dueTime: dueTime.present ? dueTime.value : this.dueTime,
    priority: priority ?? this.priority,
    position: position ?? this.position,
    assigneeIds: assigneeIds ?? this.assigneeIds,
    remindAt: remindAt.present ? remindAt.value : this.remindAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    completedBy: completedBy.present ? completedBy.value : this.completedBy,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverUpdatedAt: serverUpdatedAt.present ? serverUpdatedAt.value : this.serverUpdatedAt,
  );
  TaskRow copyWithCompanion(TasksCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      taskListId: data.taskListId.present ? data.taskListId.value : this.taskListId,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      dueTime: data.dueTime.present ? data.dueTime.value : this.dueTime,
      priority: data.priority.present ? data.priority.value : this.priority,
      position: data.position.present ? data.position.value : this.position,
      assigneeIds: data.assigneeIds.present ? data.assigneeIds.value : this.assigneeIds,
      remindAt: data.remindAt.present ? data.remindAt.value : this.remindAt,
      completedAt: data.completedAt.present ? data.completedAt.value : this.completedAt,
      completedBy: data.completedBy.present ? data.completedBy.value : this.completedBy,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverUpdatedAt: data.serverUpdatedAt.present ? data.serverUpdatedAt.value : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('taskListId: $taskListId, ')
          ..write('spaceId: $spaceId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('dueDate: $dueDate, ')
          ..write('dueTime: $dueTime, ')
          ..write('priority: $priority, ')
          ..write('position: $position, ')
          ..write('assigneeIds: $assigneeIds, ')
          ..write('remindAt: $remindAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('completedBy: $completedBy, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskListId,
    spaceId,
    title,
    notes,
    dueDate,
    dueTime,
    priority,
    position,
    assigneeIds,
    remindAt,
    completedAt,
    completedBy,
    createdBy,
    updatedBy,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.taskListId == this.taskListId &&
          other.spaceId == this.spaceId &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.dueDate == this.dueDate &&
          other.dueTime == this.dueTime &&
          other.priority == this.priority &&
          other.position == this.position &&
          other.assigneeIds == this.assigneeIds &&
          other.remindAt == this.remindAt &&
          other.completedAt == this.completedAt &&
          other.completedBy == this.completedBy &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<String> id;
  final Value<String> taskListId;
  final Value<String> spaceId;
  final Value<String> title;
  final Value<String?> notes;
  final Value<String?> dueDate;
  final Value<String?> dueTime;
  final Value<int> priority;
  final Value<double> position;
  final Value<String> assigneeIds;
  final Value<String?> remindAt;
  final Value<String?> completedAt;
  final Value<String?> completedBy;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> serverUpdatedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.taskListId = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.dueTime = const Value.absent(),
    this.priority = const Value.absent(),
    this.position = const Value.absent(),
    this.assigneeIds = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.completedBy = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String taskListId,
    required String spaceId,
    required String title,
    this.notes = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.dueTime = const Value.absent(),
    required int priority,
    required double position,
    required String assigneeIds,
    this.remindAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.completedBy = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskListId = Value(taskListId),
       spaceId = Value(spaceId),
       title = Value(title),
       priority = Value(priority),
       position = Value(position),
       assigneeIds = Value(assigneeIds),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaskRow> custom({
    Expression<String>? id,
    Expression<String>? taskListId,
    Expression<String>? spaceId,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<String>? dueDate,
    Expression<String>? dueTime,
    Expression<int>? priority,
    Expression<double>? position,
    Expression<String>? assigneeIds,
    Expression<String>? remindAt,
    Expression<String>? completedAt,
    Expression<String>? completedBy,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskListId != null) 'task_list_id': taskListId,
      if (spaceId != null) 'space_id': spaceId,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (dueDate != null) 'due_date': dueDate,
      if (dueTime != null) 'due_time': dueTime,
      if (priority != null) 'priority': priority,
      if (position != null) 'position': position,
      if (assigneeIds != null) 'assignee_ids': assigneeIds,
      if (remindAt != null) 'remind_at': remindAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (completedBy != null) 'completed_by': completedBy,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? taskListId,
    Value<String>? spaceId,
    Value<String>? title,
    Value<String?>? notes,
    Value<String?>? dueDate,
    Value<String?>? dueTime,
    Value<int>? priority,
    Value<double>? position,
    Value<String>? assigneeIds,
    Value<String?>? remindAt,
    Value<String?>? completedAt,
    Value<String?>? completedBy,
    Value<String?>? createdBy,
    Value<String?>? updatedBy,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      taskListId: taskListId ?? this.taskListId,
      spaceId: spaceId ?? this.spaceId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      position: position ?? this.position,
      assigneeIds: assigneeIds ?? this.assigneeIds,
      remindAt: remindAt ?? this.remindAt,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskListId.present) {
      map['task_list_id'] = Variable<String>(taskListId.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (dueTime.present) {
      map['due_time'] = Variable<String>(dueTime.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (position.present) {
      map['position'] = Variable<double>(position.value);
    }
    if (assigneeIds.present) {
      map['assignee_ids'] = Variable<String>(assigneeIds.value);
    }
    if (remindAt.present) {
      map['remind_at'] = Variable<String>(remindAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<String>(completedAt.value);
    }
    if (completedBy.present) {
      map['completed_by'] = Variable<String>(completedBy.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('taskListId: $taskListId, ')
          ..write('spaceId: $spaceId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('dueDate: $dueDate, ')
          ..write('dueTime: $dueTime, ')
          ..write('priority: $priority, ')
          ..write('position: $position, ')
          ..write('assigneeIds: $assigneeIds, ')
          ..write('remindAt: $remindAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('completedBy: $completedBy, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingsGoalsTable extends SavingsGoals with TableInfo<$SavingsGoalsTable, SavingsGoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta('spaceId');
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetAmountMeta = const VerificationMeta('targetAmount');
  @override
  late final GeneratedColumn<int> targetAmount = GeneratedColumn<int>(
    'target_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta('targetDate');
  @override
  late final GeneratedColumn<String> targetDate = GeneratedColumn<String>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderFrequencyMeta = const VerificationMeta('reminderFrequency');
  @override
  late final GeneratedColumn<String> reminderFrequency = GeneratedColumn<String>(
    'reminder_frequency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderDayMeta = const VerificationMeta('reminderDay');
  @override
  late final GeneratedColumn<int> reminderDay = GeneratedColumn<int>(
    'reminder_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _achievedAtMeta = const VerificationMeta('achievedAt');
  @override
  late final GeneratedColumn<String> achievedAt = GeneratedColumn<String>(
    'achieved_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta('archivedAt');
  @override
  late final GeneratedColumn<String> archivedAt = GeneratedColumn<String>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<String> serverUpdatedAt = GeneratedColumn<String>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    name,
    emoji,
    targetAmount,
    currency,
    targetDate,
    reminderFrequency,
    reminderDay,
    achievedAt,
    archivedAt,
    createdBy,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_goals';
  @override
  VerificationContext validateIntegrity(Insertable<SavingsGoalRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(_spaceIdMeta, spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta));
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(_emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    }
    if (data.containsKey('target_amount')) {
      context.handle(_targetAmountMeta, targetAmount.isAcceptableOrUnknown(data['target_amount']!, _targetAmountMeta));
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta, currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('target_date')) {
      context.handle(_targetDateMeta, targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta));
    }
    if (data.containsKey('reminder_frequency')) {
      context.handle(
        _reminderFrequencyMeta,
        reminderFrequency.isAcceptableOrUnknown(data['reminder_frequency']!, _reminderFrequencyMeta),
      );
    }
    if (data.containsKey('reminder_day')) {
      context.handle(_reminderDayMeta, reminderDay.isAcceptableOrUnknown(data['reminder_day']!, _reminderDayMeta));
    }
    if (data.containsKey('achieved_at')) {
      context.handle(_achievedAtMeta, achievedAt.isAcceptableOrUnknown(data['achieved_at']!, _achievedAtMeta));
    }
    if (data.containsKey('archived_at')) {
      context.handle(_archivedAtMeta, archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta, createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(data['server_updated_at']!, _serverUpdatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingsGoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsGoalRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      spaceId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}space_id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      emoji: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}emoji']),
      targetAmount: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}target_amount'])!,
      currency: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      targetDate: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}target_date']),
      reminderFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_frequency'],
      ),
      reminderDay: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}reminder_day']),
      achievedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}achieved_at']),
      archivedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}archived_at']),
      createdBy: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $SavingsGoalsTable createAlias(String alias) {
    return $SavingsGoalsTable(attachedDatabase, alias);
  }
}

class SavingsGoalRow extends DataClass implements Insertable<SavingsGoalRow> {
  final String id;
  final String spaceId;
  final String name;
  final String? emoji;
  final int targetAmount;
  final String currency;
  final String? targetDate;

  /// Pengingat setor rutin (v0.2): `weekly` atau `monthly`, dan hari atau tanggalnya.
  final String? reminderFrequency;
  final int? reminderDay;
  final String? achievedAt;
  final String? archivedAt;
  final String? createdBy;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? serverUpdatedAt;
  const SavingsGoalRow({
    required this.id,
    required this.spaceId,
    required this.name,
    this.emoji,
    required this.targetAmount,
    required this.currency,
    this.targetDate,
    this.reminderFrequency,
    this.reminderDay,
    this.achievedAt,
    this.archivedAt,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || emoji != null) {
      map['emoji'] = Variable<String>(emoji);
    }
    map['target_amount'] = Variable<int>(targetAmount);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<String>(targetDate);
    }
    if (!nullToAbsent || reminderFrequency != null) {
      map['reminder_frequency'] = Variable<String>(reminderFrequency);
    }
    if (!nullToAbsent || reminderDay != null) {
      map['reminder_day'] = Variable<int>(reminderDay);
    }
    if (!nullToAbsent || achievedAt != null) {
      map['achieved_at'] = Variable<String>(achievedAt);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<String>(archivedAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt);
    }
    return map;
  }

  SavingsGoalsCompanion toCompanion(bool nullToAbsent) {
    return SavingsGoalsCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      name: Value(name),
      emoji: emoji == null && nullToAbsent ? const Value.absent() : Value(emoji),
      targetAmount: Value(targetAmount),
      currency: Value(currency),
      targetDate: targetDate == null && nullToAbsent ? const Value.absent() : Value(targetDate),
      reminderFrequency: reminderFrequency == null && nullToAbsent ? const Value.absent() : Value(reminderFrequency),
      reminderDay: reminderDay == null && nullToAbsent ? const Value.absent() : Value(reminderDay),
      achievedAt: achievedAt == null && nullToAbsent ? const Value.absent() : Value(achievedAt),
      archivedAt: archivedAt == null && nullToAbsent ? const Value.absent() : Value(archivedAt),
      createdBy: createdBy == null && nullToAbsent ? const Value.absent() : Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent ? const Value.absent() : Value(serverUpdatedAt),
    );
  }

  factory SavingsGoalRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsGoalRow(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String?>(json['emoji']),
      targetAmount: serializer.fromJson<int>(json['targetAmount']),
      currency: serializer.fromJson<String>(json['currency']),
      targetDate: serializer.fromJson<String?>(json['targetDate']),
      reminderFrequency: serializer.fromJson<String?>(json['reminderFrequency']),
      reminderDay: serializer.fromJson<int?>(json['reminderDay']),
      achievedAt: serializer.fromJson<String?>(json['achievedAt']),
      archivedAt: serializer.fromJson<String?>(json['archivedAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String?>(emoji),
      'targetAmount': serializer.toJson<int>(targetAmount),
      'currency': serializer.toJson<String>(currency),
      'targetDate': serializer.toJson<String?>(targetDate),
      'reminderFrequency': serializer.toJson<String?>(reminderFrequency),
      'reminderDay': serializer.toJson<int?>(reminderDay),
      'achievedAt': serializer.toJson<String?>(achievedAt),
      'archivedAt': serializer.toJson<String?>(archivedAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'serverUpdatedAt': serializer.toJson<String?>(serverUpdatedAt),
    };
  }

  SavingsGoalRow copyWith({
    String? id,
    String? spaceId,
    String? name,
    Value<String?> emoji = const Value.absent(),
    int? targetAmount,
    String? currency,
    Value<String?> targetDate = const Value.absent(),
    Value<String?> reminderFrequency = const Value.absent(),
    Value<int?> reminderDay = const Value.absent(),
    Value<String?> achievedAt = const Value.absent(),
    Value<String?> archivedAt = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> serverUpdatedAt = const Value.absent(),
  }) => SavingsGoalRow(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    name: name ?? this.name,
    emoji: emoji.present ? emoji.value : this.emoji,
    targetAmount: targetAmount ?? this.targetAmount,
    currency: currency ?? this.currency,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    reminderFrequency: reminderFrequency.present ? reminderFrequency.value : this.reminderFrequency,
    reminderDay: reminderDay.present ? reminderDay.value : this.reminderDay,
    achievedAt: achievedAt.present ? achievedAt.value : this.achievedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverUpdatedAt: serverUpdatedAt.present ? serverUpdatedAt.value : this.serverUpdatedAt,
  );
  SavingsGoalRow copyWithCompanion(SavingsGoalsCompanion data) {
    return SavingsGoalRow(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      targetAmount: data.targetAmount.present ? data.targetAmount.value : this.targetAmount,
      currency: data.currency.present ? data.currency.value : this.currency,
      targetDate: data.targetDate.present ? data.targetDate.value : this.targetDate,
      reminderFrequency: data.reminderFrequency.present ? data.reminderFrequency.value : this.reminderFrequency,
      reminderDay: data.reminderDay.present ? data.reminderDay.value : this.reminderDay,
      achievedAt: data.achievedAt.present ? data.achievedAt.value : this.achievedAt,
      archivedAt: data.archivedAt.present ? data.archivedAt.value : this.archivedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverUpdatedAt: data.serverUpdatedAt.present ? data.serverUpdatedAt.value : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalRow(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currency: $currency, ')
          ..write('targetDate: $targetDate, ')
          ..write('reminderFrequency: $reminderFrequency, ')
          ..write('reminderDay: $reminderDay, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    spaceId,
    name,
    emoji,
    targetAmount,
    currency,
    targetDate,
    reminderFrequency,
    reminderDay,
    achievedAt,
    archivedAt,
    createdBy,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsGoalRow &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.targetAmount == this.targetAmount &&
          other.currency == this.currency &&
          other.targetDate == this.targetDate &&
          other.reminderFrequency == this.reminderFrequency &&
          other.reminderDay == this.reminderDay &&
          other.achievedAt == this.achievedAt &&
          other.archivedAt == this.archivedAt &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class SavingsGoalsCompanion extends UpdateCompanion<SavingsGoalRow> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> name;
  final Value<String?> emoji;
  final Value<int> targetAmount;
  final Value<String> currency;
  final Value<String?> targetDate;
  final Value<String?> reminderFrequency;
  final Value<int?> reminderDay;
  final Value<String?> achievedAt;
  final Value<String?> archivedAt;
  final Value<String?> createdBy;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> serverUpdatedAt;
  final Value<int> rowid;
  const SavingsGoalsCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.currency = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.reminderFrequency = const Value.absent(),
    this.reminderDay = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingsGoalsCompanion.insert({
    required String id,
    required String spaceId,
    required String name,
    this.emoji = const Value.absent(),
    required int targetAmount,
    required String currency,
    this.targetDate = const Value.absent(),
    this.reminderFrequency = const Value.absent(),
    this.reminderDay = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spaceId = Value(spaceId),
       name = Value(name),
       targetAmount = Value(targetAmount),
       currency = Value(currency),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SavingsGoalRow> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<int>? targetAmount,
    Expression<String>? currency,
    Expression<String>? targetDate,
    Expression<String>? reminderFrequency,
    Expression<int>? reminderDay,
    Expression<String>? achievedAt,
    Expression<String>? archivedAt,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (currency != null) 'currency': currency,
      if (targetDate != null) 'target_date': targetDate,
      if (reminderFrequency != null) 'reminder_frequency': reminderFrequency,
      if (reminderDay != null) 'reminder_day': reminderDay,
      if (achievedAt != null) 'achieved_at': achievedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingsGoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? name,
    Value<String?>? emoji,
    Value<int>? targetAmount,
    Value<String>? currency,
    Value<String?>? targetDate,
    Value<String?>? reminderFrequency,
    Value<int?>? reminderDay,
    Value<String?>? achievedAt,
    Value<String?>? archivedAt,
    Value<String?>? createdBy,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return SavingsGoalsCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      targetAmount: targetAmount ?? this.targetAmount,
      currency: currency ?? this.currency,
      targetDate: targetDate ?? this.targetDate,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
      reminderDay: reminderDay ?? this.reminderDay,
      achievedAt: achievedAt ?? this.achievedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<int>(targetAmount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<String>(targetDate.value);
    }
    if (reminderFrequency.present) {
      map['reminder_frequency'] = Variable<String>(reminderFrequency.value);
    }
    if (reminderDay.present) {
      map['reminder_day'] = Variable<int>(reminderDay.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<String>(achievedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<String>(archivedAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalsCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currency: $currency, ')
          ..write('targetDate: $targetDate, ')
          ..write('reminderFrequency: $reminderFrequency, ')
          ..write('reminderDay: $reminderDay, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingsEntriesTable extends SavingsEntries with TableInfo<$SavingsEntriesTable, SavingsEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savingsGoalIdMeta = const VerificationMeta('savingsGoalId');
  @override
  late final GeneratedColumn<String> savingsGoalId = GeneratedColumn<String>(
    'savings_goal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta('spaceId');
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta('entryDate');
  @override
  late final GeneratedColumn<String> entryDate = GeneratedColumn<String>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<String> serverUpdatedAt = GeneratedColumn<String>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    savingsGoalId,
    spaceId,
    userId,
    type,
    amount,
    entryDate,
    note,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_entries';
  @override
  VerificationContext validateIntegrity(Insertable<SavingsEntryRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('savings_goal_id')) {
      context.handle(
        _savingsGoalIdMeta,
        savingsGoalId.isAcceptableOrUnknown(data['savings_goal_id']!, _savingsGoalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_savingsGoalIdMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(_spaceIdMeta, spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta));
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta, amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(_entryDateMeta, entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta));
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(data['server_updated_at']!, _serverUpdatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingsEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsEntryRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      savingsGoalId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}savings_goal_id'])!,
      spaceId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}space_id'])!,
      userId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      amount: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      entryDate: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}entry_date'])!,
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $SavingsEntriesTable createAlias(String alias) {
    return $SavingsEntriesTable(attachedDatabase, alias);
  }
}

class SavingsEntryRow extends DataClass implements Insertable<SavingsEntryRow> {
  final String id;
  final String savingsGoalId;
  final String spaceId;
  final String? userId;
  final String type;
  final int amount;
  final String entryDate;
  final String? note;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? serverUpdatedAt;
  const SavingsEntryRow({
    required this.id,
    required this.savingsGoalId,
    required this.spaceId,
    this.userId,
    required this.type,
    required this.amount,
    required this.entryDate,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['savings_goal_id'] = Variable<String>(savingsGoalId);
    map['space_id'] = Variable<String>(spaceId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<int>(amount);
    map['entry_date'] = Variable<String>(entryDate);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt);
    }
    return map;
  }

  SavingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return SavingsEntriesCompanion(
      id: Value(id),
      savingsGoalId: Value(savingsGoalId),
      spaceId: Value(spaceId),
      userId: userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      type: Value(type),
      amount: Value(amount),
      entryDate: Value(entryDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent ? const Value.absent() : Value(serverUpdatedAt),
    );
  }

  factory SavingsEntryRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsEntryRow(
      id: serializer.fromJson<String>(json['id']),
      savingsGoalId: serializer.fromJson<String>(json['savingsGoalId']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      userId: serializer.fromJson<String?>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<int>(json['amount']),
      entryDate: serializer.fromJson<String>(json['entryDate']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'savingsGoalId': serializer.toJson<String>(savingsGoalId),
      'spaceId': serializer.toJson<String>(spaceId),
      'userId': serializer.toJson<String?>(userId),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<int>(amount),
      'entryDate': serializer.toJson<String>(entryDate),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'serverUpdatedAt': serializer.toJson<String?>(serverUpdatedAt),
    };
  }

  SavingsEntryRow copyWith({
    String? id,
    String? savingsGoalId,
    String? spaceId,
    Value<String?> userId = const Value.absent(),
    String? type,
    int? amount,
    String? entryDate,
    Value<String?> note = const Value.absent(),
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> serverUpdatedAt = const Value.absent(),
  }) => SavingsEntryRow(
    id: id ?? this.id,
    savingsGoalId: savingsGoalId ?? this.savingsGoalId,
    spaceId: spaceId ?? this.spaceId,
    userId: userId.present ? userId.value : this.userId,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    entryDate: entryDate ?? this.entryDate,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverUpdatedAt: serverUpdatedAt.present ? serverUpdatedAt.value : this.serverUpdatedAt,
  );
  SavingsEntryRow copyWithCompanion(SavingsEntriesCompanion data) {
    return SavingsEntryRow(
      id: data.id.present ? data.id.value : this.id,
      savingsGoalId: data.savingsGoalId.present ? data.savingsGoalId.value : this.savingsGoalId,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverUpdatedAt: data.serverUpdatedAt.present ? data.serverUpdatedAt.value : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsEntryRow(')
          ..write('id: $id, ')
          ..write('savingsGoalId: $savingsGoalId, ')
          ..write('spaceId: $spaceId, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('entryDate: $entryDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    savingsGoalId,
    spaceId,
    userId,
    type,
    amount,
    entryDate,
    note,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsEntryRow &&
          other.id == this.id &&
          other.savingsGoalId == this.savingsGoalId &&
          other.spaceId == this.spaceId &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.entryDate == this.entryDate &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class SavingsEntriesCompanion extends UpdateCompanion<SavingsEntryRow> {
  final Value<String> id;
  final Value<String> savingsGoalId;
  final Value<String> spaceId;
  final Value<String?> userId;
  final Value<String> type;
  final Value<int> amount;
  final Value<String> entryDate;
  final Value<String?> note;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> serverUpdatedAt;
  final Value<int> rowid;
  const SavingsEntriesCompanion({
    this.id = const Value.absent(),
    this.savingsGoalId = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingsEntriesCompanion.insert({
    required String id,
    required String savingsGoalId,
    required String spaceId,
    this.userId = const Value.absent(),
    required String type,
    required int amount,
    required String entryDate,
    this.note = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       savingsGoalId = Value(savingsGoalId),
       spaceId = Value(spaceId),
       type = Value(type),
       amount = Value(amount),
       entryDate = Value(entryDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SavingsEntryRow> custom({
    Expression<String>? id,
    Expression<String>? savingsGoalId,
    Expression<String>? spaceId,
    Expression<String>? userId,
    Expression<String>? type,
    Expression<int>? amount,
    Expression<String>? entryDate,
    Expression<String>? note,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (savingsGoalId != null) 'savings_goal_id': savingsGoalId,
      if (spaceId != null) 'space_id': spaceId,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (entryDate != null) 'entry_date': entryDate,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingsEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? savingsGoalId,
    Value<String>? spaceId,
    Value<String?>? userId,
    Value<String>? type,
    Value<int>? amount,
    Value<String>? entryDate,
    Value<String?>? note,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return SavingsEntriesCompanion(
      id: id ?? this.id,
      savingsGoalId: savingsGoalId ?? this.savingsGoalId,
      spaceId: spaceId ?? this.spaceId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      entryDate: entryDate ?? this.entryDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (savingsGoalId.present) {
      map['savings_goal_id'] = Variable<String>(savingsGoalId.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<String>(entryDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsEntriesCompanion(')
          ..write('id: $id, ')
          ..write('savingsGoalId: $savingsGoalId, ')
          ..write('spaceId: $spaceId, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('entryDate: $entryDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SpecialDatesTable extends SpecialDates with TableInfo<$SpecialDatesTable, SpecialDateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpecialDatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta('spaceId');
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<String> serverUpdatedAt = GeneratedColumn<String>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    type,
    title,
    date,
    createdBy,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'special_dates';
  @override
  VerificationContext validateIntegrity(Insertable<SpecialDateRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(_spaceIdMeta, spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta));
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta, createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(data['server_updated_at']!, _serverUpdatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpecialDateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpecialDateRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      spaceId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}space_id'])!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      date: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      createdBy: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $SpecialDatesTable createAlias(String alias) {
    return $SpecialDatesTable(attachedDatabase, alias);
  }
}

class SpecialDateRow extends DataClass implements Insertable<SpecialDateRow> {
  final String id;
  final String spaceId;
  final String type;
  final String title;

  /// `YYYY-MM-DD`, atau `--MM-DD` kalau tahunnya tidak diketahui.
  final String date;
  final String? createdBy;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? serverUpdatedAt;
  const SpecialDateRow({
    required this.id,
    required this.spaceId,
    required this.type,
    required this.title,
    required this.date,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt);
    }
    return map;
  }

  SpecialDatesCompanion toCompanion(bool nullToAbsent) {
    return SpecialDatesCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      type: Value(type),
      title: Value(title),
      date: Value(date),
      createdBy: createdBy == null && nullToAbsent ? const Value.absent() : Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent ? const Value.absent() : Value(serverUpdatedAt),
    );
  }

  factory SpecialDateRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpecialDateRow(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<String>(json['date']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<String>(date),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'serverUpdatedAt': serializer.toJson<String?>(serverUpdatedAt),
    };
  }

  SpecialDateRow copyWith({
    String? id,
    String? spaceId,
    String? type,
    String? title,
    String? date,
    Value<String?> createdBy = const Value.absent(),
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> serverUpdatedAt = const Value.absent(),
  }) => SpecialDateRow(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    type: type ?? this.type,
    title: title ?? this.title,
    date: date ?? this.date,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverUpdatedAt: serverUpdatedAt.present ? serverUpdatedAt.value : this.serverUpdatedAt,
  );
  SpecialDateRow copyWithCompanion(SpecialDatesCompanion data) {
    return SpecialDateRow(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverUpdatedAt: data.serverUpdatedAt.present ? data.serverUpdatedAt.value : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpecialDateRow(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, spaceId, type, title, date, createdBy, createdAt, updatedAt, deletedAt, serverUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpecialDateRow &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.type == this.type &&
          other.title == this.title &&
          other.date == this.date &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class SpecialDatesCompanion extends UpdateCompanion<SpecialDateRow> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> type;
  final Value<String> title;
  final Value<String> date;
  final Value<String?> createdBy;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> serverUpdatedAt;
  final Value<int> rowid;
  const SpecialDatesCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpecialDatesCompanion.insert({
    required String id,
    required String spaceId,
    required String type,
    required String title,
    required String date,
    this.createdBy = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spaceId = Value(spaceId),
       type = Value(type),
       title = Value(title),
       date = Value(date),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SpecialDateRow> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? date,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpecialDatesCompanion copyWith({
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? type,
    Value<String>? title,
    Value<String>? date,
    Value<String?>? createdBy,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return SpecialDatesCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      type: type ?? this.type,
      title: title ?? this.title,
      date: date ?? this.date,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpecialDatesCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripsTable extends Trips with TableInfo<$TripsTable, TripRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta('spaceId');
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationMeta = const VerificationMeta('destination');
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
    'destination',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _savingsGoalIdMeta = const VerificationMeta('savingsGoalId');
  @override
  late final GeneratedColumn<String> savingsGoalId = GeneratedColumn<String>(
    'savings_goal_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<String> serverUpdatedAt = GeneratedColumn<String>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    title,
    destination,
    startDate,
    endDate,
    notes,
    savingsGoalId,
    createdBy,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(Insertable<TripRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('space_id')) {
      context.handle(_spaceIdMeta, spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta));
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('destination')) {
      context.handle(_destinationMeta, destination.isAcceptableOrUnknown(data['destination']!, _destinationMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta, startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta, endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('savings_goal_id')) {
      context.handle(
        _savingsGoalIdMeta,
        savingsGoalId.isAcceptableOrUnknown(data['savings_goal_id']!, _savingsGoalIdMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta, createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(data['server_updated_at']!, _serverUpdatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      spaceId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}space_id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      destination: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}destination']),
      startDate: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}start_date']),
      endDate: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}end_date']),
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes']),
      savingsGoalId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}savings_goal_id']),
      createdBy: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }
}

class TripRow extends DataClass implements Insertable<TripRow> {
  final String id;
  final String spaceId;
  final String title;
  final String? destination;

  /// `YYYY-MM-DD`; kosong berarti tanggalnya belum pasti.
  final String? startDate;
  final String? endDate;
  final String? notes;
  final String? savingsGoalId;
  final String? createdBy;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? serverUpdatedAt;
  const TripRow({
    required this.id,
    required this.spaceId,
    required this.title,
    this.destination,
    this.startDate,
    this.endDate,
    this.notes,
    this.savingsGoalId,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || destination != null) {
      map['destination'] = Variable<String>(destination);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<String>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || savingsGoalId != null) {
      map['savings_goal_id'] = Variable<String>(savingsGoalId);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt);
    }
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      title: Value(title),
      destination: destination == null && nullToAbsent ? const Value.absent() : Value(destination),
      startDate: startDate == null && nullToAbsent ? const Value.absent() : Value(startDate),
      endDate: endDate == null && nullToAbsent ? const Value.absent() : Value(endDate),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      savingsGoalId: savingsGoalId == null && nullToAbsent ? const Value.absent() : Value(savingsGoalId),
      createdBy: createdBy == null && nullToAbsent ? const Value.absent() : Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent ? const Value.absent() : Value(serverUpdatedAt),
    );
  }

  factory TripRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripRow(
      id: serializer.fromJson<String>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      title: serializer.fromJson<String>(json['title']),
      destination: serializer.fromJson<String?>(json['destination']),
      startDate: serializer.fromJson<String?>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      savingsGoalId: serializer.fromJson<String?>(json['savingsGoalId']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      serverUpdatedAt: serializer.fromJson<String?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'title': serializer.toJson<String>(title),
      'destination': serializer.toJson<String?>(destination),
      'startDate': serializer.toJson<String?>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
      'notes': serializer.toJson<String?>(notes),
      'savingsGoalId': serializer.toJson<String?>(savingsGoalId),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'serverUpdatedAt': serializer.toJson<String?>(serverUpdatedAt),
    };
  }

  TripRow copyWith({
    String? id,
    String? spaceId,
    String? title,
    Value<String?> destination = const Value.absent(),
    Value<String?> startDate = const Value.absent(),
    Value<String?> endDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> savingsGoalId = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> serverUpdatedAt = const Value.absent(),
  }) => TripRow(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    title: title ?? this.title,
    destination: destination.present ? destination.value : this.destination,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    notes: notes.present ? notes.value : this.notes,
    savingsGoalId: savingsGoalId.present ? savingsGoalId.value : this.savingsGoalId,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverUpdatedAt: serverUpdatedAt.present ? serverUpdatedAt.value : this.serverUpdatedAt,
  );
  TripRow copyWithCompanion(TripsCompanion data) {
    return TripRow(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      title: data.title.present ? data.title.value : this.title,
      destination: data.destination.present ? data.destination.value : this.destination,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      savingsGoalId: data.savingsGoalId.present ? data.savingsGoalId.value : this.savingsGoalId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverUpdatedAt: data.serverUpdatedAt.present ? data.serverUpdatedAt.value : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripRow(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('title: $title, ')
          ..write('destination: $destination, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('notes: $notes, ')
          ..write('savingsGoalId: $savingsGoalId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    spaceId,
    title,
    destination,
    startDate,
    endDate,
    notes,
    savingsGoalId,
    createdBy,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripRow &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.title == this.title &&
          other.destination == this.destination &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.notes == this.notes &&
          other.savingsGoalId == this.savingsGoalId &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class TripsCompanion extends UpdateCompanion<TripRow> {
  final Value<String> id;
  final Value<String> spaceId;
  final Value<String> title;
  final Value<String?> destination;
  final Value<String?> startDate;
  final Value<String?> endDate;
  final Value<String?> notes;
  final Value<String?> savingsGoalId;
  final Value<String?> createdBy;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> serverUpdatedAt;
  final Value<int> rowid;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.title = const Value.absent(),
    this.destination = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.savingsGoalId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    required String id,
    required String spaceId,
    required String title,
    this.destination = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.savingsGoalId = const Value.absent(),
    this.createdBy = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spaceId = Value(spaceId),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TripRow> custom({
    Expression<String>? id,
    Expression<String>? spaceId,
    Expression<String>? title,
    Expression<String>? destination,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<String>? notes,
    Expression<String>? savingsGoalId,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (title != null) 'title': title,
      if (destination != null) 'destination': destination,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (notes != null) 'notes': notes,
      if (savingsGoalId != null) 'savings_goal_id': savingsGoalId,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCompanion copyWith({
    Value<String>? id,
    Value<String>? spaceId,
    Value<String>? title,
    Value<String?>? destination,
    Value<String?>? startDate,
    Value<String?>? endDate,
    Value<String?>? notes,
    Value<String?>? savingsGoalId,
    Value<String?>? createdBy,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      savingsGoalId: savingsGoalId ?? this.savingsGoalId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (savingsGoalId.present) {
      map['savings_goal_id'] = Variable<String>(savingsGoalId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<String>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('title: $title, ')
          ..write('destination: $destination, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('notes: $notes, ')
          ..write('savingsGoalId: $savingsGoalId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxOpsTable extends OutboxOps with TableInfo<$OutboxOpsTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _beforeMeta = const VerificationMeta('before');
  @override
  late final GeneratedColumn<String> before = GeneratedColumn<String>(
    'before',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptedMeta = const VerificationMeta('attempted');
  @override
  late final GeneratedColumn<bool> attempted = GeneratedColumn<bool>(
    'attempted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("attempted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _holdUntilMeta = const VerificationMeta('holdUntil');
  @override
  late final GeneratedColumn<int> holdUntil = GeneratedColumn<int>(
    'hold_until',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    method,
    payload,
    before,
    attempted,
    holdUntil,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_ops';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(_entityTypeMeta, entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta, entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta, method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta, payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    }
    if (data.containsKey('before')) {
      context.handle(_beforeMeta, before.isAcceptableOrUnknown(data['before']!, _beforeMeta));
    }
    if (data.containsKey('attempted')) {
      context.handle(_attemptedMeta, attempted.isAcceptableOrUnknown(data['attempted']!, _attemptedMeta));
    }
    if (data.containsKey('hold_until')) {
      context.handle(_holdUntilMeta, holdUntil.isAcceptableOrUnknown(data['hold_until']!, _holdUntilMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      method: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      payload: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}payload']),
      before: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}before']),
      attempted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}attempted'])!,
      holdUntil: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}hold_until']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OutboxOpsTable createAlias(String alias) {
    return $OutboxOpsTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final int id;
  final String entityType;
  final String entityId;

  /// `PUT`, `PATCH`, atau `DELETE`.
  final String method;

  /// JSON body request; kosong untuk `DELETE`.
  final String? payload;

  /// JSON nilai kolom sebelum diubah (yang paling awal), untuk Urungkan.
  final String? before;

  /// Ditandai sebelum dikirim. Operasi yang pernah dikirim tidak boleh digabung lagi.
  final bool attempted;

  /// Milidetik epoch; selama belum lewat, operasi menunggu tombol Urungkan.
  final int? holdUntil;
  final int createdAt;
  const OutboxRow({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.method,
    this.payload,
    this.before,
    required this.attempted,
    this.holdUntil,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['method'] = Variable<String>(method);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    if (!nullToAbsent || before != null) {
      map['before'] = Variable<String>(before);
    }
    map['attempted'] = Variable<bool>(attempted);
    if (!nullToAbsent || holdUntil != null) {
      map['hold_until'] = Variable<int>(holdUntil);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  OutboxOpsCompanion toCompanion(bool nullToAbsent) {
    return OutboxOpsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      method: Value(method),
      payload: payload == null && nullToAbsent ? const Value.absent() : Value(payload),
      before: before == null && nullToAbsent ? const Value.absent() : Value(before),
      attempted: Value(attempted),
      holdUntil: holdUntil == null && nullToAbsent ? const Value.absent() : Value(holdUntil),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      method: serializer.fromJson<String>(json['method']),
      payload: serializer.fromJson<String?>(json['payload']),
      before: serializer.fromJson<String?>(json['before']),
      attempted: serializer.fromJson<bool>(json['attempted']),
      holdUntil: serializer.fromJson<int?>(json['holdUntil']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'method': serializer.toJson<String>(method),
      'payload': serializer.toJson<String?>(payload),
      'before': serializer.toJson<String?>(before),
      'attempted': serializer.toJson<bool>(attempted),
      'holdUntil': serializer.toJson<int?>(holdUntil),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  OutboxRow copyWith({
    int? id,
    String? entityType,
    String? entityId,
    String? method,
    Value<String?> payload = const Value.absent(),
    Value<String?> before = const Value.absent(),
    bool? attempted,
    Value<int?> holdUntil = const Value.absent(),
    int? createdAt,
  }) => OutboxRow(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    method: method ?? this.method,
    payload: payload.present ? payload.value : this.payload,
    before: before.present ? before.value : this.before,
    attempted: attempted ?? this.attempted,
    holdUntil: holdUntil.present ? holdUntil.value : this.holdUntil,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxRow copyWithCompanion(OutboxOpsCompanion data) {
    return OutboxRow(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      method: data.method.present ? data.method.value : this.method,
      payload: data.payload.present ? data.payload.value : this.payload,
      before: data.before.present ? data.before.value : this.before,
      attempted: data.attempted.present ? data.attempted.value : this.attempted,
      holdUntil: data.holdUntil.present ? data.holdUntil.value : this.holdUntil,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('method: $method, ')
          ..write('payload: $payload, ')
          ..write('before: $before, ')
          ..write('attempted: $attempted, ')
          ..write('holdUntil: $holdUntil, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, entityId, method, payload, before, attempted, holdUntil, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.method == this.method &&
          other.payload == this.payload &&
          other.before == this.before &&
          other.attempted == this.attempted &&
          other.holdUntil == this.holdUntil &&
          other.createdAt == this.createdAt);
}

class OutboxOpsCompanion extends UpdateCompanion<OutboxRow> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> method;
  final Value<String?> payload;
  final Value<String?> before;
  final Value<bool> attempted;
  final Value<int?> holdUntil;
  final Value<int> createdAt;
  const OutboxOpsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.method = const Value.absent(),
    this.payload = const Value.absent(),
    this.before = const Value.absent(),
    this.attempted = const Value.absent(),
    this.holdUntil = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxOpsCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required String method,
    this.payload = const Value.absent(),
    this.before = const Value.absent(),
    this.attempted = const Value.absent(),
    this.holdUntil = const Value.absent(),
    required int createdAt,
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       method = Value(method),
       createdAt = Value(createdAt);
  static Insertable<OutboxRow> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? method,
    Expression<String>? payload,
    Expression<String>? before,
    Expression<bool>? attempted,
    Expression<int>? holdUntil,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (method != null) 'method': method,
      if (payload != null) 'payload': payload,
      if (before != null) 'before': before,
      if (attempted != null) 'attempted': attempted,
      if (holdUntil != null) 'hold_until': holdUntil,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxOpsCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? method,
    Value<String?>? payload,
    Value<String?>? before,
    Value<bool>? attempted,
    Value<int?>? holdUntil,
    Value<int>? createdAt,
  }) {
    return OutboxOpsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      method: method ?? this.method,
      payload: payload ?? this.payload,
      before: before ?? this.before,
      attempted: attempted ?? this.attempted,
      holdUntil: holdUntil ?? this.holdUntil,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (before.present) {
      map['before'] = Variable<String>(before.value);
    }
    if (attempted.present) {
      map['attempted'] = Variable<bool>(attempted.value);
    }
    if (holdUntil.present) {
      map['hold_until'] = Variable<int>(holdUntil.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxOpsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('method: $method, ')
          ..write('payload: $payload, ')
          ..write('before: $before, ')
          ..write('attempted: $attempted, ')
          ..write('holdUntil: $holdUntil, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MetaEntriesTable extends MetaEntries with TableInfo<$MetaEntriesTable, MetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta_entries';
  @override
  VerificationContext validateIntegrity(Insertable<MetaRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaRow(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $MetaEntriesTable createAlias(String alias) {
    return $MetaEntriesTable(attachedDatabase, alias);
  }
}

class MetaRow extends DataClass implements Insertable<MetaRow> {
  final String key;
  final String value;
  const MetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaEntriesCompanion toCompanion(bool nullToAbsent) {
    return MetaEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory MetaRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaRow(key: serializer.fromJson<String>(json['key']), value: serializer.fromJson<String>(json['value']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key), 'value': serializer.toJson<String>(value)};
  }

  MetaRow copyWith({String? key, String? value}) => MetaRow(key: key ?? this.key, value: value ?? this.value);
  MetaRow copyWithCompanion(MetaEntriesCompanion data) {
    return MetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MetaRow && other.key == this.key && other.value == this.value);
}

class MetaEntriesCompanion extends UpdateCompanion<MetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetaEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaEntriesCompanion.insert({required String key, required String value, this.rowid = const Value.absent()})
    : key = Value(key),
      value = Value(value);
  static Insertable<MetaRow> custom({Expression<String>? key, Expression<String>? value, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaEntriesCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return MetaEntriesCompanion(key: key ?? this.key, value: value ?? this.value, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SpacesTable spaces = $SpacesTable(this);
  late final $TaskListsTable taskLists = $TaskListsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $SavingsGoalsTable savingsGoals = $SavingsGoalsTable(this);
  late final $SavingsEntriesTable savingsEntries = $SavingsEntriesTable(this);
  late final $SpecialDatesTable specialDates = $SpecialDatesTable(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $OutboxOpsTable outboxOps = $OutboxOpsTable(this);
  late final $MetaEntriesTable metaEntries = $MetaEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    spaces,
    taskLists,
    tasks,
    savingsGoals,
    savingsEntries,
    specialDates,
    trips,
    outboxOps,
    metaEntries,
  ];
}

typedef $$SpacesTableCreateCompanionBuilder = SpacesCompanion Function({
  required String id,
  required String name,
  required String type,
  required String timezone,
  required String ownerId,
  required String members,
  required String createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<String?> serverUpdatedAt,
  Value<int> rowid,
});
typedef $$SpacesTableUpdateCompanionBuilder = SpacesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> type,
  Value<String> timezone,
  Value<String> ownerId,
  Value<String> members,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<String?> serverUpdatedAt,
  Value<int> rowid,
});

class $$SpacesTableFilterComposer extends Composer<_$AppDatabase, $SpacesTable> {
  $$SpacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get members =>
      $composableBuilder(column: $table.members, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => ColumnFilters(column));
}

class $$SpacesTableOrderingComposer extends Composer<_$AppDatabase, $SpacesTable> {
  $$SpacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get members =>
      $composableBuilder(column: $table.members, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SpacesTableAnnotationComposer extends Composer<_$AppDatabase, $SpacesTable> {
  $$SpacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type => $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get timezone => $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get ownerId => $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get members => $composableBuilder(column: $table.members, builder: (column) => column);

  GeneratedColumn<String> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => column);
}

class $$SpacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpacesTable,
          SpaceRow,
          $$SpacesTableFilterComposer,
          $$SpacesTableOrderingComposer,
          $$SpacesTableAnnotationComposer,
          $$SpacesTableCreateCompanionBuilder,
          $$SpacesTableUpdateCompanionBuilder,
          (SpaceRow, BaseReferences<_$AppDatabase, $SpacesTable, SpaceRow>),
          SpaceRow,
          PrefetchHooks Function()
        > {
  $$SpacesTableTableManager(_$AppDatabase db, $SpacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SpacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SpacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SpacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> members = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpacesCompanion(
                id: id,
                name: name,
                type: type,
                timezone: timezone,
                ownerId: ownerId,
                members: members,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                required String timezone,
                required String ownerId,
                required String members,
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpacesCompanion.insert(
                id: id,
                name: name,
                type: type,
                timezone: timezone,
                ownerId: ownerId,
                members: members,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SpacesTable, SpaceRow>(table),
                  BaseReferences<_$AppDatabase, $SpacesTable, SpaceRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpacesTable,
      SpaceRow,
      $$SpacesTableFilterComposer,
      $$SpacesTableOrderingComposer,
      $$SpacesTableAnnotationComposer,
      $$SpacesTableCreateCompanionBuilder,
      $$SpacesTableUpdateCompanionBuilder,
      (SpaceRow, BaseReferences<_$AppDatabase, $SpacesTable, SpaceRow>),
      SpaceRow,
      PrefetchHooks Function()
    >;
typedef $$TaskListsTableCreateCompanionBuilder = TaskListsCompanion Function({
  required String id,
  required String spaceId,
  required String name,
  Value<String?> emoji,
  required String color,
  required double position,
  Value<String?> archivedAt,
  Value<String?> tripId,
  Value<String?> createdBy,
  required String createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<String?> serverUpdatedAt,
  Value<int> rowid,
});
typedef $$TaskListsTableUpdateCompanionBuilder = TaskListsCompanion Function({
  Value<String> id,
  Value<String> spaceId,
  Value<String> name,
  Value<String?> emoji,
  Value<String> color,
  Value<double> position,
  Value<String?> archivedAt,
  Value<String?> tripId,
  Value<String?> createdBy,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<String?> serverUpdatedAt,
  Value<int> rowid,
});

class $$TaskListsTableFilterComposer extends Composer<_$AppDatabase, $TaskListsTable> {
  $$TaskListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get spaceId =>
      $composableBuilder(column: $table.spaceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get archivedAt =>
      $composableBuilder(column: $table.archivedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => ColumnFilters(column));
}

class $$TaskListsTableOrderingComposer extends Composer<_$AppDatabase, $TaskListsTable> {
  $$TaskListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get spaceId =>
      $composableBuilder(column: $table.spaceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get archivedAt =>
      $composableBuilder(column: $table.archivedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TaskListsTableAnnotationComposer extends Composer<_$AppDatabase, $TaskListsTable> {
  $$TaskListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get spaceId => $composableBuilder(column: $table.spaceId, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji => $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get color => $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<double> get position => $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get archivedAt => $composableBuilder(column: $table.archivedAt, builder: (column) => column);

  GeneratedColumn<String> get tripId => $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get createdBy => $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => column);
}

class $$TaskListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskListsTable,
          TaskListRow,
          $$TaskListsTableFilterComposer,
          $$TaskListsTableOrderingComposer,
          $$TaskListsTableAnnotationComposer,
          $$TaskListsTableCreateCompanionBuilder,
          $$TaskListsTableUpdateCompanionBuilder,
          (TaskListRow, BaseReferences<_$AppDatabase, $TaskListsTable, TaskListRow>),
          TaskListRow,
          PrefetchHooks Function()
        > {
  $$TaskListsTableTableManager(_$AppDatabase db, $TaskListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TaskListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TaskListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TaskListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> emoji = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<double> position = const Value.absent(),
                Value<String?> archivedAt = const Value.absent(),
                Value<String?> tripId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskListsCompanion(
                id: id,
                spaceId: spaceId,
                name: name,
                emoji: emoji,
                color: color,
                position: position,
                archivedAt: archivedAt,
                tripId: tripId,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spaceId,
                required String name,
                Value<String?> emoji = const Value.absent(),
                required String color,
                required double position,
                Value<String?> archivedAt = const Value.absent(),
                Value<String?> tripId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskListsCompanion.insert(
                id: id,
                spaceId: spaceId,
                name: name,
                emoji: emoji,
                color: color,
                position: position,
                archivedAt: archivedAt,
                tripId: tripId,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TaskListsTable, TaskListRow>(table),
                  BaseReferences<_$AppDatabase, $TaskListsTable, TaskListRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskListsTable,
      TaskListRow,
      $$TaskListsTableFilterComposer,
      $$TaskListsTableOrderingComposer,
      $$TaskListsTableAnnotationComposer,
      $$TaskListsTableCreateCompanionBuilder,
      $$TaskListsTableUpdateCompanionBuilder,
      (TaskListRow, BaseReferences<_$AppDatabase, $TaskListsTable, TaskListRow>),
      TaskListRow,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String taskListId,
  required String spaceId,
  required String title,
  Value<String?> notes,
  Value<String?> dueDate,
  Value<String?> dueTime,
  required int priority,
  required double position,
  required String assigneeIds,
  Value<String?> remindAt,
  Value<String?> completedAt,
  Value<String?> completedBy,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  required String createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<String?> serverUpdatedAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> taskListId,
  Value<String> spaceId,
  Value<String> title,
  Value<String?> notes,
  Value<String?> dueDate,
  Value<String?> dueTime,
  Value<int> priority,
  Value<double> position,
  Value<String> assigneeIds,
  Value<String?> remindAt,
  Value<String?> completedAt,
  Value<String?> completedBy,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<String?> serverUpdatedAt,
  Value<int> rowid,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskListId =>
      $composableBuilder(column: $table.taskListId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get spaceId =>
      $composableBuilder(column: $table.spaceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dueTime =>
      $composableBuilder(column: $table.dueTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assigneeIds =>
      $composableBuilder(column: $table.assigneeIds, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remindAt =>
      $composableBuilder(column: $table.remindAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get completedBy =>
      $composableBuilder(column: $table.completedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => ColumnFilters(column));
}

class $$TasksTableOrderingComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskListId =>
      $composableBuilder(column: $table.taskListId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get spaceId =>
      $composableBuilder(column: $table.spaceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dueTime =>
      $composableBuilder(column: $table.dueTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assigneeIds =>
      $composableBuilder(column: $table.assigneeIds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remindAt =>
      $composableBuilder(column: $table.remindAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get completedBy =>
      $composableBuilder(column: $table.completedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TasksTableAnnotationComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskListId => $composableBuilder(column: $table.taskListId, builder: (column) => column);

  GeneratedColumn<String> get spaceId => $composableBuilder(column: $table.spaceId, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get dueDate => $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get dueTime => $composableBuilder(column: $table.dueTime, builder: (column) => column);

  GeneratedColumn<int> get priority => $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<double> get position => $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get assigneeIds =>
      $composableBuilder(column: $table.assigneeIds, builder: (column) => column);

  GeneratedColumn<String> get remindAt => $composableBuilder(column: $table.remindAt, builder: (column) => column);

  GeneratedColumn<String> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get completedBy =>
      $composableBuilder(column: $table.completedBy, builder: (column) => column);

  GeneratedColumn<String> get createdBy => $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedBy => $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          TaskRow,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
          TaskRow,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskListId = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> dueDate = const Value.absent(),
                Value<String?> dueTime = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<double> position = const Value.absent(),
                Value<String> assigneeIds = const Value.absent(),
                Value<String?> remindAt = const Value.absent(),
                Value<String?> completedAt = const Value.absent(),
                Value<String?> completedBy = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                taskListId: taskListId,
                spaceId: spaceId,
                title: title,
                notes: notes,
                dueDate: dueDate,
                dueTime: dueTime,
                priority: priority,
                position: position,
                assigneeIds: assigneeIds,
                remindAt: remindAt,
                completedAt: completedAt,
                completedBy: completedBy,
                createdBy: createdBy,
                updatedBy: updatedBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskListId,
                required String spaceId,
                required String title,
                Value<String?> notes = const Value.absent(),
                Value<String?> dueDate = const Value.absent(),
                Value<String?> dueTime = const Value.absent(),
                required int priority,
                required double position,
                required String assigneeIds,
                Value<String?> remindAt = const Value.absent(),
                Value<String?> completedAt = const Value.absent(),
                Value<String?> completedBy = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                taskListId: taskListId,
                spaceId: spaceId,
                title: title,
                notes: notes,
                dueDate: dueDate,
                dueTime: dueTime,
                priority: priority,
                position: position,
                assigneeIds: assigneeIds,
                remindAt: remindAt,
                completedAt: completedAt,
                completedBy: completedBy,
                createdBy: createdBy,
                updatedBy: updatedBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, TaskRow>(table),
                  BaseReferences<_$AppDatabase, $TasksTable, TaskRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      TaskRow,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
      TaskRow,
      PrefetchHooks Function()
    >;
typedef $$SavingsGoalsTableCreateCompanionBuilder = SavingsGoalsCompanion Function({
  required String id,
  required String spaceId,
  required String name,
  Value<String?> emoji,
  required int targetAmount,
  required String currency,
  Value<String?> targetDate,
  Value<String?> reminderFrequency,
  Value<int?> reminderDay,
  Value<String?> achievedAt,
  Value<String?> archivedAt,
  Value<String?> createdBy,
  required String createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<String?> serverUpdatedAt,
  Value<int> rowid,
});
typedef $$SavingsGoalsTableUpdateCompanionBuilder = SavingsGoalsCompanion Function({
  Value<String> id,
  Value<String> spaceId,
  Value<String> name,
  Value<String?> emoji,
  Value<int> targetAmount,
  Value<String> currency,
  Value<String?> targetDate,
  Value<String?> reminderFrequency,
  Value<int?> reminderDay,
  Value<String?> achievedAt,
  Value<String?> archivedAt,
  Value<String?> createdBy,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<String?> serverUpdatedAt,
  Value<int> rowid,
});

class $$SavingsGoalsTableFilterComposer extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get spaceId =>
      $composableBuilder(column: $table.spaceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetAmount =>
      $composableBuilder(column: $table.targetAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetDate =>
      $composableBuilder(column: $table.targetDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderFrequency =>
      $composableBuilder(column: $table.reminderFrequency, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reminderDay =>
      $composableBuilder(column: $table.reminderDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get achievedAt =>
      $composableBuilder(column: $table.achievedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get archivedAt =>
      $composableBuilder(column: $table.archivedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => ColumnFilters(column));
}

class $$SavingsGoalsTableOrderingComposer extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get spaceId =>
      $composableBuilder(column: $table.spaceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetAmount =>
      $composableBuilder(column: $table.targetAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetDate =>
      $composableBuilder(column: $table.targetDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderFrequency =>
      $composableBuilder(column: $table.reminderFrequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderDay =>
      $composableBuilder(column: $table.reminderDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get achievedAt =>
      $composableBuilder(column: $table.achievedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get archivedAt =>
      $composableBuilder(column: $table.archivedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SavingsGoalsTableAnnotationComposer extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get spaceId => $composableBuilder(column: $table.spaceId, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji => $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<int> get targetAmount => $composableBuilder(column: $table.targetAmount, builder: (column) => column);

  GeneratedColumn<String> get currency => $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get targetDate => $composableBuilder(column: $table.targetDate, builder: (column) => column);

  GeneratedColumn<String> get reminderFrequency =>
      $composableBuilder(column: $table.reminderFrequency, builder: (column) => column);

  GeneratedColumn<int> get reminderDay => $composableBuilder(column: $table.reminderDay, builder: (column) => column);

  GeneratedColumn<String> get achievedAt => $composableBuilder(column: $table.achievedAt, builder: (column) => column);

  GeneratedColumn<String> get archivedAt => $composableBuilder(column: $table.archivedAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy => $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => column);
}

class $$SavingsGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingsGoalsTable,
          SavingsGoalRow,
          $$SavingsGoalsTableFilterComposer,
          $$SavingsGoalsTableOrderingComposer,
          $$SavingsGoalsTableAnnotationComposer,
          $$SavingsGoalsTableCreateCompanionBuilder,
          $$SavingsGoalsTableUpdateCompanionBuilder,
          (SavingsGoalRow, BaseReferences<_$AppDatabase, $SavingsGoalsTable, SavingsGoalRow>),
          SavingsGoalRow,
          PrefetchHooks Function()
        > {
  $$SavingsGoalsTableTableManager(_$AppDatabase db, $SavingsGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SavingsGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SavingsGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SavingsGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> emoji = const Value.absent(),
                Value<int> targetAmount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> targetDate = const Value.absent(),
                Value<String?> reminderFrequency = const Value.absent(),
                Value<int?> reminderDay = const Value.absent(),
                Value<String?> achievedAt = const Value.absent(),
                Value<String?> archivedAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalsCompanion(
                id: id,
                spaceId: spaceId,
                name: name,
                emoji: emoji,
                targetAmount: targetAmount,
                currency: currency,
                targetDate: targetDate,
                reminderFrequency: reminderFrequency,
                reminderDay: reminderDay,
                achievedAt: achievedAt,
                archivedAt: archivedAt,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spaceId,
                required String name,
                Value<String?> emoji = const Value.absent(),
                required int targetAmount,
                required String currency,
                Value<String?> targetDate = const Value.absent(),
                Value<String?> reminderFrequency = const Value.absent(),
                Value<int?> reminderDay = const Value.absent(),
                Value<String?> achievedAt = const Value.absent(),
                Value<String?> archivedAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalsCompanion.insert(
                id: id,
                spaceId: spaceId,
                name: name,
                emoji: emoji,
                targetAmount: targetAmount,
                currency: currency,
                targetDate: targetDate,
                reminderFrequency: reminderFrequency,
                reminderDay: reminderDay,
                achievedAt: achievedAt,
                archivedAt: archivedAt,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SavingsGoalsTable, SavingsGoalRow>(table),
                  BaseReferences<_$AppDatabase, $SavingsGoalsTable, SavingsGoalRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavingsGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingsGoalsTable,
      SavingsGoalRow,
      $$SavingsGoalsTableFilterComposer,
      $$SavingsGoalsTableOrderingComposer,
      $$SavingsGoalsTableAnnotationComposer,
      $$SavingsGoalsTableCreateCompanionBuilder,
      $$SavingsGoalsTableUpdateCompanionBuilder,
      (SavingsGoalRow, BaseReferences<_$AppDatabase, $SavingsGoalsTable, SavingsGoalRow>),
      SavingsGoalRow,
      PrefetchHooks Function()
    >;
typedef $$SavingsEntriesTableCreateCompanionBuilder = SavingsEntriesCompanion Function({
  required String id,
  required String savingsGoalId,
  required String spaceId,
  Value<String?> userId,
  required String type,
  required int amount,
  required String entryDate,
  Value<String?> note,
  required String createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<String?> serverUpdatedAt,
  Value<int> rowid,
});
typedef $$SavingsEntriesTableUpdateCompanionBuilder = SavingsEntriesCompanion Function({
  Value<String> id,
  Value<String> savingsGoalId,
  Value<String> spaceId,
  Value<String?> userId,
  Value<String> type,
  Value<int> amount,
  Value<String> entryDate,
  Value<String?> note,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<String?> serverUpdatedAt,
  Value<int> rowid,
});

class $$SavingsEntriesTableFilterComposer extends Composer<_$AppDatabase, $SavingsEntriesTable> {
  $$SavingsEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get savingsGoalId =>
      $composableBuilder(column: $table.savingsGoalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get spaceId =>
      $composableBuilder(column: $table.spaceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => ColumnFilters(column));
}

class $$SavingsEntriesTableOrderingComposer extends Composer<_$AppDatabase, $SavingsEntriesTable> {
  $$SavingsEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get savingsGoalId =>
      $composableBuilder(column: $table.savingsGoalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get spaceId =>
      $composableBuilder(column: $table.spaceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SavingsEntriesTableAnnotationComposer extends Composer<_$AppDatabase, $SavingsEntriesTable> {
  $$SavingsEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get savingsGoalId =>
      $composableBuilder(column: $table.savingsGoalId, builder: (column) => column);

  GeneratedColumn<String> get spaceId => $composableBuilder(column: $table.spaceId, builder: (column) => column);

  GeneratedColumn<String> get userId => $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get type => $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amount => $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get entryDate => $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get note => $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => column);
}

class $$SavingsEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingsEntriesTable,
          SavingsEntryRow,
          $$SavingsEntriesTableFilterComposer,
          $$SavingsEntriesTableOrderingComposer,
          $$SavingsEntriesTableAnnotationComposer,
          $$SavingsEntriesTableCreateCompanionBuilder,
          $$SavingsEntriesTableUpdateCompanionBuilder,
          (SavingsEntryRow, BaseReferences<_$AppDatabase, $SavingsEntriesTable, SavingsEntryRow>),
          SavingsEntryRow,
          PrefetchHooks Function()
        > {
  $$SavingsEntriesTableTableManager(_$AppDatabase db, $SavingsEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SavingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SavingsEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SavingsEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> savingsGoalId = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> entryDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsEntriesCompanion(
                id: id,
                savingsGoalId: savingsGoalId,
                spaceId: spaceId,
                userId: userId,
                type: type,
                amount: amount,
                entryDate: entryDate,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String savingsGoalId,
                required String spaceId,
                Value<String?> userId = const Value.absent(),
                required String type,
                required int amount,
                required String entryDate,
                Value<String?> note = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsEntriesCompanion.insert(
                id: id,
                savingsGoalId: savingsGoalId,
                spaceId: spaceId,
                userId: userId,
                type: type,
                amount: amount,
                entryDate: entryDate,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SavingsEntriesTable, SavingsEntryRow>(table),
                  BaseReferences<_$AppDatabase, $SavingsEntriesTable, SavingsEntryRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavingsEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingsEntriesTable,
      SavingsEntryRow,
      $$SavingsEntriesTableFilterComposer,
      $$SavingsEntriesTableOrderingComposer,
      $$SavingsEntriesTableAnnotationComposer,
      $$SavingsEntriesTableCreateCompanionBuilder,
      $$SavingsEntriesTableUpdateCompanionBuilder,
      (SavingsEntryRow, BaseReferences<_$AppDatabase, $SavingsEntriesTable, SavingsEntryRow>),
      SavingsEntryRow,
      PrefetchHooks Function()
    >;
typedef $$SpecialDatesTableCreateCompanionBuilder = SpecialDatesCompanion Function({
  required String id,
  required String spaceId,
  required String type,
  required String title,
  required String date,
  Value<String?> createdBy,
  required String createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<String?> serverUpdatedAt,
  Value<int> rowid,
});
typedef $$SpecialDatesTableUpdateCompanionBuilder = SpecialDatesCompanion Function({
  Value<String> id,
  Value<String> spaceId,
  Value<String> type,
  Value<String> title,
  Value<String> date,
  Value<String?> createdBy,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<String?> serverUpdatedAt,
  Value<int> rowid,
});

class $$SpecialDatesTableFilterComposer extends Composer<_$AppDatabase, $SpecialDatesTable> {
  $$SpecialDatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get spaceId =>
      $composableBuilder(column: $table.spaceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => ColumnFilters(column));
}

class $$SpecialDatesTableOrderingComposer extends Composer<_$AppDatabase, $SpecialDatesTable> {
  $$SpecialDatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get spaceId =>
      $composableBuilder(column: $table.spaceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SpecialDatesTableAnnotationComposer extends Composer<_$AppDatabase, $SpecialDatesTable> {
  $$SpecialDatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get spaceId => $composableBuilder(column: $table.spaceId, builder: (column) => column);

  GeneratedColumn<String> get type => $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get date => $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get createdBy => $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => column);
}

class $$SpecialDatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpecialDatesTable,
          SpecialDateRow,
          $$SpecialDatesTableFilterComposer,
          $$SpecialDatesTableOrderingComposer,
          $$SpecialDatesTableAnnotationComposer,
          $$SpecialDatesTableCreateCompanionBuilder,
          $$SpecialDatesTableUpdateCompanionBuilder,
          (SpecialDateRow, BaseReferences<_$AppDatabase, $SpecialDatesTable, SpecialDateRow>),
          SpecialDateRow,
          PrefetchHooks Function()
        > {
  $$SpecialDatesTableTableManager(_$AppDatabase db, $SpecialDatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SpecialDatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SpecialDatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SpecialDatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpecialDatesCompanion(
                id: id,
                spaceId: spaceId,
                type: type,
                title: title,
                date: date,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spaceId,
                required String type,
                required String title,
                required String date,
                Value<String?> createdBy = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpecialDatesCompanion.insert(
                id: id,
                spaceId: spaceId,
                type: type,
                title: title,
                date: date,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SpecialDatesTable, SpecialDateRow>(table),
                  BaseReferences<_$AppDatabase, $SpecialDatesTable, SpecialDateRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpecialDatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpecialDatesTable,
      SpecialDateRow,
      $$SpecialDatesTableFilterComposer,
      $$SpecialDatesTableOrderingComposer,
      $$SpecialDatesTableAnnotationComposer,
      $$SpecialDatesTableCreateCompanionBuilder,
      $$SpecialDatesTableUpdateCompanionBuilder,
      (SpecialDateRow, BaseReferences<_$AppDatabase, $SpecialDatesTable, SpecialDateRow>),
      SpecialDateRow,
      PrefetchHooks Function()
    >;
typedef $$TripsTableCreateCompanionBuilder = TripsCompanion Function({
  required String id,
  required String spaceId,
  required String title,
  Value<String?> destination,
  Value<String?> startDate,
  Value<String?> endDate,
  Value<String?> notes,
  Value<String?> savingsGoalId,
  Value<String?> createdBy,
  required String createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<String?> serverUpdatedAt,
  Value<int> rowid,
});
typedef $$TripsTableUpdateCompanionBuilder = TripsCompanion Function({
  Value<String> id,
  Value<String> spaceId,
  Value<String> title,
  Value<String?> destination,
  Value<String?> startDate,
  Value<String?> endDate,
  Value<String?> notes,
  Value<String?> savingsGoalId,
  Value<String?> createdBy,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<String?> serverUpdatedAt,
  Value<int> rowid,
});

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get spaceId =>
      $composableBuilder(column: $table.spaceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destination =>
      $composableBuilder(column: $table.destination, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get savingsGoalId =>
      $composableBuilder(column: $table.savingsGoalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => ColumnFilters(column));
}

class $$TripsTableOrderingComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get spaceId =>
      $composableBuilder(column: $table.spaceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destination =>
      $composableBuilder(column: $table.destination, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get savingsGoalId =>
      $composableBuilder(column: $table.savingsGoalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TripsTableAnnotationComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get spaceId => $composableBuilder(column: $table.spaceId, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get destination =>
      $composableBuilder(column: $table.destination, builder: (column) => column);

  GeneratedColumn<String> get startDate => $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate => $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get savingsGoalId =>
      $composableBuilder(column: $table.savingsGoalId, builder: (column) => column);

  GeneratedColumn<String> get createdBy => $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get serverUpdatedAt =>
      $composableBuilder(column: $table.serverUpdatedAt, builder: (column) => column);
}

class $$TripsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsTable,
          TripRow,
          $$TripsTableFilterComposer,
          $$TripsTableOrderingComposer,
          $$TripsTableAnnotationComposer,
          $$TripsTableCreateCompanionBuilder,
          $$TripsTableUpdateCompanionBuilder,
          (TripRow, BaseReferences<_$AppDatabase, $TripsTable, TripRow>),
          TripRow,
          PrefetchHooks Function()
        > {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> destination = const Value.absent(),
                Value<String?> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> savingsGoalId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                spaceId: spaceId,
                title: title,
                destination: destination,
                startDate: startDate,
                endDate: endDate,
                notes: notes,
                savingsGoalId: savingsGoalId,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spaceId,
                required String title,
                Value<String?> destination = const Value.absent(),
                Value<String?> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> savingsGoalId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion.insert(
                id: id,
                spaceId: spaceId,
                title: title,
                destination: destination,
                startDate: startDate,
                endDate: endDate,
                notes: notes,
                savingsGoalId: savingsGoalId,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TripsTable, TripRow>(table),
                  BaseReferences<_$AppDatabase, $TripsTable, TripRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TripsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsTable,
      TripRow,
      $$TripsTableFilterComposer,
      $$TripsTableOrderingComposer,
      $$TripsTableAnnotationComposer,
      $$TripsTableCreateCompanionBuilder,
      $$TripsTableUpdateCompanionBuilder,
      (TripRow, BaseReferences<_$AppDatabase, $TripsTable, TripRow>),
      TripRow,
      PrefetchHooks Function()
    >;
typedef $$OutboxOpsTableCreateCompanionBuilder = OutboxOpsCompanion Function({
  Value<int> id,
  required String entityType,
  required String entityId,
  required String method,
  Value<String?> payload,
  Value<String?> before,
  Value<bool> attempted,
  Value<int?> holdUntil,
  required int createdAt,
});
typedef $$OutboxOpsTableUpdateCompanionBuilder = OutboxOpsCompanion Function({
  Value<int> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> method,
  Value<String?> payload,
  Value<String?> before,
  Value<bool> attempted,
  Value<int?> holdUntil,
  Value<int> createdAt,
});

class $$OutboxOpsTableFilterComposer extends Composer<_$AppDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType =>
      $composableBuilder(column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get before =>
      $composableBuilder(column: $table.before, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get attempted =>
      $composableBuilder(column: $table.attempted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get holdUntil =>
      $composableBuilder(column: $table.holdUntil, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$OutboxOpsTableOrderingComposer extends Composer<_$AppDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType =>
      $composableBuilder(column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get before =>
      $composableBuilder(column: $table.before, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get attempted =>
      $composableBuilder(column: $table.attempted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get holdUntil =>
      $composableBuilder(column: $table.holdUntil, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OutboxOpsTableAnnotationComposer extends Composer<_$AppDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId => $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get method => $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get payload => $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get before => $composableBuilder(column: $table.before, builder: (column) => column);

  GeneratedColumn<bool> get attempted => $composableBuilder(column: $table.attempted, builder: (column) => column);

  GeneratedColumn<int> get holdUntil => $composableBuilder(column: $table.holdUntil, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxOpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxOpsTable,
          OutboxRow,
          $$OutboxOpsTableFilterComposer,
          $$OutboxOpsTableOrderingComposer,
          $$OutboxOpsTableAnnotationComposer,
          $$OutboxOpsTableCreateCompanionBuilder,
          $$OutboxOpsTableUpdateCompanionBuilder,
          (OutboxRow, BaseReferences<_$AppDatabase, $OutboxOpsTable, OutboxRow>),
          OutboxRow,
          PrefetchHooks Function()
        > {
  $$OutboxOpsTableTableManager(_$AppDatabase db, $OutboxOpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$OutboxOpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$OutboxOpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$OutboxOpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                Value<String?> before = const Value.absent(),
                Value<bool> attempted = const Value.absent(),
                Value<int?> holdUntil = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => OutboxOpsCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                method: method,
                payload: payload,
                before: before,
                attempted: attempted,
                holdUntil: holdUntil,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String entityId,
                required String method,
                Value<String?> payload = const Value.absent(),
                Value<String?> before = const Value.absent(),
                Value<bool> attempted = const Value.absent(),
                Value<int?> holdUntil = const Value.absent(),
                required int createdAt,
              }) => OutboxOpsCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                method: method,
                payload: payload,
                before: before,
                attempted: attempted,
                holdUntil: holdUntil,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxOpsTable, OutboxRow>(table),
                  BaseReferences<_$AppDatabase, $OutboxOpsTable, OutboxRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxOpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxOpsTable,
      OutboxRow,
      $$OutboxOpsTableFilterComposer,
      $$OutboxOpsTableOrderingComposer,
      $$OutboxOpsTableAnnotationComposer,
      $$OutboxOpsTableCreateCompanionBuilder,
      $$OutboxOpsTableUpdateCompanionBuilder,
      (OutboxRow, BaseReferences<_$AppDatabase, $OutboxOpsTable, OutboxRow>),
      OutboxRow,
      PrefetchHooks Function()
    >;
typedef $$MetaEntriesTableCreateCompanionBuilder = MetaEntriesCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$MetaEntriesTableUpdateCompanionBuilder = MetaEntriesCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$MetaEntriesTableFilterComposer extends Composer<_$AppDatabase, $MetaEntriesTable> {
  $$MetaEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$MetaEntriesTableOrderingComposer extends Composer<_$AppDatabase, $MetaEntriesTable> {
  $$MetaEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$MetaEntriesTableAnnotationComposer extends Composer<_$AppDatabase, $MetaEntriesTable> {
  $$MetaEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key => $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetaEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetaEntriesTable,
          MetaRow,
          $$MetaEntriesTableFilterComposer,
          $$MetaEntriesTableOrderingComposer,
          $$MetaEntriesTableAnnotationComposer,
          $$MetaEntriesTableCreateCompanionBuilder,
          $$MetaEntriesTableUpdateCompanionBuilder,
          (MetaRow, BaseReferences<_$AppDatabase, $MetaEntriesTable, MetaRow>),
          MetaRow,
          PrefetchHooks Function()
        > {
  $$MetaEntriesTableTableManager(_$AppDatabase db, $MetaEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MetaEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MetaEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$MetaEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => MetaEntriesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => MetaEntriesCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MetaEntriesTable, MetaRow>(table),
                  BaseReferences<_$AppDatabase, $MetaEntriesTable, MetaRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetaEntriesTable,
      MetaRow,
      $$MetaEntriesTableFilterComposer,
      $$MetaEntriesTableOrderingComposer,
      $$MetaEntriesTableAnnotationComposer,
      $$MetaEntriesTableCreateCompanionBuilder,
      $$MetaEntriesTableUpdateCompanionBuilder,
      (MetaRow, BaseReferences<_$AppDatabase, $MetaEntriesTable, MetaRow>),
      MetaRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SpacesTableTableManager get spaces => $$SpacesTableTableManager(_db, _db.spaces);
  $$TaskListsTableTableManager get taskLists => $$TaskListsTableTableManager(_db, _db.taskLists);
  $$TasksTableTableManager get tasks => $$TasksTableTableManager(_db, _db.tasks);
  $$SavingsGoalsTableTableManager get savingsGoals => $$SavingsGoalsTableTableManager(_db, _db.savingsGoals);
  $$SavingsEntriesTableTableManager get savingsEntries => $$SavingsEntriesTableTableManager(_db, _db.savingsEntries);
  $$SpecialDatesTableTableManager get specialDates => $$SpecialDatesTableTableManager(_db, _db.specialDates);
  $$TripsTableTableManager get trips => $$TripsTableTableManager(_db, _db.trips);
  $$OutboxOpsTableTableManager get outboxOps => $$OutboxOpsTableTableManager(_db, _db.outboxOps);
  $$MetaEntriesTableTableManager get metaEntries => $$MetaEntriesTableTableManager(_db, _db.metaEntries);
}
