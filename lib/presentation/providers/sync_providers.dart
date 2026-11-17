import 'dart:async';

import 'package:flutter/widgets.dart';
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
  Timer? _autoSyncTimer;
  AppLifecycleListener? _lifecycleListener;
  bool _isAutoSyncing = false;

  @override
  SyncStateInfo build() {
    final service = ref.watch(syncServiceProvider);

    ref.onDispose(() {
      _autoSyncTimer?.cancel();
      _lifecycleListener?.dispose();
    });

    if (service.isConfigured) {
      _initAutoSync();
    }

    return service.currentState;
  }

  void _initAutoSync() {
    _autoSyncTimer?.cancel();
    _lifecycleListener?.dispose();

    // 1. Initial background sync attempt when app loads
    Future.microtask(() => syncSilently());

    // 2. Periodic background auto-sync every 30 seconds
    _autoSyncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      syncSilently();
    });

    // 3. Auto-sync whenever the app comes back to foreground (e.g. phone unlock)
    _lifecycleListener = AppLifecycleListener(onResume: () => syncSilently());
  }

  /// Triggers an immediate silent background sync (e.g. after completing a sale,
  /// adding an expense, editing a product, or recording a payout).
  Future<void> triggerAutoSync() async {
    await syncSilently();
  }

  /// Performs a background sync without showing blocking UI or interrupting
  /// the user if offline.
  Future<void> syncSilently() async {
    final service = ref.read(syncServiceProvider);
    if (!service.isConfigured) return;
    if (_isAutoSyncing || state.status == SyncStatus.syncing) return;

    _isAutoSyncing = true;
    try {
      final result = await service.sync();
      state = result;
    } catch (_) {
      // Silently catch in auto-sync so stall operations are never interrupted
    } finally {
      _isAutoSyncing = false;
    }
  }

  /// Explicit user-initiated sync (e.g. tapping "Sync Now" in Settings).
  Future<void> syncNow() async {
    state = const SyncStateInfo(status: SyncStatus.syncing);
    final service = ref.read(syncServiceProvider);
    final result = await service.sync();
    state = result;
  }
}
