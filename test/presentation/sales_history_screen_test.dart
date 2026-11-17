import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';
import 'package:pos/data/repositories/sale_repository.dart';
import 'package:pos/domain/models/weight.dart';
import 'package:pos/presentation/providers/database_provider.dart';
import 'package:pos/presentation/screens/sales/sales_history_screen.dart';

void main() {
  late AppDatabase db;
  late SaleRepository saleRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    saleRepo = SaleRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: SalesHistoryScreen()),
    );
  }

  Future<void> cleanUpWidget(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('SalesHistoryScreen Widget & Audit Tests', () {
    testWidgets('renders empty state when no sales exist', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sales History'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('All Time'), findsOneWidget);
      expect(find.text('No sales recorded'), findsOneWidget);

      await cleanUpWidget(tester);
    });

    testWidgets(
      'renders sales grouped by day with correct charged and snapshotted profit',
      (tester) async {
        final now = DateTime.now();

        // Complete two sales today
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

        await saleRepo.completeSale(
          lines: [
            SaleLineInput(
              productId: 2,
              productName: 'Binanggay',
              weight: Weight.fromGrams(2000),
              pricePerKgCentavos: 2500,
              capitalPerKgCentavos: 1500,
            ),
          ],
          chargedCentavos: 5000,
          paidCentavos: 5000,
          createdAt: now,
        );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Check summary banner: Total Charged = P80.00, Profit = P32.00 (1200 + 2000 = 3200 centavos)
        expect(find.text('P80.00'), findsOneWidget);
        expect(find.text('P32.00'), findsOneWidget);
        expect(find.text('2 sales'), findsOneWidget);

        // Day header
        expect(find.text('Today'), findsWidgets);

        // Sale cards
        expect(find.text('Sale #1'), findsOneWidget);
        expect(find.text('Sale #2'), findsOneWidget);

        await cleanUpWidget(tester);
      },
    );

    testWidgets(
      'tap sale card opens SaleDetailSheet showing snapshotted lines',
      (tester) async {
        final now = DateTime.now();

        await saleRepo.completeSale(
          lines: [
            SaleLineInput(
              productId: 1,
              productName: 'Cardava',
              weight: Weight.fromGrams(1500),
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 1800,
            ),
          ],
          chargedCentavos: 4500,
          paidCentavos: 5000,
          createdAt: now,
        );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap Sale #1
        await tester.tap(find.text('Sale #1'));
        await tester.pumpAndSettle();

        // Details sheet opened
        expect(find.text('ITEMIZED LINES (SNAPSHOT)'), findsOneWidget);
        expect(find.text('Cardava'), findsWidgets);
        expect(find.text('1.500 kg @ P30.00/kg'), findsOneWidget);
        expect(find.text('Capital: P18.00/kg (P27.00)'), findsOneWidget);
        expect(find.text('+P18.00 profit'), findsWidgets);
        expect(find.text('Change Returned'), findsOneWidget);
        expect(
          find.text('P5.00'),
          findsOneWidget,
        ); // 5000 - 4500 = 500 centavos = P5.00
        expect(find.text('Void This Sale'), findsOneWidget);

        await cleanUpWidget(tester);
      },
    );

    testWidgets(
      'voids sale safely with confirmation dialog and excludes from active totals',
      (tester) async {
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

        await saleRepo.completeSale(
          lines: [
            SaleLineInput(
              productId: 2,
              productName: 'Binanggay',
              weight: Weight.fromGrams(2000),
              pricePerKgCentavos: 2500,
              capitalPerKgCentavos: 1500,
            ),
          ],
          chargedCentavos: 5000,
          paidCentavos: 5000,
          createdAt: now,
        );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Initially: Total sales P80.00
        expect(find.text('P80.00'), findsOneWidget);

        // Tap Sale #1 to open sheet
        await tester.tap(find.text('Sale #1'));
        await tester.pumpAndSettle();

        // Tap Void This Sale
        await tester.tap(find.text('Void This Sale'));
        await tester.pumpAndSettle();

        // Confirm dialog appears
        expect(find.text('Void Sale #1?'), findsOneWidget);
        expect(
          find.text(
            'This sale will be kept for audit records, but permanently excluded from sales totals, net profit, and payout formulas.',
          ),
          findsOneWidget,
        );

        // Confirm void
        await tester.tap(find.widgetWithText(ElevatedButton, 'Void Sale'));
        await tester.pumpAndSettle();

        // Verified: Sale #1 is marked VOIDED
        expect(find.text('VOIDED'), findsOneWidget);

        // Active total sales now only includes Sale #2 (P50.00 and P20.00 profit)
        expect(find.text('P50.00'), findsWidgets);
        expect(find.text('P20.00'), findsWidgets);
        expect(find.text('1 sale (1 voided)'), findsOneWidget);

        await cleanUpWidget(tester);
      },
    );

    testWidgets(
      'safeguards against voiding when day is locked unless reopened',
      (tester) async {
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

        // Insert locked payout for today
        await db
            .into(db.payouts)
            .insert(
              PayoutsCompanion.insert(
                date: DateTime(now.year, now.month, now.day),
                toParentsCentavos: 1800,
                salaryCentavos: 500,
                reserveCentavos: 700,
                locked: const Value(true),
              ),
            );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Locked badge should appear in day header
        expect(find.text('Locked'), findsOneWidget);

        // Tap Sale #1 to open detail sheet
        await tester.tap(find.text('Sale #1'));
        await tester.pumpAndSettle();

        // Tap Void This Sale
        await tester.tap(find.text('Void This Sale'));
        await tester.pumpAndSettle();

        // Void confirmation dialog is displayed with Reopen notice
        expect(find.text('Void Sale #1?'), findsOneWidget);
        expect(
          find.text(
            'Notice: This day payout is locked. Confirming this void will unlock and reopen the day.',
          ),
          findsOneWidget,
        );

        // Confirm Reopen & Void
        await tester.tap(find.widgetWithText(ElevatedButton, 'Reopen & Void'));
        await tester.pumpAndSettle();

        // Verified: sale is now voided
        expect(find.text('VOIDED'), findsOneWidget);

        await cleanUpWidget(tester);
      },
    );

    test(
      'editSale rewrites items atomically and updates exact total and profit',
      () async {
        final now = DateTime.now();
        final saleResult = await saleRepo.completeSale(
          lines: [
            SaleLineInput(
              productId: 1,
              productName: 'Cardava',
              weight: Weight.fromGrams(1000),
              pricePerKgCentavos: 2500,
              capitalPerKgCentavos: 1800,
            ),
          ],
          chargedCentavos: 2500,
          paidCentavos: 3000,
          createdAt: now,
        );

        expect(saleResult.sale.exactTotalCentavos, equals(2500));
        expect(saleResult.items.length, equals(1));

        // Edit sale to 2000g at P25.00/kg (5000 centavos)
        final editedResult = await saleRepo.editSale(
          saleId: saleResult.sale.id,
          newLines: [
            SaleLineInput(
              productId: 1,
              productName: 'Cardava',
              weight: Weight.fromGrams(2000),
              pricePerKgCentavos: 2500,
              capitalPerKgCentavos: 1800,
            ),
          ],
          chargedCentavos: 5000,
          paidCentavos: 5000,
        );

        expect(editedResult.sale.exactTotalCentavos, equals(5000));
        expect(editedResult.sale.chargedCentavos, equals(5000));
        expect(editedResult.items.length, equals(1));
        expect(editedResult.items.first.grams, equals(2000));

        // Check with details
        final details = await saleRepo.getSalesWithDetails();
        expect(
          details.first.profitCentavos,
          equals(5000 - 3600),
        ); // 1400 centavos
      },
    );

    testWidgets(
      'shows Edited badge on edited sales and tapping it displays before/after audit history',
      (tester) async {
        final now = DateTime.now();
        final saleResult = await saleRepo.completeSale(
          lines: [
            SaleLineInput(
              productId: 1,
              productName: 'Cardava',
              weight: Weight.fromGrams(1000),
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 2000,
            ),
          ],
          chargedCentavos: 3000,
          paidCentavos: 3000,
          createdAt: now,
        );

        // Perform an edit
        await saleRepo.editSale(
          saleId: saleResult.sale.id,
          newLines: [
            SaleLineInput(
              originalItemId: saleResult.items.single.id,
              productId: 1,
              productName: 'Cardava',
              weight: Weight.fromGrams(1500),
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 2000,
            ),
          ],
          chargedCentavos: 4500,
          paidCentavos: 5000,
          reason: 'Added half kilo',
        );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // "Edited" badge should be visible on the card
        expect(find.text('Edited'), findsWidgets);

        // Tap the Edited badge to open SaleEditHistoryDialog
        await tester.tap(find.text('Edited').first);
        await tester.pumpAndSettle();

        // Audit modal dialog must display
        expect(
          find.text('Edit History: Sale #${saleResult.sale.id}'),
          findsOneWidget,
        );
        expect(find.text('Reason: Added half kilo'), findsOneWidget);
        expect(find.text('Before'), findsOneWidget);
        expect(find.text('After'), findsOneWidget);

        await cleanUpWidget(tester);
      },
    );

    testWidgets(
      'edit on locked day is blocked with "This day is paid out. Reopen it first." dialog',
      (tester) async {
        final now = DateTime.now();
        final saleResult = await saleRepo.completeSale(
          lines: [
            SaleLineInput(
              productId: 1,
              productName: 'Cardava',
              weight: Weight.fromGrams(1000),
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 2000,
            ),
          ],
          chargedCentavos: 3000,
          paidCentavos: 3000,
          createdAt: now,
        );

        // Lock the day
        await db
            .into(db.payouts)
            .insert(
              PayoutsCompanion.insert(
                date: DateTime(now.year, now.month, now.day),
                toParentsCentavos: 2000,
                salaryCentavos: 500,
                reserveCentavos: 500,
                locked: const Value(true),
              ),
            );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap the Edit button on the card
        await tester.tap(find.text('Edit').first);
        await tester.pumpAndSettle();

        // Guard dialog appears
        expect(find.text('Day Payout Locked'), findsOneWidget);
        expect(
          find.text('This day is paid out. Reopen it first.'),
          findsOneWidget,
        );
        expect(find.text('Reopen Day'), findsOneWidget);

        // Tap Reopen Day
        await tester.tap(find.widgetWithText(FilledButton, 'Reopen Day'));
        await tester.pumpAndSettle();

        // Verified: day is unlocked and EditSaleDialog opened
        expect(await saleRepo.isDayLocked(now), isFalse);
        expect(find.text('Edit Sale #${saleResult.sale.id}'), findsOneWidget);

        await cleanUpWidget(tester);
      },
    );

    testWidgets(
      'shows Edited badge on edited sales and tapping it displays before/after audit history',
      (tester) async {
        final now = DateTime.now();
        final saleResult = await saleRepo.completeSale(
          lines: [
            SaleLineInput(
              productId: 1,
              productName: 'Cardava',
              weight: Weight.fromGrams(1000),
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 2000,
            ),
          ],
          chargedCentavos: 3000,
          paidCentavos: 3000,
          createdAt: now,
        );

        // Perform an edit
        await saleRepo.editSale(
          saleId: saleResult.sale.id,
          newLines: [
            SaleLineInput(
              originalItemId: saleResult.items.single.id,
              productId: 1,
              productName: 'Cardava',
              weight: Weight.fromGrams(1500),
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 2000,
            ),
          ],
          chargedCentavos: 4500,
          paidCentavos: 5000,
          reason: 'Added half kilo',
        );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // "Edited" badge should be visible on the card
        expect(find.text('Edited'), findsWidgets);

        // Tap the Edited badge to open SaleEditHistoryDialog
        await tester.tap(find.text('Edited').first);
        await tester.pumpAndSettle();

        // Audit modal dialog must display
        expect(
          find.text('Edit History: Sale #${saleResult.sale.id}'),
          findsOneWidget,
        );
        expect(find.text('Reason: Added half kilo'), findsOneWidget);
        expect(find.text('Before'), findsOneWidget);
        expect(find.text('After'), findsOneWidget);

        await cleanUpWidget(tester);
      },
    );

    testWidgets(
      'edit on locked day is blocked with "This day is paid out. Reopen it first." dialog',
      (tester) async {
        final now = DateTime.now();
        final saleResult = await saleRepo.completeSale(
          lines: [
            SaleLineInput(
              productId: 1,
              productName: 'Cardava',
              weight: Weight.fromGrams(1000),
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 2000,
            ),
          ],
          chargedCentavos: 3000,
          paidCentavos: 3000,
          createdAt: now,
        );

        // Lock the day
        await db
            .into(db.payouts)
            .insert(
              PayoutsCompanion.insert(
                date: DateTime(now.year, now.month, now.day),
                toParentsCentavos: 2000,
                salaryCentavos: 500,
                reserveCentavos: 500,
                locked: const Value(true),
              ),
            );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap the Edit button on the card
        await tester.tap(find.text('Edit').first);
        await tester.pumpAndSettle();

        // Guard dialog appears
        expect(find.text('Day Payout Locked'), findsOneWidget);
        expect(
          find.text('This day is paid out. Reopen it first.'),
          findsOneWidget,
        );
        expect(find.text('Reopen Day'), findsOneWidget);

        // Tap Reopen Day
        await tester.tap(find.widgetWithText(FilledButton, 'Reopen Day'));
        await tester.pumpAndSettle();

        // Verified: day is unlocked and EditSaleDialog opened
        expect(await saleRepo.isDayLocked(now), isFalse);
        expect(find.text('Edit Sale #${saleResult.sale.id}'), findsOneWidget);

        await cleanUpWidget(tester);
      },
    );
  });
}
