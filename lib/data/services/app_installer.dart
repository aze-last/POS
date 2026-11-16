import 'package:flutter/services.dart';

/// Platform channel bridge to Android package installer via FileProvider.
class AppInstaller {
  static const MethodChannel _channel = MethodChannel(
    'com.banana.pos/app_installer',
  );

  /// Checks if the app is granted permission to request package installs (Android 8.0+).
  static Future<bool> canRequestPackageInstalls() async {
    try {
      final bool? canInstall = await _channel.invokeMethod<bool>(
        'canRequestPackageInstalls',
      );
      return canInstall ?? true;
    } on MissingPluginException {
      // In test or non-Android environments
      return true;
    } catch (_) {
      return true;
    }
  }

  /// Deep-links directly to Android "Install unknown apps" settings page for this app.
  static Future<void> openInstallPermissionSettings() async {
    try {
      await _channel.invokeMethod('openInstallPermissionSettings');
    } catch (_) {
      // Ignored
    }
  }

  /// Triggers the Android system package installer intent using the FileProvider content URI.
  static Future<bool> installApk(String filePath) async {
    try {
      final bool? success = await _channel.invokeMethod<bool>('installApk', {
        'filePath': filePath,
      });
      return success ?? false;
    } on PlatformException catch (e) {
      throw Exception('Package installer error: ${e.message}');
    }
  }
}
