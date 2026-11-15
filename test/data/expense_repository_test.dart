import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';
import 'package:pos/data/repositories/expense_repository.dart';
import 'package:pos/data/repositories/sale_repository.dart';

void main() {
  late AppDatabase db;
  late ExpenseRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = ExpenseRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ExpenseRepository Tests', () {
    final today = DateTime(2026, 11, 15, 14, 30);

    test('adds transport and other expenses with validation', () async {
      final id1 = await repository.addGeneralExpense(
        date: today,
        type: 'transport',
        amountCentavos: 15000, // P150.00
        note: 'Jeepney fare to market',
      );

      final id2 = await repository.addGeneralExpense(
        date: today,
        type: 'other',
        amountCentavos: 5000, // P50.00
        note: 'Plastic bags',
      );

      final expenses = await repository.getExpensesForDay(today);
      expect(expenses.length, 2);
      // Newest first (descending id)
      expect(expenses[0].id, id2);
      expect(expenses[0].type, 'other');
      expect(expenses[0].amountCentavos, 5000);

      expect(expenses[1].id, id1);
      expect(expenses[1].type, 'transport');
      expect(expenses[1].amountCentavos, 15000);
      expect(expenses[1].note, 'Jeepney fare to market');
    });

    test(
      'rejects general expense with non-positive amount or invalid type',
      () async {
        expect(
          () => repository.addGeneralExpense(
            date: today,
            type: 'transport',
            amountCentavos: 0,
          ),
          throwsArgumentError,
        );

        expect(
          () => repository.addGeneralExpense(
            date: today,
            type: 'invalid_type',
            amountCentavos: 5000,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'adds spoilage expense with snapshotted capital per kg and computed loss',
      () async {
        // 1500 g @ P18.00/kg capital = round_half_up(1800 * 1500 / 1000) = 2700 centavos
        final id = await repository.addSpoilageExpense(
          date: today,
          productId: 1, // Cardava
          grams: 1500,
          capitalPerKgCentavos: 1800,
          note: 'Overripe bruising',
        );

        final expenses = await repository.getExpensesForDay(today);
        expect(expenses.length, 1);
        final spoilage = expenses.first;
        expect(spoilage.id, id);
        expect(spoilage.type, 'spoilage');
        expect(spoilage.productId, 1);
        expect(spoilage.grams, 1500);
        expect(spoilage.capitalPerKgCentavos, 1800);
        expect(spoilage.amountCentavos, 2700);
        expect(spoilage.note, 'Overripe bruising');
      },
    );

    test(
      'aggregates daily expenses separating spoilage and other expenses',
      () async {
        // Spoilage: 2700 centavos
        await repository.addSpoilageExpense(
          date: today,
          productId: 1,
          grams: 1500,
          capitalPerKgCentavos: 1800,
        );

        // Transport: 10000 centavos
        await repository.addGeneralExpense(
          date: today,
          type: 'transport',
          amountCentavos: 10000,
        );

        // Other: 4000 centavos
        await repository.addGeneralExpense(
          date: today,
          type: 'other',
          amountCentavos: 4000,
        );

        final breakdown = await repository.getDailyExpenseSummary(today);
        expect(breakdown.spoilageCentavos, 2700);
        expect(breakdown.otherExpensesCentavos, 14000); // 10000 + 4000
        expect(breakdown.totalExpensesCentavos, 16700);
      },
    );

    test('deletes expense when day is open', () async {
      final id = await repository.addGeneralExpense(
        date: today,
        type: 'transport',
        amountCentavos: 5000,
      );

      var expenses = await repository.getExpensesForDay(today);
      expect(expenses.length, 1);

      await repository.deleteExpense(id);

      expenses = await repository.getExpensesForDay(today);
      expect(expenses.isEmpty, isTrue);
    });

    test('prevents deleting or adding expenses on locked day', () async {
      final id = await repository.addGeneralExpense(
        date: today,
        type: 'transport',
        amountCentavos: 5000,
      );

      // Lock day in payouts
      await db
          .into(db.payouts)
          .insert(
            PayoutsCompanion.insert(
              date: DateTime(today.year, today.month, today.day),
              toParentsCentavos: 1000,
              salaryCentavos: 500,
              reserveCentavos: 500,
              locked: const Value(true),
            ),
          );

      // Delete should fail with SaleModificationLockedException
      await expectLater(
        repository.deleteExpense(id),
        throwsA(isA<SaleModificationLockedException>()),
      );

      // Add should fail with SaleModificationLockedException
      await expectLater(
        repository.addGeneralExpense(
          date: today,
          type: 'other',
          amountCentavos: 2000,
        ),
        throwsA(isA<SaleModificationLockedException>()),
      );
    });
  });
}
