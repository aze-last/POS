import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';
import 'package:pos/data/repositories/expense_repository.dart';
import 'package:pos/presentation/providers/database_provider.dart';
import 'package:pos/presentation/screens/expenses/expenses_screen.dart';

void main() {
  late AppDatabase db;
  late ExpenseRepository expenseRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    expenseRepo = ExpenseRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: ExpensesScreen()),
    );
  }

  Future<void> cleanUpWidget(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('ExpensesScreen Widget Tests', () {
    testWidgets('renders empty state and adds transport expense', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Expenses & Losses'), findsOneWidget);
      expect(find.text('No expenses or losses recorded today'), findsOneWidget);

      // Tap + Add Expense / Loss
      await tester.tap(find.text('Add Expense / Loss'));
      await tester.pumpAndSettle();

      // Dialog opens
      expect(find.text('Add Expense / Loss'), findsWidgets);
      expect(find.text('Transport'), findsOneWidget);

      // Enter amount via quick chip P50
      await tester.tap(find.text('P50'));
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();

      // Expense card displayed
      expect(find.text('TRANSPORT'), findsOneWidget);
      expect(find.text('P50.00'), findsWidgets);

      await cleanUpWidget(tester);
    });

    testWidgets('adds spoilage expense and calculates loss', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.text('Add Expense / Loss'));
      await tester.pumpAndSettle();

      // Switch to Spoilage tab
      await tester.tap(find.text('Spoilage'));
      await tester.pumpAndSettle();

      // Tap +1.0 kg quick chip
      await tester.tap(find.text('+1.0 kg'));
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();

      // Spoilage card displayed
      expect(find.text('SPOILAGE'), findsOneWidget);
      expect(find.text('1.000 kg spoiled @ P20.00/kg cost'), findsOneWidget);
      expect(find.text('P20.00'), findsWidgets);

      await cleanUpWidget(tester);
    });

    testWidgets('deletes expense with confirmation', (tester) async {
      final now = DateTime.now();
      await expenseRepo.addGeneralExpense(
        date: now,
        type: 'transport',
        amountCentavos: 3000,
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('TRANSPORT'), findsOneWidget);

      // Tap delete icon
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Delete Expense?'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('No expenses or losses recorded today'), findsOneWidget);

      await cleanUpWidget(tester);
    });

    testWidgets(
      'displays daily salary tracker and warns when expenses reduce fixed salary',
      (tester) async {
        final now = DateTime.now();

        // Configure fixed daily salary of P500 (50,000 centavos)
        await (db.update(db.settings)..where((s) => s.id.equals(1))).write(
          const SettingsCompanion(
            salaryMode: Value('fixed'),
            fixedDailySalaryCentavos: Value(50000),
          ),
        );

        // Add a sale with charged = P600 (60,000 centavos), capital = P200 (20,000 centavos) -> gross profit = P400 (40,000 centavos)
        final saleId = await db
            .into(db.sales)
            .insert(
              SalesCompanion.insert(
                createdAt: now,
                exactTotalCentavos: 60000,
                chargedCentavos: 60000,
                paidCentavos: 60000,
                changeCentavos: 0,
              ),
            );
        await db
            .into(db.saleItems)
            .insert(
              SaleItemsCompanion.insert(
                saleId: saleId,
                productId: 1,
                productNameSnapshot: 'Lakatan',
                grams: 2000,
                pricePerKgCentavos: 30000,
                capitalPerKgCentavos: 10000,
              ),
            );

        // Add an expense of P100 (10,000 centavos) -> net profit = P300 (30,000 centavos)
        await expenseRepo.addGeneralExpense(
          date: now,
          type: 'transport',
          amountCentavos: 10000,
        );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Header displays salary tracker
        expect(find.text('DAILY SALARY TRACKER'), findsOneWidget);
        expect(find.text('SALARY LEFT TODAY'), findsOneWidget);

        // Net profit is P300, target was P500. Salary left is P300.00
        expect(find.text('P300.00'), findsOneWidget);

        // Low salary warning is displayed
        expect(
          find.textContaining(
            'Low Salary Warning: Expenses reduced your salary',
          ),
          findsOneWidget,
        );

        await cleanUpWidget(tester);
      },
    );

    testWidgets('displays zero salary alert when expenses exceed profits', (
      tester,
    ) async {
      final now = DateTime.now();

      // Configure fixed daily salary of P500
      await (db.update(db.settings)..where((s) => s.id.equals(1))).write(
        const SettingsCompanion(
          salaryMode: Value('fixed'),
          fixedDailySalaryCentavos: Value(50000),
        ),
      );

      // Add a sale with gross profit = P100 (charged 200, capital 100)
      final saleId = await db
          .into(db.sales)
          .insert(
            SalesCompanion.insert(
              createdAt: now,
              exactTotalCentavos: 20000,
              chargedCentavos: 20000,
              paidCentavos: 20000,
              changeCentavos: 0,
            ),
          );
      await db
          .into(db.saleItems)
          .insert(
            SaleItemsCompanion.insert(
              saleId: saleId,
              productId: 1,
              productNameSnapshot: 'Lakatan',
              grams: 1000,
              pricePerKgCentavos: 20000,
              capitalPerKgCentavos: 10000,
            ),
          );

      // Add expense of P150 -> net profit = -P50
      await expenseRepo.addGeneralExpense(
        date: now,
        type: 'other',
        amountCentavos: 15000,
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Salary left is P0.00
      expect(find.text('P0.00'), findsWidgets);

      // Zero salary alert banner is displayed
      expect(
        find.textContaining(
          "Warning: Expenses (P150.00) have exhausted today's profits! P0.00 salary left today.",
        ),
        findsOneWidget,
      );

      await cleanUpWidget(tester);
    });

    testWidgets(
      'AddExpenseDialog previews live salary impact and shows warning',
      (tester) async {
        final now = DateTime.now();

        // Configure fixed daily salary of P500
        await (db.update(db.settings)..where((s) => s.id.equals(1))).write(
          const SettingsCompanion(
            salaryMode: Value('fixed'),
            fixedDailySalaryCentavos: Value(50000),
          ),
        );

        // Add a sale with gross profit = P300
        final saleId = await db
            .into(db.sales)
            .insert(
              SalesCompanion.insert(
                createdAt: now,
                exactTotalCentavos: 40000,
                chargedCentavos: 40000,
                paidCentavos: 40000,
                changeCentavos: 0,
              ),
            );
        await db
            .into(db.saleItems)
            .insert(
              SaleItemsCompanion.insert(
                saleId: saleId,
                productId: 1,
                productNameSnapshot: 'Lakatan',
                grams: 1000,
                pricePerKgCentavos: 40000,
                capitalPerKgCentavos: 10000,
              ),
            );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Open Add Expense dialog
        await tester.tap(find.text('Add Expense / Loss'));
        await tester.pumpAndSettle();

        // Dialog opens, salary left shows current salary (P300.00)
        expect(find.text('Salary Left Today:'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('P300.00'),
          ),
          findsOneWidget,
        );

        // Tap P100 chip
        await tester.tap(find.text('P100'));
        await tester.pumpAndSettle();

        // Projected salary left becomes P200.00 (P300 - P100)
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('P200.00'),
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining('Warning: Reduces your salary by P100.00'),
          findsOneWidget,
        );

        await cleanUpWidget(tester);
      },
    );

    testWidgets(
      'displays daily salary tracker and warns when expenses reduce fixed salary',
      (tester) async {
        final now = DateTime.now();

        // Configure fixed daily salary of P500 (50,000 centavos)
        await (db.update(db.settings)..where((s) => s.id.equals(1))).write(
          const SettingsCompanion(
            salaryMode: Value('fixed'),
            fixedDailySalaryCentavos: Value(50000),
          ),
        );

        // Add a sale with charged = P600 (60,000 centavos), capital = P200 (20,000 centavos) -> gross profit = P400 (40,000 centavos)
        final saleId = await db
            .into(db.sales)
            .insert(
              SalesCompanion.insert(
                createdAt: now,
                exactTotalCentavos: 60000,
                chargedCentavos: 60000,
                paidCentavos: 60000,
                changeCentavos: 0,
              ),
            );
        await db
            .into(db.saleItems)
            .insert(
              SaleItemsCompanion.insert(
                saleId: saleId,
                productId: 1,
                productNameSnapshot: 'Lakatan',
                grams: 2000,
                pricePerKgCentavos: 30000,
                capitalPerKgCentavos: 10000,
              ),
            );

        // Add an expense of P100 (10,000 centavos) -> net profit = P300 (30,000 centavos)
        await expenseRepo.addGeneralExpense(
          date: now,
          type: 'transport',
          amountCentavos: 10000,
        );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Header displays salary tracker
        expect(find.text('DAILY SALARY TRACKER'), findsOneWidget);
        expect(find.text('SALARY LEFT TODAY'), findsOneWidget);

        // Net profit is P300, target was P500. Salary left is P300.00
        expect(find.text('P300.00'), findsOneWidget);

        // Low salary warning is displayed
        expect(
          find.textContaining(
            'Low Salary Warning: Expenses reduced your salary',
          ),
          findsOneWidget,
        );

        await cleanUpWidget(tester);
      },
    );

    testWidgets('displays zero salary alert when expenses exceed profits', (
      tester,
    ) async {
      final now = DateTime.now();

      // Configure fixed daily salary of P500
      await (db.update(db.settings)..where((s) => s.id.equals(1))).write(
        const SettingsCompanion(
          salaryMode: Value('fixed'),
          fixedDailySalaryCentavos: Value(50000),
        ),
      );

      // Add a sale with gross profit = P100 (charged 200, capital 100)
      final saleId = await db
          .into(db.sales)
          .insert(
            SalesCompanion.insert(
              createdAt: now,
              exactTotalCentavos: 20000,
              chargedCentavos: 20000,
              paidCentavos: 20000,
              changeCentavos: 0,
            ),
          );
      await db
          .into(db.saleItems)
          .insert(
            SaleItemsCompanion.insert(
              saleId: saleId,
              productId: 1,
              productNameSnapshot: 'Lakatan',
              grams: 1000,
              pricePerKgCentavos: 20000,
              capitalPerKgCentavos: 10000,
            ),
          );

      // Add expense of P150 -> net profit = -P50
      await expenseRepo.addGeneralExpense(
        date: now,
        type: 'other',
        amountCentavos: 15000,
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Salary left is P0.00
      expect(find.text('P0.00'), findsWidgets);

      // Zero salary alert banner is displayed
      expect(
        find.textContaining(
          "Warning: Expenses (P150.00) have exhausted today's profits! P0.00 salary left today.",
        ),
        findsOneWidget,
      );

      await cleanUpWidget(tester);
    });

    testWidgets(
      'AddExpenseDialog previews live salary impact and shows warning',
      (tester) async {
        final now = DateTime.now();

        // Configure fixed daily salary of P500
        await (db.update(db.settings)..where((s) => s.id.equals(1))).write(
          const SettingsCompanion(
            salaryMode: Value('fixed'),
            fixedDailySalaryCentavos: Value(50000),
          ),
        );

        // Add a sale with gross profit = P300
        final saleId = await db
            .into(db.sales)
            .insert(
              SalesCompanion.insert(
                createdAt: now,
                exactTotalCentavos: 40000,
                chargedCentavos: 40000,
                paidCentavos: 40000,
                changeCentavos: 0,
              ),
            );
        await db
            .into(db.saleItems)
            .insert(
              SaleItemsCompanion.insert(
                saleId: saleId,
                productId: 1,
                productNameSnapshot: 'Lakatan',
                grams: 1000,
                pricePerKgCentavos: 40000,
                capitalPerKgCentavos: 10000,
              ),
            );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Open Add Expense dialog
        await tester.tap(find.text('Add Expense / Loss'));
        await tester.pumpAndSettle();

        // Dialog opens, salary left shows current salary (P300.00)
        expect(find.text('Salary Left Today:'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('P300.00'),
          ),
          findsOneWidget,
        );

        // Tap P100 chip
        await tester.tap(find.text('P100'));
        await tester.pumpAndSettle();

        // Projected salary left becomes P200.00 (P300 - P100)
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('P200.00'),
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining('Warning: Reduces your salary by P100.00'),
          findsOneWidget,
        );

        await cleanUpWidget(tester);
      },
    );
  });
}
