import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/backup_providers.dart';
import '../../providers/cart_provider.dart';
import '../../providers/payout_providers.dart';
import '../../providers/product_providers.dart';
import '../../theme/app_theme.dart';

/// Backup & Restore management widget.
///
/// Features:
/// - Clear last backup timestamp with weekly nudge indicator.
/// - Single-tap export and system share sheet invocation.
/// - Safe restore with mandatory destructive confirmation dialog.
class BackupView extends ConsumerStatefulWidget {
  const BackupView({super.key});

  @override
  ConsumerState<BackupView> createState() => _BackupViewState();
}

class _BackupViewState extends ConsumerState<BackupView> {
  bool _isExporting = false;
  bool _isRestoring = false;

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    try {
      final backupService = ref.read(backupServiceProvider);
      await backupService.shareBackupFile();
      await ref.read(lastBackupTimeProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup file ready and shared!'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _handleRestore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.dangerColor,
              size: 28,
            ),
            SizedBox(width: 8),
            Expanded(child: Text('Restore Database?')),
          ],
        ),
        content: const Text(
          'Restoring will OVERWRITE and completely replace all existing products, '
          'sales, expenses, and records with data from the backup file.\n\n'
          'This action CANNOT be undone.\n\n'
          'Are you sure you want to proceed?',
          style: TextStyle(fontSize: 15, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes, Overwrite & Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRestoring = true);
    try {
      final backupService = ref.read(backupServiceProvider);
      final restored = await backupService.pickAndRestoreBackupFile();

      if (!mounted) return;

      if (restored) {
        // Refresh core providers so that the entire UI reflects the newly loaded database
        ref.invalidate(lastBackupTimeProvider);
        ref.invalidate(settingsStreamProvider);
        ref.invalidate(activeProductsProvider);
        ref.invalidate(archivedProductsProvider);
        ref.invalidate(cartProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database successfully restored!'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restore cancelled (no file selected).'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastBackupAsync = ref.watch(lastBackupTimeProvider);
    final nudgeNeeded = ref.watch(backupNudgeNeededProvider);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderSubtle, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    color: AppTheme.primaryDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offline Backup & Disaster Recovery',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Exports all 8 tables to an offline JSON file.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nudge / Status Banner
            lastBackupAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Text(
                'Error loading backup status: $err',
                style: const TextStyle(color: AppTheme.dangerColor),
              ),
              data: (lastDate) {
                if (nudgeNeeded) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7), // Light amber
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.warningAmber,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppTheme.warningAmber,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Weekly Backup Recommended',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF92400E),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lastDate == null
                                    ? 'No backup has been made yet. Export now to avoid data loss.'
                                    : 'Last export: ${DateFormat('MMM d, yyyy h:mm a').format(lastDate)}. '
                                          'It has been over 7 days since your last backup.',
                                style: const TextStyle(
                                  color: Color(0xFF92400E),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7), // Light emerald
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentGreen, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppTheme.accentGreen,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Last backup: ${DateFormat('MMM d, yyyy h:mm a').format(lastDate!)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF166534),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Action Buttons
            ElevatedButton.icon(
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.share_rounded, size: 20),
              label: Text(
                _isExporting ? 'Exporting...' : 'Export & Share Backup',
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: (_isExporting || _isRestoring) ? null : _handleExport,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: _isRestoring
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.restore_page_outlined,
                      color: AppTheme.dangerColor,
                      size: 20,
                    ),
              label: Text(
                _isRestoring ? 'Restoring...' : 'Restore from Backup File',
                style: const TextStyle(
                  color: AppTheme.dangerColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                side: const BorderSide(color: AppTheme.dangerColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: (_isExporting || _isRestoring) ? null : _handleRestore,
            ),
          ],
        ),
      ),
    );
  }
}
