import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';
import 'package:pos/presentation/providers/database_provider.dart';
import 'package:pos/presentation/screens/pos/pos_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: PosScreen()),
    );
  }

  Future<void> cleanUpWidget(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('PosScreen & Checkout Flow Widget Tests', () {
    testWidgets('renders product grid and weighing bottom sheet', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Banana POS'), findsOneWidget);

      // Verify grid items
      expect(find.text('Cardava'), findsOneWidget);
      expect(find.text('Binanggay'), findsOneWidget);

      // Tap on Cardava to open WeighingBottomSheet
      await tester.tap(find.text('Cardava'));
      await tester.pumpAndSettle();

      // Weighing sheet should be open
      expect(find.text('Enter Weight (kg and grams):'), findsOneWidget);
      expect(find.text('+0.5 kg (500g)'), findsOneWidget);
      expect(find.text('Add to Cart'), findsOneWidget);

      // Tap Add to Cart
      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      // Verify persistent bottom cart bar appears with 1 item
      expect(find.text('1 item'), findsOneWidget);
      expect(find.text('Total: P30.00'), findsOneWidget);

      await cleanUpWidget(tester);
    });

    testWidgets(
      'full checkout flow: weighing -> cart -> quick cash -> receipt',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // 1. Add Cardava to cart
        await tester.tap(find.text('Cardava'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add to Cart'));
        await tester.pumpAndSettle();

        // 2. Open cart sheet
        await tester.tap(find.text('Total: P30.00'));
        await tester.pumpAndSettle();

        expect(find.text('Current Cart (1)'), findsOneWidget);
        expect(find.text('Exact Total:'), findsOneWidget);

        // 3. Tap Quick Cash "P50"
        await tester.tap(find.text('P50'));
        await tester.pumpAndSettle();

        // Verify change calculation: 50.00 - 30.00 = P20.00
        expect(find.text('CHANGE DUE:'), findsOneWidget);
        expect(find.text('P20.00'), findsOneWidget);

        // 4. Tap "Complete Sale"
        final completeBtn = find.widgetWithText(
          ElevatedButton,
          'Complete Sale',
        );
        await tester.tap(completeBtn);
        await tester.pumpAndSettle();

        // 5. Verify ReceiptDialog appeared
        expect(find.text('Sale Complete'), findsOneWidget);
        expect(find.text('CHANGE DUE'), findsOneWidget);
        expect(find.text('Done · New Sale'), findsOneWidget);

        // Close receipt
        await tester.tap(find.text('Done · New Sale'));
        await tester.pumpAndSettle();

        // Cart bar should now be gone because cart is empty
        expect(find.text('1 item'), findsNothing);

        await cleanUpWidget(tester);
      },
    );
  });
}
