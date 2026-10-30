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

  /// Perjalanan (v0.2). Checklist persiapannya adalah daftar dengan `trip_id`.
  trip(apiPath: 'trips', syncKey: 'trips'),

  /// Kenangan (v0.3).
  memory(apiPath: 'memories', syncKey: 'memories'),

  /// Foto kenangan (v0.3). Dibuat lewat `POST` multipart, bukan `PUT`.
  memoryPhoto(apiPath: 'memory-photos', syncKey: 'memory_photos'),

  /// Komentar pada tugas, setoran, atau kenangan di Ruang Bersama (v1.x).
  comment(apiPath: 'comments', syncKey: 'comments'),

  /// Reaksi emoji pada tugas, setoran, atau kenangan di Ruang Bersama (v1.x). Tanpa `PATCH`.
  reaction(apiPath: 'reactions', syncKey: 'reactions'),

  /// Profil sendiri; hanya `PATCH /me` yang lewat antrean.
  me(apiPath: 'me');

  const EntityType({this.apiPath, this.syncKey});

  final String? apiPath;
  final String? syncKey;

  /// Urutan penerapan satu halaman sync: induk dulu, baru anak.
  static const List<EntityType> syncOrder = [
    space,
    trip,
    list,
    task,
    goal,
    entry,
    specialDate,
    memory,
    memoryPhoto,
    comment,
    reaction,
  ];

  /// Jenis anak yang ikut terhapus saat induknya dihapus. Komentar dan reaksi (v1.x) menunjuk
  /// induknya lewat `subject_id`.
  ///
  /// Perjalanan tidak tercantum: server ikut menghapus checklist dan tugasnya, dan
  /// penghapusan itu sampai lewat sync bersama perjalanannya. Begitu pula komentar dan
  /// reaksi pada anak dari induk yang dihapus berantai (daftar ke tugas, target ke setoran).
  List<EntityType> get children => switch (this) {
    EntityType.list => const [EntityType.task],
    EntityType.goal => const [EntityType.entry],
    EntityType.memory => const [EntityType.memoryPhoto, EntityType.comment, EntityType.reaction],
    EntityType.task || EntityType.entry => const [EntityType.comment, EntityType.reaction],
    _ => const [],
  };

  /// Isi ruang: semua jenis yang punya `space_id`. Saat Ruang Bersama tiba tertutup (v1.0),
  /// semuanya ikut terhapus dari cache.
  static const List<EntityType> spaceContent = [
    list,
    task,
    goal,
    entry,
    specialDate,
    trip,
    memory,
    memoryPhoto,
    comment,
    reaction,
  ];

  /// Jenis yang ikut terhapus saat data ini tiba terhapus: [children], atau untuk ruang (v1.0)
  /// seluruh [spaceContent]. Yang masih punya operasi di antrean dibiarkan.
  List<EntityType> get dependents => this == EntityType.space ? spaceContent : children;

  static EntityType byName(String name) => values.firstWhere((type) => type.name == name);
}
