import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';
import 'package:pos/data/repositories/restock_repository.dart';
import 'package:pos/presentation/providers/database_provider.dart';
import 'package:pos/presentation/screens/parents/parents_balance_screen.dart';

void main() {
  late AppDatabase db;
  late RestockRepository restockRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    restockRepo = RestockRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: ParentsBalanceScreen()),
    );
  }

  Future<void> cleanUpWidget(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('ParentsBalanceScreen Widget Tests', () {
    testWidgets('renders balance ledger and adds restock purchase', (
      tester,
    ) async {
      // Locked payout (returned to parents P2,000.00)
      await db
          .into(db.payouts)
          .insert(
            PayoutsCompanion.insert(
              date: DateTime(2026, 11, 10),
              toParentsCentavos: 200000,
              salaryCentavos: 50000,
              reserveCentavos: 10000,
              locked: const Value(true),
            ),
          );

      // Existing restock purchase P5,000.00
      await restockRepo.addRestockPurchase(
        date: DateTime(2026, 11, 10),
        amountCentavos: 500000,
        note: 'Davao shipment',
      );

      // Outstanding balance: 5,000 - 2,000 = P3,000.00
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text("Parents' Balance Ledger"), findsOneWidget);
      expect(find.text('OUTSTANDING BALANCE OWED'), findsOneWidget);
      expect(find.text('P3,000.00'), findsOneWidget);
      expect(
        find.text('P5,000.00'),
        findsWidgets,
      ); // restock spend and entry row
      expect(find.text('P2,000.00'), findsOneWidget); // returned

      // Add another restock purchase: P1,000.00
      await tester.tap(find.text('Add Restock Purchase'));
      await tester.pumpAndSettle();

      expect(find.text('Add Restock Purchase'), findsWidgets);
      await tester.tap(find.text('P1000'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Purchase'));
      await tester.pumpAndSettle();

      // Now outstanding balance = 6,000 - 2,000 = P4,000.00
      expect(find.text('P4,000.00'), findsOneWidget);
      expect(find.text('P6,000.00'), findsOneWidget);

      await cleanUpWidget(tester);
    });

    testWidgets('deletes restock purchase with confirmation', (tester) async {
      await restockRepo.addRestockPurchase(
        date: DateTime.now(),
        amountCentavos: 250000,
        note: 'Binanggay crate',
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('P2,500.00'), findsWidgets);

      // Tap delete
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Delete Restock Purchase?'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('P0.00'), findsWidgets);

      await cleanUpWidget(tester);
    });

    testWidgets(
      'displays weekly overview card with amount to parents and salary and navigates to weekly summary',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Verify weekly overview card is rendered
        expect(find.text('AMOUNT TO PARENTS'), findsOneWidget);
        expect(find.text('YOUR SALARY THIS WEEK'), findsOneWidget);
        expect(find.text('View Full Weekly Breakdown'), findsOneWidget);

        // Tap "View Full Weekly Breakdown"
        await tester.tap(find.text('View Full Weekly Breakdown'));
        await tester.pumpAndSettle();

        // Should now be on Weekly Summary screen
        expect(find.text('Weekly Summary'), findsOneWidget);
        expect(find.text('TOTAL TO PARENTS'), findsOneWidget);
        expect(find.text('MY TOTAL SALARY'), findsOneWidget);

        await cleanUpWidget(tester);
      },
    );
  });
}
