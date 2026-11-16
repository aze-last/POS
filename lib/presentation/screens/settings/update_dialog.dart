import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/services/app_installer.dart';
import '../../../data/services/update_service.dart';
import '../../providers/backup_providers.dart';
import '../../providers/update_providers.dart';
import '../../theme/app_theme.dart';

/// Modal dialog prompting the user about an available update.
class UpdateDialog extends ConsumerStatefulWidget {
  final ReleaseInfo release;
  final String currentVersion;

  const UpdateDialog({
    super.key,
    required this.release,
    required this.currentVersion,
  });

  /// Helper static method to display the update dialog.
  static Future<void> show(
    BuildContext context, {
    required ReleaseInfo release,
    required String currentVersion,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          UpdateDialog(release: release, currentVersion: currentVersion),
    );
  }

  @override
  ConsumerState<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends ConsumerState<UpdateDialog> {
  bool _isDownloading = false;
  bool _isCancelled = false;
  double _progress = 0.0;
  String _statusText = '';

  Future<void> _handleUpdateFlow() async {
    // 1. Prompt optional backup export
    final shouldExport = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.backup_outlined, color: AppTheme.primaryDark),
            SizedBox(width: 8),
            Text('Export Backup First?'),
          ],
        ),
        content: const Text(
          'Before installing the update, would you like to export an offline database backup? '
          'This guarantees your sales and products remain secure.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continue Without Backup'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Export Backup Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryDark,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (shouldExport == true && mounted) {
      try {
        final backupService = ref.read(backupServiceProvider);
        await backupService.shareBackupFile();
        await ref.read(lastBackupTimeProvider.notifier).refresh();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Backup export error: $e'),
              backgroundColor: AppTheme.dangerColor,
            ),
          );
        }
      }
    }

    if (!mounted) return;

    // 2. Start Download with Progress
    setState(() {
      _isDownloading = true;
      _isCancelled = false;
      _progress = 0.0;
      _statusText = 'Starting download...';
    });

    File? downloadedFile;
    try {
      final updateService = ref.read(updateServiceProvider);
      downloadedFile = await updateService.downloadAndVerifyUpdate(
        release: widget.release,
        onProgress: (received, total) {
          if (mounted && !_isCancelled) {
            setState(() {
              _progress = total > 0 ? (received / total).clamp(0.0, 1.0) : 0.0;
              final mbReceived = (received / (1024 * 1024)).toStringAsFixed(1);
              final mbTotal = (total / (1024 * 1024)).toStringAsFixed(1);
              _statusText =
                  'Downloading: $mbReceived MB / $mbTotal MB (${(_progress * 100).toInt()}%)';
            });
          }
        },
        isCancelled: () => _isCancelled,
      );

      if (!mounted) return;

      // 3. Android unknown app installation permission check
      final canInstall = await AppInstaller.canRequestPackageInstalls();
      if (!canInstall && mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.security, color: AppTheme.warningAmber),
                SizedBox(width: 8),
                Text('Permission Required'),
              ],
            ),
            content: const Text(
              'Android requires permission to "Install unknown apps" to update Banana POS.\n\n'
              'Please allow installation for Banana POS in system settings, then return to complete the update.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  AppInstaller.openInstallPermissionSettings();
                  Navigator.of(ctx).pop();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }

      if (!mounted) return;

      // Inform user that Android will show its own native installation prompt
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Android will prompt you to confirm installation. Tap "Install" to proceed.',
          ),
          duration: Duration(seconds: 4),
          backgroundColor: AppTheme.accentGreen,
        ),
      );

      // 4. Trigger system installer
      await AppInstaller.installApk(downloadedFile.path);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    } finally {
      // Delete downloaded APK after install attempt per spec
      if (downloadedFile != null && await downloadedFile.exists()) {
        try {
          await downloadedFile.delete();
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDownloading) {
      return AlertDialog(
        title: const Text('Downloading Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: _progress > 0 ? _progress : null,
              backgroundColor: AppTheme.borderSubtle,
              color: AppTheme.primaryDark,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 14),
            Text(
              _statusText,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Checksum will be cryptographically verified against SHA-256 before installation.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isCancelled = true;
                _isDownloading = false;
              });
            },
            child: const Text(
              'Cancel Download',
              style: TextStyle(color: AppTheme.dangerColor),
            ),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.system_update_rounded,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Text('Update Available')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.warningAmber, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Color(0xFF92400E),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'v${widget.currentVersion}  ➔  ${widget.release.rawTag}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF92400E),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Release Notes:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderSubtle, width: 1),
              ),
              child: Text(
                widget.release.releaseNotes,
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref
                .read(availableUpdateProvider.notifier)
                .skipVersion(widget.release.rawTag);
            Navigator.of(context).pop();
          },
          child: const Text(
            'Skip this version',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () {
            ref.read(availableUpdateProvider.notifier).dismiss();
            Navigator.of(context).pop();
          },
          child: const Text('Later'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryDark,
            foregroundColor: Colors.white,
          ),
          onPressed: _handleUpdateFlow,
          child: const Text('Update Now'),
        ),
      ],
    );
  }
}
