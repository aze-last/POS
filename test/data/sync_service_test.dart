import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';
import 'package:pos/data/services/sync_service.dart';

void main() {
  late AppDatabase db;
  late SyncService syncService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    syncService = SyncService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SyncService Offline-First Engine Tests', () {
    test('reports disabled status when Supabase is unconfigured', () async {
      expect(syncService.isConfigured, isFalse);
      final state = syncService.currentState;
      expect(state.status, equals(SyncStatus.disabled));
      expect(state.isConfigured, isFalse);
    });

    test('generates valid RFC-4122 v4 UUIDs', () {
      final uuid1 = syncService.generateUuid();
      final uuid2 = syncService.generateUuid();

      expect(uuid1, isNotEmpty);
      expect(uuid2, isNotEmpty);
      expect(uuid1, isNot(equals(uuid2)));

      final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        caseSensitive: false,
      );
      expect(uuidRegex.hasMatch(uuid1), isTrue);
      expect(uuidRegex.hasMatch(uuid2), isTrue);
    });

    test('enqueueOutbox writes into outboxItems table', () async {
      final uuid = syncService.generateUuid();
      await syncService.enqueueOutbox(
        entityType: 'products',
        entitySyncId: uuid,
        action: 'upsert',
        payload: {
          'id': uuid,
          'name': 'Cardava',
          'default_price_centavos': 3000,
          'capital_centavos': 2000,
        },
      );

      final items = await db.select(db.outboxItems).get();
      expect(items.length, equals(1));
      expect(items.first.entityType, equals('products'));
      expect(items.first.entitySyncId, equals(uuid));
      expect(items.first.action, equals('upsert'));
      expect(items.first.payloadJson, contains('Cardava'));
    });

    test('sync returns disabled when client is not available', () async {
      final result = await syncService.sync();
      expect(result.status, equals(SyncStatus.disabled));
    });
  });
}
