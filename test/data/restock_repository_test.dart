import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';
import 'package:pos/data/repositories/restock_repository.dart';

void main() {
  late AppDatabase db;
  late RestockRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = RestockRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('RestockRepository & Parents Balance Ledger Tests', () {
    test('adds restock purchases and calculates total restock spend', () async {
      await repository.addRestockPurchase(
        date: DateTime(2026, 11, 10),
        amountCentavos: 500000, // P5,000.00
        note: 'Wholesale batch from Davao farmer',
      );

      await repository.addRestockPurchase(
        date: DateTime(2026, 11, 12),
        amountCentavos: 300000, // P3,000.00
        note: 'Binanggay crates',
      );

      final purchases = await repository.getAllRestockPurchases();
      expect(purchases.length, 2);
      expect(purchases.first.amountCentavos, 300000); // newest first

      final totalSpend = await repository.getTotalRestockSpendCentavos();
      expect(totalSpend, 800000); // P8,000.00
    });

    test(
      'calculates total returned to parents from locked payouts only',
      () async {
        // Locked payout (returned to parents)
        await db
            .into(db.payouts)
            .insert(
              PayoutsCompanion.insert(
                date: DateTime(2026, 11, 10),
                toParentsCentavos: 350000, // P3,500.00
                salaryCentavos: 50000,
                reserveCentavos: 20000,
                locked: const Value(true),
              ),
            );

        // Another locked payout
        await db
            .into(db.payouts)
            .insert(
              PayoutsCompanion.insert(
                date: DateTime(2026, 11, 11),
                toParentsCentavos: 200000, // P2,000.00
                salaryCentavos: 40000,
                reserveCentavos: 10000,
                locked: const Value(true),
              ),
            );

        // Unlocked payout (draft / reopened) - MUST NOT be counted as returned yet!
        await db
            .into(db.payouts)
            .insert(
              PayoutsCompanion.insert(
                date: DateTime(2026, 11, 12),
                toParentsCentavos: 150000,
                salaryCentavos: 30000,
                reserveCentavos: 5000,
                locked: const Value(false),
              ),
            );

        final totalReturned = await repository
            .getTotalReturnedToParentsCentavos();
        expect(totalReturned, 550000); // 350,000 + 200,000 = P5,500.00
      },
    );

    test(
      'computes running ledger balance: restock spend minus returned',
      () async {
        // Restock: P10,000.00
        await repository.addRestockPurchase(
          date: DateTime(2026, 11, 10),
          amountCentavos: 1000000,
        );

        // Returned: P6,000.00
        await db
            .into(db.payouts)
            .insert(
              PayoutsCompanion.insert(
                date: DateTime(2026, 11, 11),
                toParentsCentavos: 600000,
                salaryCentavos: 100000,
                reserveCentavos: 50000,
                locked: const Value(true),
              ),
            );

        final ledger = await repository.getParentsBalanceLedger();
        expect(ledger.totalRestockSpendCentavos, 1000000);
        expect(ledger.totalReturnedToParentsCentavos, 600000);
        expect(
          ledger.outstandingBalanceCentavos,
          400000,
        ); // P4,000.00 owed to parents
      },
    );

    test('deletes restock purchase', () async {
      final id = await repository.addRestockPurchase(
        date: DateTime(2026, 11, 10),
        amountCentavos: 100000,
      );

      expect((await repository.getAllRestockPurchases()).length, 1);

      await repository.deleteRestockPurchase(id);
      expect((await repository.getAllRestockPurchases()).isEmpty, isTrue);
    });
  });
}
