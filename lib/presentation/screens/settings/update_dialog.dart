import 'dart:async';
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

class _UpdateDialogState extends ConsumerState<UpdateDialog>
    with WidgetsBindingObserver {
  bool _isProcessing = false;
  bool _isDownloading = false;
  bool _isCancelled = false;
  double _progress = 0.0;
  String _statusText = '';
  String? _errorMessage;
  Completer<void>? _resumeCompleter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_resumeCompleter != null && !_resumeCompleter!.isCompleted) {
        _resumeCompleter!.complete();
      }
    }
  }

  Future<void> _handleUpdateFlow() async {
    // 0. Re-entrancy guard before first await (p7-12)
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

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

      // 3. Android unknown app installation permission check (p7-4)
      bool canInstall = await AppInstaller.canRequestPackageInstalls();
      if (!canInstall && mounted) {
        final opened = await showDialog<bool>(
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
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );

        if (opened == true && mounted) {
          _resumeCompleter = Completer<void>();
          await AppInstaller.openInstallPermissionSettings();
          // Wait for app resume from settings before re-checking (p7-4)
          await _resumeCompleter!.future.timeout(
            const Duration(minutes: 5),
            onTimeout: () {},
          );
          if (mounted) {
            canInstall = await AppInstaller.canRequestPackageInstalls();
          }
        }

        if (!canInstall) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Install permission was not granted. Please allow unknown apps to install update.';
              _isDownloading = false;
              _isProcessing = false;
            });
          }
          return;
        }
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

      // 4. Trigger system installer and treat false as error (p7-1)
      final installSuccess = await AppInstaller.installApk(downloadedFile.path);
      if (!installSuccess) {
        throw Exception('Package installer could not be launched.');
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _isCancelled
              ? 'Download cancelled by user.'
              : 'Update failed: $e';
          _isDownloading = false;
          _isProcessing = false;
        });
      }
    }
    // Note: Do NOT delete downloaded APK here; system installer needs to read it (p7-1).
    // cleanOldUpdateFiles() runs at next startup.
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      // Persistent failure state in dialog (p7-16)
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.dangerColor),
            SizedBox(width: 8),
            Text('Update Failed'),
          ],
        ),
        content: Text(_errorMessage!),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _isDownloading = false;
                _isProcessing = false;
                _progress = 0.0;
              });
              _handleUpdateFlow();
            },
            child: const Text('Retry'),
          ),
        ],
      );
    }

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
                _statusText = 'Cancelling download...';
              });
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    }

    final release = widget.release;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.system_update_alt, color: AppTheme.accentGreen),
          const SizedBox(width: 8),
          Text('New Version Available: ${release.rawTag}'),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Installed: v${widget.currentVersion}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    Text(
                      'Latest: ${release.rawTag}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Release Notes:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                constraints: const BoxConstraints(maxHeight: 180),
                child: SingleChildScrollView(
                  child: Text(
                    release.releaseNotes,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await ref
                .read(updateServiceProvider)
                .skipVersion(widget.release.rawTag);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Skip this version'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Later'),
        ),
        ElevatedButton(
          onPressed: _handleUpdateFlow,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentGreen,
            foregroundColor: Colors.white,
          ),
          child: const Text('Update Now'),
        ),
      ],
    );
  }
}
