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
  });
}
