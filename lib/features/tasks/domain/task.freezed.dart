// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Task {

 String get id; String get taskListId; String get spaceId; String get title; String? get notes;/// `YYYY-MM-DD` menurut zona waktu ruang.
 String? get dueDate;/// `HH:MM` menurut zona waktu ruang; butuh [dueDate].
 String? get dueTime; int get priority; double get position;/// Satu ID berarti satu orang; dua ID berarti "Kita".
 List<String> get assigneeIds; DateTime? get remindAt; DateTime? get completedAt; String? get completedBy; String? get createdBy; String? get updatedBy; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCopyWith<Task> get copyWith => _$TaskCopyWithImpl<Task>(this as Task, _$identity);

  /// Serializes this Task to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Task;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Task&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.taskListId, _this.taskListId) || other.taskListId == _this.taskListId)&&(identical(other.spaceId, _this.spaceId) || other.spaceId == _this.spaceId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.dueTime, _this.dueTime) || other.dueTime == _this.dueTime)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.position, _this.position) || other.position == _this.position)&&const DeepCollectionEquality().equals(other.assigneeIds, _this.assigneeIds)&&(identical(other.remindAt, _this.remindAt) || other.remindAt == _this.remindAt)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt)&&(identical(other.completedBy, _this.completedBy) || other.completedBy == _this.completedBy)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.updatedBy, _this.updatedBy) || other.updatedBy == _this.updatedBy)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Task;
  return Object.hash(runtimeType,_this.id,_this.taskListId,_this.spaceId,_this.title,_this.notes,_this.dueDate,_this.dueTime,_this.priority,_this.position,const DeepCollectionEquality().hash(_this.assigneeIds),_this.remindAt,_this.completedAt,_this.completedBy,_this.createdBy,_this.updatedBy,_this.createdAt,_this.updatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as Task;
  return 'Task(id: ${_this.id}, taskListId: ${_this.taskListId}, spaceId: ${_this.spaceId}, title: ${_this.title}, notes: ${_this.notes}, dueDate: ${_this.dueDate}, dueTime: ${_this.dueTime}, priority: ${_this.priority}, position: ${_this.position}, assigneeIds: ${_this.assigneeIds}, remindAt: ${_this.remindAt}, completedAt: ${_this.completedAt}, completedBy: ${_this.completedBy}, createdBy: ${_this.createdBy}, updatedBy: ${_this.updatedBy}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $TaskCopyWith<$Res>  {
  factory $TaskCopyWith(Task value, $Res Function(Task) _then) = _$TaskCopyWithImpl;
@useResult
$Res call({
 String id, String taskListId, String spaceId, String title, String? notes, String? dueDate, String? dueTime, int priority, double position, List<String> assigneeIds, DateTime? remindAt, DateTime? completedAt, String? completedBy, String? createdBy, String? updatedBy, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$TaskCopyWithImpl<$Res>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._self, this._then);

  final Task _self;
  final $Res Function(Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? taskListId = null,Object? spaceId = null,Object? title = null,Object? notes = freezed,Object? dueDate = freezed,Object? dueTime = freezed,Object? priority = null,Object? position = null,Object? assigneeIds = null,Object? remindAt = freezed,Object? completedAt = freezed,Object? completedBy = freezed,Object? createdBy = freezed,Object? updatedBy = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(Task(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,taskListId: null == taskListId ? _self.taskListId : taskListId // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String?,dueTime: freezed == dueTime ? _self.dueTime : dueTime // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as double,assigneeIds: null == assigneeIds ? _self.assigneeIds : assigneeIds // ignore: cast_nullable_to_non_nullable
as List<String>,remindAt: freezed == remindAt ? _self.remindAt : remindAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedBy: freezed == completedBy ? _self.completedBy : completedBy // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Task].
extension TaskPatterns on Task {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Task value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Task value)  $default,){
final _that = this;
switch (_that) {
case _Task():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Task value)?  $default,){
final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String taskListId,  String spaceId,  String title,  String? notes,  String? dueDate,  String? dueTime,  int priority,  double position,  List<String> assigneeIds,  DateTime? remindAt,  DateTime? completedAt,  String? completedBy,  String? createdBy,  String? updatedBy,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.taskListId,_that.spaceId,_that.title,_that.notes,_that.dueDate,_that.dueTime,_that.priority,_that.position,_that.assigneeIds,_that.remindAt,_that.completedAt,_that.completedBy,_that.createdBy,_that.updatedBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String taskListId,  String spaceId,  String title,  String? notes,  String? dueDate,  String? dueTime,  int priority,  double position,  List<String> assigneeIds,  DateTime? remindAt,  DateTime? completedAt,  String? completedBy,  String? createdBy,  String? updatedBy,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Task():
return $default(_that.id,_that.taskListId,_that.spaceId,_that.title,_that.notes,_that.dueDate,_that.dueTime,_that.priority,_that.position,_that.assigneeIds,_that.remindAt,_that.completedAt,_that.completedBy,_that.createdBy,_that.updatedBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String taskListId,  String spaceId,  String title,  String? notes,  String? dueDate,  String? dueTime,  int priority,  double position,  List<String> assigneeIds,  DateTime? remindAt,  DateTime? completedAt,  String? completedBy,  String? createdBy,  String? updatedBy,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.taskListId,_that.spaceId,_that.title,_that.notes,_that.dueDate,_that.dueTime,_that.priority,_that.position,_that.assigneeIds,_that.remindAt,_that.completedAt,_that.completedBy,_that.createdBy,_that.updatedBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Task extends Task {
  const _Task({required this.id, required this.taskListId, required this.spaceId, required this.title, this.notes, this.dueDate, this.dueTime, this.priority = priorityNone, required this.position,  List<String> assigneeIds = const <String>[], this.remindAt, this.completedAt, this.completedBy, this.createdBy, this.updatedBy, required this.createdAt, required this.updatedAt, this.deletedAt}): _assigneeIds = assigneeIds,super._();
  factory _Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

@override final  String id;
@override final  String taskListId;
@override final  String spaceId;
@override final  String title;
@override final  String? notes;
/// `YYYY-MM-DD` menurut zona waktu ruang.
@override final  String? dueDate;
/// `HH:MM` menurut zona waktu ruang; butuh [dueDate].
@override final  String? dueTime;
@override@JsonKey() final  int priority;
@override final  double position;
/// Satu ID berarti satu orang; dua ID berarti "Kita".
 final  List<String> _assigneeIds;
/// Satu ID berarti satu orang; dua ID berarti "Kita".
@override@JsonKey() List<String> get assigneeIds {
  if (_assigneeIds is EqualUnmodifiableListView) return _assigneeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assigneeIds);
}

@override final  DateTime? remindAt;
@override final  DateTime? completedAt;
@override final  String? completedBy;
@override final  String? createdBy;
@override final  String? updatedBy;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCopyWith<_Task> get copyWith => __$TaskCopyWithImpl<_Task>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Task&&(identical(other.id, id) || other.id == id)&&(identical(other.taskListId, taskListId) || other.taskListId == taskListId)&&(identical(other.spaceId, spaceId) || other.spaceId == spaceId)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.dueTime, dueTime) || other.dueTime == dueTime)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.position, position) || other.position == position)&&const DeepCollectionEquality().equals(other.assigneeIds, _assigneeIds)&&(identical(other.remindAt, remindAt) || other.remindAt == remindAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.completedBy, completedBy) || other.completedBy == completedBy)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,taskListId,spaceId,title,notes,dueDate,dueTime,priority,position,const DeepCollectionEquality().hash(_assigneeIds),remindAt,completedAt,completedBy,createdBy,updatedBy,createdAt,updatedAt,deletedAt);
}

@override
String toString() {
    return 'Task(id: $id, taskListId: $taskListId, spaceId: $spaceId, title: $title, notes: $notes, dueDate: $dueDate, dueTime: $dueTime, priority: $priority, position: $position, assigneeIds: $assigneeIds, remindAt: $remindAt, completedAt: $completedAt, completedBy: $completedBy, createdBy: $createdBy, updatedBy: $updatedBy, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$TaskCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$TaskCopyWith(_Task value, $Res Function(_Task) _then) = __$TaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String taskListId, String spaceId, String title, String? notes, String? dueDate, String? dueTime, int priority, double position, List<String> assigneeIds, DateTime? remindAt, DateTime? completedAt, String? completedBy, String? createdBy, String? updatedBy, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$TaskCopyWithImpl<$Res>
    implements _$TaskCopyWith<$Res> {
  __$TaskCopyWithImpl(this._self, this._then);

  final _Task _self;
  final $Res Function(_Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? taskListId = null,Object? spaceId = null,Object? title = null,Object? notes = freezed,Object? dueDate = freezed,Object? dueTime = freezed,Object? priority = null,Object? position = null,Object? assigneeIds = null,Object? remindAt = freezed,Object? completedAt = freezed,Object? completedBy = freezed,Object? createdBy = freezed,Object? updatedBy = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_Task(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,taskListId: null == taskListId ? _self.taskListId : taskListId // ignore: cast_nullable_to_non_nullable
as String,spaceId: null == spaceId ? _self.spaceId : spaceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String?,dueTime: freezed == dueTime ? _self.dueTime : dueTime // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as double,assigneeIds: null == assigneeIds ? _self._assigneeIds : assigneeIds // ignore: cast_nullable_to_non_nullable
as List<String>,remindAt: freezed == remindAt ? _self.remindAt : remindAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedBy: freezed == completedBy ? _self.completedBy : completedBy // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
