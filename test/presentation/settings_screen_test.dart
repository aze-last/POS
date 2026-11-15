import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';
import 'package:pos/data/repositories/payout_repository.dart';
import 'package:pos/data/services/backup_service.dart';
import 'package:pos/presentation/providers/backup_providers.dart';
import 'package:pos/presentation/providers/database_provider.dart';
import 'package:pos/presentation/screens/settings/settings_screen.dart';

class TestBackupService extends BackupService {
  DateTime? lastBackup;
  bool shareCalled = false;
  bool restoreCalled = false;

  TestBackupService(super.db, {this.lastBackup});

  @override
  Future<DateTime?> getLastBackupTime() async => lastBackup;

  @override
  Future<void> shareBackupFile() async {
    shareCalled = true;
    lastBackup = DateTime.now();
  }

  @override
  Future<bool> pickAndRestoreBackupFile() async {
    restoreCalled = true;
    return true;
  }
}

void main() {
  late AppDatabase db;
  late PayoutRepository payoutRepo;
  late TestBackupService testBackupService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    payoutRepo = PayoutRepository(db);
    testBackupService = TestBackupService(db);
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestWidget({TestBackupService? backupService}) {
    final service = backupService ?? testBackupService;
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        backupServiceProvider.overrideWithValue(service),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    );
  }

  Future<void> cleanUpWidget(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('SettingsScreen & BackupView Widget Tests', () {
    testWidgets(
      'renders default settings and weekly backup reminder when unbacked',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Settings & Backup'), findsOneWidget);
        expect(find.text('Daily Salary Calculation Mode'), findsOneWidget);
        expect(find.text('% of Net Profit'), findsOneWidget);
        expect(find.text('Fixed Daily (₱)'), findsOneWidget);

        // Default percent is 30%
        expect(find.text('30'), findsOneWidget);

        // Weekly backup reminder banner
        expect(find.text('Weekly Backup Recommended'), findsOneWidget);
        expect(find.text('Export & Share Backup'), findsOneWidget);
        expect(find.text('Restore from Backup File'), findsOneWidget);

        await cleanUpWidget(tester);
      },
    );

    testWidgets('saves updated salary percent in database', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Clear percent and type 35
      final percentField = find.widgetWithText(
        TextFormField,
        'Salary Percentage (%)',
      );
      expect(percentField, findsOneWidget);
      await tester.enterText(percentField, '35');
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save Salary Mode'));
      await tester.pumpAndSettle();

      // Verify SnackBar
      expect(find.text('Salary settings saved successfully!'), findsOneWidget);

      // Verify DB settings
      final setting = await payoutRepo.getSettings();
      expect(setting.salaryMode, equals('percent'));
      expect(setting.salaryPercentBasisPoints, equals(3500));

      await cleanUpWidget(tester);
    });

    testWidgets('switches to fixed daily salary mode and saves centavos', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap 'Fixed Daily (₱)' segment
      await tester.tap(find.text('Fixed Daily (₱)'));
      await tester.pumpAndSettle();

      // Enter 450.50 pesos
      final fixedField = find.widgetWithText(
        TextFormField,
        'Fixed Daily Salary (₱)',
      );
      expect(fixedField, findsOneWidget);
      await tester.enterText(fixedField, '450.50');
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save Salary Mode'));
      await tester.pumpAndSettle();

      expect(find.text('Salary settings saved successfully!'), findsOneWidget);

      final setting = await payoutRepo.getSettings();
      expect(setting.salaryMode, equals('fixed'));
      expect(setting.fixedDailySalaryCentavos, equals(45050));

      await cleanUpWidget(tester);
    });

    testWidgets('triggers export and refreshes status', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Scroll to reveal backup buttons
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Export & Share Backup'));
      await tester.pumpAndSettle();

      expect(testBackupService.shareCalled, isTrue);
      expect(find.text('Backup file ready and shared!'), findsOneWidget);

      await cleanUpWidget(tester);
    });

    testWidgets(
      'restores database only upon explicit confirmation in warning dialog',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Scroll to reveal backup buttons
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -400),
        );
        await tester.pumpAndSettle();

        // 1. Tap restore button
        await tester.tap(find.text('Restore from Backup File'));
        await tester.pumpAndSettle();

        // 2. Verify warning dialog content
        expect(find.text('Restore Database?'), findsOneWidget);
        expect(
          find.textContaining(
            'Restoring will OVERWRITE and completely replace',
          ),
          findsOneWidget,
        );

        // 3. Cancel first
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(testBackupService.restoreCalled, isFalse);

        // 4. Open dialog again and confirm
        await tester.tap(find.text('Restore from Backup File'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Yes, Overwrite & Restore'));
        await tester.pumpAndSettle();

        expect(testBackupService.restoreCalled, isTrue);
        expect(find.text('Database successfully restored!'), findsOneWidget);

        await cleanUpWidget(tester);
      },
    );
  });
}
