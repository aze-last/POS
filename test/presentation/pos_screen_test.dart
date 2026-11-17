import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';
import 'package:pos/presentation/providers/database_provider.dart';
import 'package:pos/presentation/screens/pos/pos_screen.dart';
import 'package:pos/presentation/widgets/product_image_widget.dart';
import 'package:pos/presentation/widgets/stall_keypad.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestWidget(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: PosScreen()),
    );
  }

  Future<void> cleanUpWidget(WidgetTester tester) async {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('PosScreen & Checkout Flow Widget Tests', () {
    testWidgets('renders product grid and weighing bottom sheet', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(tester));
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Banana POS'), findsOneWidget);

      // Verify grid items and product images
      expect(find.text('Cardava'), findsOneWidget);
      expect(find.text('Binanggay'), findsOneWidget);
      expect(find.byType(ProductImageWidget), findsWidgets);

      // Tap on Cardava to open WeighingBottomSheet
      await tester.tap(find.text('Cardava'));
      await tester.pumpAndSettle();

      // Weighing sheet should be open with product photo and controls
      expect(find.byType(ProductImageWidget), findsWidgets);
      expect(find.text('Enter Weight (kg and grams):'), findsOneWidget);
      expect(find.text('+0.5 kg (500g)'), findsOneWidget);
      expect(find.text('Add to Cart'), findsOneWidget);

      // Tap Add to Cart
      await tester.ensureVisible(find.text('Add to Cart'));
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
        await tester.pumpWidget(buildTestWidget(tester));
        await tester.pumpAndSettle();

        // 1. Add Cardava to cart
        await tester.tap(find.text('Cardava'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Add to Cart'));
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

    testWidgets(
      'scale-style stall keypad fast typing: 1 . 3 5 -> 1.350 kg @ P30/kg = P40.50',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(tester));
        await tester.pumpAndSettle();

        // Open WeighingBottomSheet for Cardava
        await tester.tap(find.text('Cardava'));
        await tester.pumpAndSettle();

        // Find keypad keys
        expect(find.byType(StallKeypad), findsOneWidget);

        // Tap '1', '•', '3', '5'
        await tester.ensureVisible(find.widgetWithText(InkWell, '1'));
        await tester.tap(find.widgetWithText(InkWell, '1'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.widgetWithText(InkWell, '•'));
        await tester.tap(find.widgetWithText(InkWell, '•'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.widgetWithText(InkWell, '3'));
        await tester.tap(find.widgetWithText(InkWell, '3'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.widgetWithText(InkWell, '5'));
        await tester.tap(find.widgetWithText(InkWell, '5'));
        await tester.pumpAndSettle();

        // Verify parsed weight is 1.350 kg (1350 grams)
        expect(find.text('1.350 kg'), findsOneWidget);
        expect(find.text('(1350 grams)'), findsOneWidget);

        // Verify calculated total: 1350g @ 30.00/kg = P40.50
        expect(find.text('P40.50'), findsOneWidget);

        // Tap Add to Cart
        await tester.ensureVisible(find.text('Add to Cart'));
        await tester.tap(find.text('Add to Cart'));
        await tester.pumpAndSettle();

        // Verify cart has item with P40.50
        expect(find.text('1 item'), findsOneWidget);
        expect(find.text('Total: P40.50'), findsOneWidget);

        await cleanUpWidget(tester);
      },
    );

    testWidgets('stall keypad backspace and clear work properly', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(tester));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cardava'));
      await tester.pumpAndSettle();

      // Type '2'
      await tester.ensureVisible(find.widgetWithText(InkWell, '2'));
      await tester.tap(find.widgetWithText(InkWell, '2'));
      await tester.pumpAndSettle();
      expect(find.text('2.000 kg'), findsOneWidget);

      // Tap Clear
      await tester.ensureVisible(find.text('Clear'));
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();
      expect(find.text('0.000 kg'), findsOneWidget);

      // Type 5, 0, 0 (stream 500 grams)
      await tester.ensureVisible(find.widgetWithText(InkWell, '5'));
      await tester.tap(find.widgetWithText(InkWell, '5'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(InkWell, '0'));
      await tester.tap(find.widgetWithText(InkWell, '0'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(InkWell, '0'));
      await tester.tap(find.widgetWithText(InkWell, '0'));
      await tester.pumpAndSettle();

      expect(find.text('0.500 kg'), findsOneWidget);
      expect(find.text('(500 grams)'), findsOneWidget);

      // Tap backspace icon
      await tester.ensureVisible(find.byIcon(Icons.backspace_outlined));
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pumpAndSettle();

      // Stream becomes '50' -> 50 kg (2 digits)
      expect(find.text('50.000 kg'), findsOneWidget);

      await cleanUpWidget(tester);
    });
  });
}
