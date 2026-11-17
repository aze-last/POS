import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pos_mig_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('migration from v1 to v4 succeeds on disk file', () async {
    final file = File('${tempDir.path}/v1.sqlite');
    // Open and write schema v1
    final rawDb1 = NativeDatabase(file);
    final dbV1 = _V1Db(rawDb1);
    await dbV1.customStatement('SELECT 1;');
    await dbV1.close();

    // Now open with AppDatabase (v4)
    final rawDb4 = NativeDatabase(file);
    final dbV4 = AppDatabase(rawDb4);
    try {
      await dbV4.customStatement('SELECT 1;');
      final prods = await dbV4.select(dbV4.products).get();
      expect(prods, isEmpty);
    } finally {
      await dbV4.close();
    }
  });

  test('migration from v2 to v4 succeeds on disk file', () async {
    final file = File('${tempDir.path}/v2.sqlite');
    final rawDb2 = NativeDatabase(file);
    final dbV2 = _V2Db(rawDb2);
    await dbV2.customStatement('SELECT 1;');
    await dbV2.close();

    final rawDb4 = NativeDatabase(file);
    final dbV4 = AppDatabase(rawDb4);
    try {
      await dbV4.customStatement('SELECT 1;');
      final prods = await dbV4.select(dbV4.products).get();
      expect(prods, isEmpty);
    } finally {
      await dbV4.close();
    }
  });

  test('migration from v3 to v4 succeeds on disk file', () async {
    final file = File('${tempDir.path}/v3.sqlite');
    final rawDb3 = NativeDatabase(file);
    final dbV3 = _V3Db(rawDb3);
    await dbV3.customStatement('SELECT 1;');
    await dbV3.close();

    final rawDb4 = NativeDatabase(file);
    final dbV4 = AppDatabase(rawDb4);
    try {
      await dbV4.customStatement('SELECT 1;');
      final prods = await dbV4.select(dbV4.products).get();
      expect(prods, isEmpty);
    } finally {
      await dbV4.close();
    }
  });

  test(
    'interrupted migration with partially added columns succeeds on retry',
    () async {
      final file = File('${tempDir.path}/partial.sqlite');
      // Start with v1 DB
      final rawDb1 = NativeDatabase(file);
      final dbV1 = _V1Db(rawDb1);
      await dbV1.customStatement('SELECT 1;');
      // Simulate partial migration failure: some columns added manually while user_version is still 1
      await dbV1.customStatement(
        'ALTER TABLE products ADD COLUMN sync_id TEXT;',
      );
      await dbV1.customStatement('ALTER TABLE sales ADD COLUMN sync_id TEXT;');
      await dbV1.close();

      // Now open with AppDatabase (v4) - should safely handle the pre-existing columns
      final rawDb4 = NativeDatabase(file);
      final dbV4 = AppDatabase(rawDb4);
      try {
        await dbV4.customStatement('SELECT 1;');
        final prods = await dbV4.select(dbV4.products).get();
        expect(prods, isEmpty);
      } finally {
        await dbV4.close();
      }
    },
  );
}

const _v1Sql = '''
  CREATE TABLE products (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    default_price_centavos INTEGER NOT NULL,
    capital_centavos INTEGER NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    archived INTEGER NOT NULL DEFAULT 0
  );
  CREATE TABLE capital_history (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    old_centavos INTEGER NOT NULL,
    new_centavos INTEGER NOT NULL,
    changed_at INTEGER NOT NULL
  );
  CREATE TABLE sales (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    created_at INTEGER NOT NULL,
    exact_total_centavos INTEGER NOT NULL,
    charged_centavos INTEGER NOT NULL,
    paid_centavos INTEGER NOT NULL,
    change_centavos INTEGER NOT NULL,
    voided INTEGER NOT NULL DEFAULT 0
  );
  CREATE TABLE sale_items (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    sale_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    product_name_snapshot TEXT NOT NULL,
    grams INTEGER NOT NULL,
    price_per_kg_centavos INTEGER NOT NULL,
    capital_per_kg_centavos INTEGER NOT NULL
  );
  CREATE TABLE expenses (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    date INTEGER NOT NULL,
    type TEXT NOT NULL,
    amount_centavos INTEGER NOT NULL,
    note TEXT,
    product_id INTEGER,
    grams INTEGER,
    capital_per_kg_centavos INTEGER
  );
  CREATE TABLE restock_purchases (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    date INTEGER NOT NULL,
    amount_centavos INTEGER NOT NULL,
    note TEXT
  );
  CREATE TABLE payouts (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    date INTEGER NOT NULL,
    to_parents_centavos INTEGER NOT NULL,
    salary_centavos INTEGER NOT NULL,
    reserve_centavos INTEGER NOT NULL,
    locked INTEGER NOT NULL DEFAULT 0
  );
  CREATE TABLE settings (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    salary_mode TEXT NOT NULL DEFAULT 'percent',
    salary_percent_basis_points INTEGER NOT NULL DEFAULT 3000,
    fixed_daily_salary_centavos INTEGER NOT NULL DEFAULT 0
  );
''';

const _v2Sql = '''
  ALTER TABLE sales ADD COLUMN edited_at INTEGER;
  ALTER TABLE sales ADD COLUMN edit_count INTEGER NOT NULL DEFAULT 0;
  CREATE TABLE sale_edits (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    sale_id INTEGER NOT NULL,
    edited_at INTEGER NOT NULL,
    before_json TEXT NOT NULL,
    after_json TEXT NOT NULL,
    reason TEXT
  );
''';

const _v3Sql = '''
  ALTER TABLE products ADD COLUMN image_path TEXT;
''';

class _V1Db extends GeneratedDatabase {
  _V1Db(super.executor);
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await customStatement(_v1Sql);
    },
  );
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [];
  @override
  Iterable<TableInfo> get allTables => [];
}

class _V2Db extends GeneratedDatabase {
  _V2Db(super.executor);
  @override
  int get schemaVersion => 2;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await customStatement(_v1Sql);
      await customStatement(_v2Sql);
    },
  );
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [];
  @override
  Iterable<TableInfo> get allTables => [];
}

class _V3Db extends GeneratedDatabase {
  _V3Db(super.executor);
  @override
  int get schemaVersion => 3;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await customStatement(_v1Sql);
      await customStatement(_v2Sql);
      await customStatement(_v3Sql);
    },
  );
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [];
  @override
  Iterable<TableInfo> get allTables => [];
}
