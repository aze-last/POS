import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/sync_service.dart';
import 'database_provider.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncService(db);
});

final syncStateProvider = NotifierProvider<SyncNotifier, SyncStateInfo>(
  SyncNotifier.new,
);

class SyncNotifier extends Notifier<SyncStateInfo> {
  @override
  SyncStateInfo build() {
    final service = ref.watch(syncServiceProvider);
    return service.currentState;
  }

  Future<void> syncNow() async {
    state = const SyncStateInfo(status: SyncStatus.syncing);
    final service = ref.read(syncServiceProvider);
    final result = await service.sync();
    state = result;
  }
}
