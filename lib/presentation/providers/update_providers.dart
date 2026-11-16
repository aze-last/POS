import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/services/update_service.dart';

/// Provider for UpdateService singleton.
final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

/// Current installed version representation for UI display.
class InstalledVersionInfo {
  final String version;
  final String buildNumber;

  const InstalledVersionInfo({
    required this.version,
    required this.buildNumber,
  });

  String get displayString => 'Version $version (Build $buildNumber)';
}

/// Provider for installed application version details from platform package info.
final installedVersionProvider = FutureProvider<InstalledVersionInfo>((
  ref,
) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return InstalledVersionInfo(
      version: info.version,
      buildNumber: info.buildNumber,
    );
  } catch (_) {
    return const InstalledVersionInfo(version: '1.0.0', buildNumber: '1');
  }
});

/// Notifier managing available update state and checks.
class AvailableUpdateNotifier extends AsyncNotifier<ReleaseInfo?> {
  @override
  Future<ReleaseInfo?> build() async {
    // Initial auto-check throttled to 24 hours
    final service = ref.watch(updateServiceProvider);
    return service.checkForUpdate(isManual: false);
  }

  /// Manually checks for updates, ignoring the 24-hour throttle.
  Future<ReleaseInfo?> checkManual() async {
    state = const AsyncLoading();
    try {
      final service = ref.read(updateServiceProvider);
      final update = await service.checkForUpdate(isManual: true);
      state = AsyncData(update);
      return update;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Skips a specific version tag.
  Future<void> skipVersion(String tag) async {
    final service = ref.read(updateServiceProvider);
    await service.skipVersion(tag);
    state = const AsyncData(null);
  }

  /// Clears the current update state (e.g. when dismissed or postponed).
  void dismiss() {
    state = const AsyncData(null);
  }
}

final availableUpdateProvider =
    AsyncNotifierProvider<AvailableUpdateNotifier, ReleaseInfo?>(
      AvailableUpdateNotifier.new,
    );
