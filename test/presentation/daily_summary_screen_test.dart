import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';
import 'package:pos/data/repositories/expense_repository.dart';
import 'package:pos/data/repositories/sale_repository.dart';
import 'package:pos/domain/models/weight.dart';
import 'package:pos/presentation/providers/database_provider.dart';
import 'package:pos/presentation/screens/summary/daily_summary_screen.dart';

void main() {
  late AppDatabase db;
  late SaleRepository saleRepo;
  late ExpenseRepository expenseRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    saleRepo = SaleRepository(db);
    expenseRepo = ExpenseRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: DailySummaryScreen()),
    );
  }

  Future<void> cleanUpWidget(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('DailySummaryScreen & Payout Section Widget Tests', () {
    testWidgets(
      'renders daily summary with live volume and 8-step payout settlement',
      (tester) async {
        final now = DateTime.now();

        // Sale 1: Cardava 2000g @ P30.00/kg (Value 6000, Capital 3600; Profit 2400)
        await saleRepo.completeSale(
          lines: [
            SaleLineInput(
              productId: 1,
              productName: 'Cardava',
              weight: Weight.fromGrams(2000),
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 1800,
            ),
          ],
          chargedCentavos: 6000,
          paidCentavos: 6000,
          createdAt: now,
        );

        // Expense: Spoilage 1000g Cardava @ 1800 = 1800 centavos (P18.00)
        await expenseRepo.addSpoilageExpense(
          date: now,
          productId: 1,
          grams: 1000,
          capitalPerKgCentavos: 1800,
        );

        // Expense: Transport P10.00 (1000 centavos)
        await expenseRepo.addGeneralExpense(
          date: now,
          type: 'transport',
          amountCentavos: 1000,
        );

        // Math:
        // Sales: P60.00
        // Capital sold: P36.00
        // Gross profit: P24.00
        // Spoilage: P18.00
        // Other: P10.00
        // Net profit: 24.00 - 18.00 - 10.00 = -P4.00 (Loss!)
        // Suggested to parents: 36.00 + 18.00 = P54.00
        // Suggested salary: 0 (net profit < 0)
        // Reserve: 60.00 - 54.00 - 0 - 10.00 = -P4.00 (Shortfall!)

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Check KPI cards
        expect(find.text('TOTAL CHARGED'), findsOneWidget);
        expect(find.text('P60.00'), findsWidgets);
        expect(find.text('GROSS PROFIT'), findsOneWidget);
        expect(find.text('P24.00'), findsWidgets);

        // Volume sold
        expect(find.text('VOLUME SOLD BY VARIETY'), findsOneWidget);
        expect(find.text('Cardava'), findsWidgets);
        expect(find.text('2.000 kg'), findsOneWidget);

        // Payout Section
        expect(find.text('Daily Payout Settlement'), findsOneWidget);
        expect(find.text('RESERVE SHORTFALL'), findsOneWidget);
        expect(find.text('-P4.00'), findsWidgets);

        await cleanUpWidget(tester);
      },
    );

    testWidgets('locks payout on Mark as Paid Out and allows Reopening', (
      tester,
    ) async {
      final now = DateTime.now();

      await saleRepo.completeSale(
        lines: [
          SaleLineInput(
            productId: 1,
            productName: 'Cardava',
            weight: Weight.fromGrams(1000),
            pricePerKgCentavos: 3000,
            capitalPerKgCentavos: 1800,
          ),
        ],
        chargedCentavos: 3000,
        paidCentavos: 3000,
        createdAt: now,
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Scroll down to Payout section
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -750),
      );
      await tester.pumpAndSettle();

      // Button: Mark as Paid Out & Lock Day
      final lockButton = find.text('Mark as Paid Out & Lock Day');
      expect(lockButton, findsOneWidget);

      // Tap Lock Day
      await tester.tap(lockButton);
      await tester.pumpAndSettle();

      // Dialog appears
      expect(find.text('Lock Day Payout?'), findsOneWidget);
      await tester.tap(find.text('Confirm & Lock'));
      await tester.pumpAndSettle();

      // Day is locked! Button is now Reopen Day Payout
      final reopenButton = find.text('Reopen Day Payout');
      expect(reopenButton, findsOneWidget);

      // Reopen Day
      await tester.tap(reopenButton);
      await tester.pumpAndSettle();

      expect(find.text('Reopen Day Payout?'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Reopen Day'));
      await tester.pumpAndSettle();

      // Unlocked!
      expect(lockButton, findsOneWidget);

      await cleanUpWidget(tester);
    });

    testWidgets(
      'displays edited sales count and reopened payout warning banner with saved vs suggested amounts',
      (tester) async {
        final now = DateTime.now();

        final saleResult = await saleRepo.completeSale(
          lines: [
            SaleLineInput(
              productId: 1,
              productName: 'Cardava',
              weight: Weight.fromGrams(1000),
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 1800,
            ),
          ],
          chargedCentavos: 3000,
          paidCentavos: 3000,
          createdAt: now,
        );

        // Lock the day with initial payout
        await db
            .into(db.payouts)
            .insert(
              PayoutsCompanion.insert(
                date: DateTime(now.year, now.month, now.day),
                toParentsCentavos: 1800,
                salaryCentavos: 600,
                reserveCentavos: 600,
                locked: const Value(true),
              ),
            );

        // Reopen the day
        await saleRepo.reopenDay(now);

        // Edit the sale (e.g. increase weight to 2000g, charged 5000)
        await saleRepo.editSale(
          saleId: saleResult.sale.id,
          newLines: [
            SaleLineInput(
              originalItemId: saleResult.items.single.id,
              productId: 1,
              productName: 'Cardava',
              weight: Weight.fromGrams(2000),
              pricePerKgCentavos: 2500,
              capitalPerKgCentavos: 1800,
            ),
          ],
          chargedCentavos: 5000,
          paidCentavos: 5000,
          reason: 'Customer added 1kg',
        );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Verify "1 sale edited today" counter is displayed
        expect(find.text('1 sale edited today'), findsOneWidget);

        // Verify reopened payout banner is displayed
        expect(
          find.text(
            'Sales changed since this day was paid out. Review the payout before marking it again.',
          ),
          findsOneWidget,
        );
        expect(find.text('PREVIOUSLY SAVED'), findsOneWidget);
        expect(find.text('NEW SUGGESTED'), findsOneWidget);

        await cleanUpWidget(tester);
      },
    );

    testWidgets(
      'switches to Weekly View and displays weekly totals for parents and salary',
      (tester) async {
        final now = DateTime.now();

        // Add a sale for today
        await saleRepo.completeSale(
          lines: [
            SaleLineInput(
              productId: 1,
              productName: 'Cardava',
              weight: Weight.fromGrams(1000),
              pricePerKgCentavos: 5000,
              capitalPerKgCentavos: 3000,
            ),
          ],
          chargedCentavos: 5000, // P50.00
          paidCentavos: 5000,
          createdAt: now,
        );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Find Weekly Payout segmented button and tap it
        final weeklySegment = find.text('Weekly Payout');
        expect(weeklySegment, findsOneWidget);
        await tester.tap(weeklySegment);
        await tester.pumpAndSettle();

        // Verify Weekly Summary title and highlight KPI cards appear
        expect(find.text('Weekly Summary'), findsOneWidget);
        expect(find.text('TOTAL TO PARENTS'), findsOneWidget);
        expect(find.text('MY TOTAL SALARY'), findsOneWidget);
        expect(find.text('WEEKLY FINANCIAL CONSOLIDATION'), findsOneWidget);
        expect(find.text('DAY-BY-DAY BREAKDOWN (MON–SUN)'), findsOneWidget);

        await cleanUpWidget(tester);
      },
    );
  });
}
