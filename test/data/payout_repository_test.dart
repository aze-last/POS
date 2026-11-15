import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';
import 'package:pos/data/repositories/payout_repository.dart';

void main() {
  late AppDatabase db;
  late PayoutRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = PayoutRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('PayoutRepository Tests', () {
    final today = DateTime(2026, 11, 15);

    test('saves and locks payout for a day', () async {
      await repository.saveAndLockPayout(
        date: today,
        toParentsCentavos: 350000,
        salaryCentavos: 45000,
        reserveCentavos: 105000,
      );

      final payout = await repository.getPayoutForDay(today);
      expect(payout, isNotNull);
      expect(payout!.toParentsCentavos, 350000);
      expect(payout.salaryCentavos, 45000);
      expect(payout.reserveCentavos, 105000);
      expect(payout.locked, isTrue);

      final isLocked = await repository.isDayLocked(today);
      expect(isLocked, isTrue);
    });

    test('reopens/unlocks day payout', () async {
      await repository.saveAndLockPayout(
        date: today,
        toParentsCentavos: 350000,
        salaryCentavos: 45000,
        reserveCentavos: 105000,
      );

      await repository.unlockDay(today);
      final isLocked = await repository.isDayLocked(today);
      expect(isLocked, isFalse);

      final payout = await repository.getPayoutForDay(today);
      expect(payout!.locked, isFalse);
    });

    test('reads and updates settings', () async {
      final defaultSettings = await repository.getSettings();
      expect(defaultSettings.salaryMode, 'percent');
      expect(defaultSettings.salaryPercentBasisPoints, 3000);

      await repository.updateSettings(
        salaryMode: 'fixed',
        salaryPercentBasisPoints: 2500,
        fixedDailySalaryCentavos: 50000,
      );

      final updated = await repository.getSettings();
      expect(updated.salaryMode, 'fixed');
      expect(updated.salaryPercentBasisPoints, 2500);
      expect(updated.fixedDailySalaryCentavos, 50000);
    });
  });
}
