import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/backup_service.dart';
import 'database_provider.dart';

/// Provider for BackupService singleton bound to AppDatabase.
final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider);
  return BackupService(db);
});

/// Notifier tracking the latest database backup timestamp.
class LastBackupNotifier extends AsyncNotifier<DateTime?> {
  @override
  Future<DateTime?> build() async {
    final service = ref.watch(backupServiceProvider);
    return service.getLastBackupTime();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(backupServiceProvider);
      return service.getLastBackupTime();
    });
  }
}

final lastBackupTimeProvider =
    AsyncNotifierProvider<LastBackupNotifier, DateTime?>(
      LastBackupNotifier.new,
    );

/// Boolean provider indicating whether a weekly backup nudge banner is needed.
final backupNudgeNeededProvider = Provider<bool>((ref) {
  final lastBackupAsync = ref.watch(lastBackupTimeProvider);
  return lastBackupAsync.maybeWhen(
    data: (date) => BackupService.isNudgeNeeded(lastBackupDate: date),
    orElse: () => false,
  );
});
