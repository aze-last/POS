import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';
import 'package:pos/presentation/providers/database_provider.dart';
import 'package:pos/presentation/screens/products/products_screen.dart';

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

      // Verify starter products rendered
      expect(find.text('Cardava'), findsOneWidget);
      expect(find.text('Binanggay'), findsOneWidget);
      expect(find.text('Tundan'), findsOneWidget);

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
  });
}
