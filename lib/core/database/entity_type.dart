/// Jenis data di cache lokal.
///
/// [apiPath] adalah sumber di URL untuk operasi antrean (`PUT /tasks/{id}`),
/// dan [syncKey] adalah nama koleksinya di balasan `GET /sync`.
enum EntityType {
  space(syncKey: 'spaces'),
  list(apiPath: 'lists', syncKey: 'task_lists'),
  task(apiPath: 'tasks', syncKey: 'tasks'),
  goal(apiPath: 'savings-goals', syncKey: 'savings_goals'),
  entry(apiPath: 'savings-entries', syncKey: 'savings_entries'),

  /// Tanggal penting (v0.2).
  specialDate(apiPath: 'special-dates', syncKey: 'special_dates'),

  /// Profil sendiri; hanya `PATCH /me` yang lewat antrean.
  me(apiPath: 'me');

  const EntityType({this.apiPath, this.syncKey});

  final String? apiPath;
  final String? syncKey;

  /// Urutan penerapan satu halaman sync: induk dulu, baru anak.
  static const List<EntityType> syncOrder = [space, list, task, goal, entry, specialDate];

  /// Jenis anak yang ikut terhapus saat induknya dihapus, beserta kolom penunjuk induknya.
  (EntityType, String)? get child => switch (this) {
    EntityType.list => (EntityType.task, 'task_list_id'),
    EntityType.goal => (EntityType.entry, 'savings_goal_id'),
    _ => null,
  };

  static EntityType byName(String name) => values.firstWhere((type) => type.name == name);
}
