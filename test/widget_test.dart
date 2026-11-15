import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:pos/main.dart';
import 'package:pos/presentation/providers/database_provider.dart';
import 'package:pos/data/database/app_database.dart';

void main() {
  testWidgets('BananaPosApp smoke test renders POS storefront', (
    WidgetTester tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const BananaPosApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify storefront header and products
    expect(find.text('Banana POS'), findsOneWidget);
    expect(find.text('Cardava'), findsOneWidget);
    expect(find.text('Binanggay'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));

    await db.close();
  });
}
