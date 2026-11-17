import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// Repository responsible for daily settlement payouts and settings management.
class PayoutRepository {
  final AppDatabase _db;

  PayoutRepository(this._db);

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  /// Checks if a day's payout is locked.
  Future<bool> isDayLocked(DateTime date) async {
    final start = _startOfDay(date);
    final end = _endOfDay(date);

    final payout =
        await (_db.select(_db.payouts)..where(
              (p) =>
                  p.date.isBiggerOrEqualValue(start) &
                  p.date.isSmallerOrEqualValue(end) &
                  p.locked.equals(true),
            ))
            .get();

    return payout.isNotEmpty;
  }

  /// Retrieves the payout record for a specific day.
  Future<Payout?> getPayoutForDay(DateTime date) {
    final start = _startOfDay(date);
    final end = _endOfDay(date);

    return (_db.select(_db.payouts)..where(
          (p) =>
              p.date.isBiggerOrEqualValue(start) &
              p.date.isSmallerOrEqualValue(end),
        ))
        .getSingleOrNull();
  }

  /// Streams the payout record for a specific day.
  Stream<Payout?> watchPayoutForDay(DateTime date) {
    final start = _startOfDay(date);
    final end = _endOfDay(date);

    return (_db.select(_db.payouts)..where(
          (p) =>
              p.date.isBiggerOrEqualValue(start) &
              p.date.isSmallerOrEqualValue(end),
        ))
        .watchSingleOrNull();
  }

  /// Saves the settlement amounts for the day and marks the day as locked.
  Future<void> saveAndLockPayout({
    required DateTime date,
    required int toParentsCentavos,
    required int salaryCentavos,
    required int reserveCentavos,
  }) async {
    final start = _startOfDay(date);
    final end = _endOfDay(date);

    final existing =
        await (_db.select(_db.payouts)..where(
              (p) =>
                  p.date.isBiggerOrEqualValue(start) &
                  p.date.isSmallerOrEqualValue(end),
            ))
            .getSingleOrNull();

    if (existing != null) {
      if (existing.locked) {
        throw StateError(
          'Cannot modify locked payout for this date without unlocking it first.',
        );
      }
      await (_db.update(
        _db.payouts,
      )..where((p) => p.id.equals(existing.id))).write(
        PayoutsCompanion(
          toParentsCentavos: Value(toParentsCentavos),
          salaryCentavos: Value(salaryCentavos),
          reserveCentavos: Value(reserveCentavos),
          locked: const Value(true),
        ),
      );
    } else {
      await _db
          .into(_db.payouts)
          .insert(
            PayoutsCompanion.insert(
              date: date,
              toParentsCentavos: toParentsCentavos,
              salaryCentavos: salaryCentavos,
              reserveCentavos: reserveCentavos,
              locked: const Value(true),
            ),
          );
    }
  }

  /// Unlocks a day payout so sales or expenses can be modified or recalculated.
  Future<void> unlockDay(DateTime date) async {
    final start = _startOfDay(date);
    final end = _endOfDay(date);

    await (_db.update(_db.payouts)..where(
          (p) =>
              p.date.isBiggerOrEqualValue(start) &
              p.date.isSmallerOrEqualValue(end),
        ))
        .write(const PayoutsCompanion(locked: Value(false)));
  }

  /// Gets current system settings or seeds default if absent.
  Future<Setting> getSettings() async {
    final existing = await _db.select(_db.settings).getSingleOrNull();
    if (existing != null) return existing;

    // Seed default settings: percent mode, 30% (3000 bps)
    await _db
        .into(_db.settings)
        .insert(
          const SettingsCompanion(
            salaryMode: Value('percent'),
            salaryPercentBasisPoints: Value(3000),
            fixedDailySalaryCentavos: Value(0),
          ),
        );

    return (_db.select(_db.settings)).getSingle();
  }

  /// Streams current system settings.
  Stream<Setting> watchSettings() {
    return _db
        .select(_db.settings)
        .watchSingle()
        .asyncMap((setting) async {
          return setting;
        })
        .handleError((_) async* {
          // In case table is initially empty, ensure row is created
          yield await getSettings();
        });
  }

  /// Updates system salary settings.
  Future<void> updateSettings({
    required String salaryMode,
    required int salaryPercentBasisPoints,
    required int fixedDailySalaryCentavos,
  }) async {
    final current = await getSettings();
    await (_db.update(
      _db.settings,
    )..where((s) => s.id.equals(current.id))).write(
      SettingsCompanion(
        salaryMode: Value(salaryMode),
        salaryPercentBasisPoints: Value(salaryPercentBasisPoints),
        fixedDailySalaryCentavos: Value(fixedDailySalaryCentavos),
      ),
    );
  }
}
