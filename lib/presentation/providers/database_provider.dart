import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';

/// Global provider for the SQLite Drift database instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
