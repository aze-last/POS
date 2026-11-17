import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';
import 'package:pos/presentation/providers/database_provider.dart';
import 'package:pos/presentation/screens/products/products_screen.dart';
import 'package:pos/presentation/widgets/product_image_widget.dart';

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
      child: const MaterialApp(home: ProductsScreen()),
    );
  }

  Future<void> cleanUpWidget(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('ProductsScreen Widget Tests', () {
    testWidgets('renders active products with prominent capital display', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify app bar title
      expect(find.text('Banana Catalog'), findsOneWidget);

      // Verify tabs
      expect(find.text('Active (6)'), findsOneWidget);
      expect(find.text('Archived (0)'), findsOneWidget);

      // Verify starter products rendered with image widget
      expect(find.text('Cardava'), findsOneWidget);
      expect(find.text('Binanggay'), findsOneWidget);
      expect(find.text('Tundan'), findsOneWidget);
      expect(find.byType(ProductImageWidget), findsWidgets);

      // Verify prominent capital display
      expect(find.text('Capital: P20.00/kg'), findsWidgets); // Cardava capital
      expect(find.text('Sell: P30.00/kg'), findsWidgets);

      await cleanUpWidget(tester);
    });

    testWidgets(
      'archive opens confirmation dialog and moves item to archived tab',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Find archive button for Cardava (first archive icon)
        final archiveButtons = find.byTooltip('Archive');
        expect(archiveButtons, findsWidgets);

        await tester.tap(archiveButtons.first);
        await tester.pumpAndSettle();

        // Verify confirmation dialog appeared
        expect(find.text('Archive Cardava?'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);

        // Tap confirm "Archive" in dialog
        final confirmBtn = find.widgetWithText(ElevatedButton, 'Archive');
        await tester.tap(confirmBtn);
        await tester.pumpAndSettle();

        // Verify Cardava is no longer in active tab
        expect(find.text('Active (5)'), findsOneWidget);
        expect(find.text('Archived (1)'), findsOneWidget);

        // Switch to Archived tab
        await tester.tap(find.text('Archived (1)'));
        await tester.pumpAndSettle();

        // Verify Cardava is present in Archived tab with Restore button
        expect(find.text('Cardava'), findsOneWidget);
        expect(find.text('Restore'), findsOneWidget);

        // Tap Restore
        await tester.tap(find.text('Restore'));
        await tester.pumpAndSettle();

        // Verify counts updated
        expect(find.text('Active (6)'), findsOneWidget);
        expect(find.text('Archived (0)'), findsOneWidget);

        await cleanUpWidget(tester);
      },
    );

    testWidgets('tapping capital history button opens history sheet', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final historyButtons = find.byTooltip('Capital History');
      expect(historyButtons, findsWidgets);

      await tester.tap(historyButtons.first);
      await tester.pumpAndSettle();

      // Bottom sheet header
      expect(find.text('Cardava Capital History'), findsOneWidget);
      expect(find.text('Active Capital: P20.00/kg'), findsOneWidget);
      expect(
        find.text(
          'No capital adjustments yet.\nCurrent capital was set at creation.',
        ),
        findsOneWidget,
      );

      await cleanUpWidget(tester);
    });

    testWidgets('adds a new product variety through FAB', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Active (6)'), findsOneWidget);

      // Tap Add Variety FAB
      final fab = find.widgetWithText(FloatingActionButton, 'Add Variety');
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Form should be visible
      expect(find.text('Add Banana Variety'), findsOneWidget);

      // Enter name, price, capital
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(3));

      await tester.enterText(textFields.at(0), 'Latundan Special');
      await tester.enterText(textFields.at(1), '45.00');
      await tester.enterText(textFields.at(2), '30.00');
      await tester.pumpAndSettle();

      // Tap Save
      final saveBtn = find.widgetWithText(ElevatedButton, 'Add to Catalog');
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Verify new variety count updated and scroll to see it
      expect(find.text('Active (7)'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Latundan Special'), 100);
      expect(find.text('Latundan Special'), findsOneWidget);

      await cleanUpWidget(tester);
    });

    testWidgets('edits an existing product variety', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Cardava row to edit
      await tester.tap(find.text('Cardava'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Banana Variety'), findsOneWidget);

      final textFields = find.byType(TextFormField);
      // Change price to 35.00
      await tester.enterText(textFields.at(1), '35.00');
      await tester.pumpAndSettle();

      final saveBtn = find.widgetWithText(ElevatedButton, 'Save Changes');
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Verify updated price in list
      expect(find.text('Sell: P35.00/kg'), findsWidgets);

      await cleanUpWidget(tester);
    });

    testWidgets('reorders active products via drag and drop', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final dragHandles = find.byIcon(Icons.drag_indicator);
      expect(dragHandles, findsWidgets);

      // Drag first item below second item
      final firstHandle = dragHandles.first;
      await tester.drag(firstHandle, const Offset(0, 100));
      await tester.pumpAndSettle();

      expect(find.text('Active (6)'), findsOneWidget);

      await cleanUpWidget(tester);
    });
  });
}
