import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/services/sync_service.dart';
import '../../../domain/utils/formatters.dart';
import '../../providers/payout_providers.dart';
import '../../providers/sync_providers.dart';
import '../../providers/update_providers.dart';
import '../../theme/app_theme.dart';
import 'backup_view.dart';
import 'update_dialog.dart';

/// Settings screen for salary rules and database disaster recovery.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedMode = 'percent';
  late final TextEditingController _percentController;
  late final TextEditingController _fixedSalaryController;
  bool _initialized = false;
  bool _isSaving = false;
  bool _isCheckingUpdates = false;

  Future<void> _handleManualUpdateCheck() async {
    setState(() => _isCheckingUpdates = true);
    try {
      final update = await ref
          .read(availableUpdateProvider.notifier)
          .checkManual();
      final versionInfo = await ref.read(installedVersionProvider.future);
      if (!mounted) return;

      if (update != null) {
        UpdateDialog.show(
          context,
          release: update,
          currentVersion: versionInfo.version,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You're up to date! (v${versionInfo.version})"),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update check failed: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingUpdates = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _percentController = TextEditingController();
    _fixedSalaryController = TextEditingController();
  }

  @override
  void dispose() {
    _percentController.dispose();
    _fixedSalaryController.dispose();
    super.dispose();
  }

  void _initFields(Setting setting) {
    if (_initialized) return;
    _selectedMode = setting.salaryMode;
    // Basis points e.g. 3000 -> 30%
    final percent = setting.salaryPercentBasisPoints ~/ 100;
    _percentController.text = percent.toString();
    _fixedSalaryController.text = formatCentavosToDecimal(
      setting.fixedDailySalaryCentavos,
    );
    _initialized = true;
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      int basisPoints = 3000;
      int fixedDailySalaryCentavos = 0;

      if (_selectedMode == 'percent') {
        final percentVal = int.parse(_percentController.text.trim());
        basisPoints = percentVal * 100;
      } else {
        final centavos = parsePesoStringToCentavos(
          _fixedSalaryController.text.trim(),
        );
        if (centavos == null || centavos < 0) {
          throw const FormatException('Invalid fixed salary amount');
        }
        fixedDailySalaryCentavos = centavos;
      }

      await ref
          .read(payoutRepositoryProvider)
          .updateSettings(
            salaryMode: _selectedMode,
            salaryPercentBasisPoints: basisPoints,
            fixedDailySalaryCentavos: fixedDailySalaryCentavos,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salary settings saved successfully!'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<Setting>>(settingsStreamProvider, (prev, next) {
      final newSetting = next.value;
      if (newSetting != null && !_isSaving && prev?.value != newSetting) {
        _selectedMode = newSetting.salaryMode;
        final percent = newSetting.salaryPercentBasisPoints ~/ 100;
        _percentController.text = percent.toString();
        _fixedSalaryController.text = formatCentavosToDecimal(
          newSetting.fixedDailySalaryCentavos,
        );
        if (mounted) setState(() {});
      }
    });

    final settingsAsync = ref.watch(settingsStreamProvider);
    final versionAsync = ref.watch(installedVersionProvider);
    final syncState = ref.watch(syncStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Backup')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading settings: $err')),
        data: (setting) {
          _initFields(setting);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Salary Configuration Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: AppTheme.borderSubtle,
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet,
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
                                      'Daily Salary Calculation Mode',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Choose how your daily wage is determined.',
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

                          // Mode Selector
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment<String>(
                                value: 'percent',
                                label: Text('% of Net Profit'),
                                icon: Icon(Icons.percent_rounded),
                              ),
                              ButtonSegment<String>(
                                value: 'fixed',
                                label: Text('Fixed Daily (₱)'),
                                icon: Icon(Icons.payments_outlined),
                              ),
                            ],
                            selected: {_selectedMode},
                            onSelectionChanged: (newSelection) {
                              setState(() {
                                _selectedMode = newSelection.first;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          if (_selectedMode == 'percent') ...[
                            TextFormField(
                              controller: _percentController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: 'Salary Percentage (%)',
                                suffixText: '%',
                                helperText: 'Default: 30%. Stored as basis points (3000 bps).\nSalary is capped at net profit.',
                                helperMaxLines: 2,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Enter a percentage';
                                }
                                final p = int.tryParse(val.trim());
                                if (p == null || p < 0 || p > 100) {
                                  return 'Enter a value between 0 and 100';
                                }
                                return null;
                              },
                            ),
                          ] else ...[
                            TextFormField(
                              controller: _fixedSalaryController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'Fixed Daily Salary (₱)',
                                prefixText: '₱ ',
                                helperText: 'Integer centavos. Capped at daily net profit if profit is lower.',
                                helperMaxLines: 2,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Enter a daily salary amount';
                                }
                                final centavos = parsePesoStringToCentavos(
                                  val.trim(),
                                );
                                if (centavos == null || centavos < 0) {
                                  return 'Enter a valid positive amount';
                                }
                                return null;
                              },
                            ),
                          ],

                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_rounded, size: 20),
                            label: Text(
                              _isSaving ? 'Saving...' : 'Save Salary Mode',
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: AppTheme.primaryDark,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isSaving ? null : _saveSettings,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Offline Backup Section
                const BackupView(),

                const SizedBox(height: 20),

                // Multi-Device Cloud Sync Card (Supabase Step 9)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: AppTheme.borderSubtle,
                      width: 1.5,
                    ),
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
                                color: syncState.isConfigured
                                    ? AppTheme.accentGreen.withValues(
                                        alpha: 0.15,
                                      )
                                    : AppTheme.borderSubtle.withValues(
                                        alpha: 0.3,
                                      ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                syncState.isConfigured
                                    ? Icons.cloud_done_rounded
                                    : Icons.cloud_off_rounded,
                                color: syncState.isConfigured
                                    ? AppTheme.accentGreen
                                    : AppTheme.textSecondary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Multi-Device Sync',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    !syncState.isConfigured
                                        ? 'Offline only. Credentials not configured.'
                                        : syncState.status == SyncStatus.syncing
                                        ? 'Synchronizing data...'
                                        : syncState.lastSyncedAt != null
                                        ? 'Last synced: ${syncState.lastSyncedAt!.toLocal().toString().substring(0, 16)}'
                                        : 'Ready to sync (Supabase)',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (syncState.isConfigured) ...[
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            icon: syncState.status == SyncStatus.syncing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.sync_rounded, size: 20),
                            label: Text(
                              syncState.status == SyncStatus.syncing
                                  ? 'Syncing with Supabase...'
                                  : 'Sync Now',
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primaryDark,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: syncState.status == SyncStatus.syncing
                                ? null
                                : () async {
                                    await ref
                                        .read(syncStateProvider.notifier)
                                        .syncNow();
                                    final current = ref.read(syncStateProvider);
                                    if (!context.mounted) return;
                                    if (current.status == SyncStatus.success) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Multi-device sync completed successfully!',
                                          ),
                                          backgroundColor: AppTheme.accentGreen,
                                        ),
                                      );
                                    } else if (current.status ==
                                        SyncStatus.error) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Sync failed: ${current.errorMessage ?? "Network error"}',
                                          ),
                                          backgroundColor: AppTheme.dangerColor,
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Software Updates Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: AppTheme.borderSubtle,
                      width: 1.5,
                    ),
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
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.system_update_rounded,
                                color: AppTheme.primaryDark,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Software Updates',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  versionAsync.when(
                                    data: (info) => Text(
                                      info.displayString,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    loading: () =>
                                        const Text('Checking version...'),
                                    error: (err, stack) =>
                                        const Text('Version 1.0.0+1'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          icon: _isCheckingUpdates
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded, size: 20),
                          label: Text(
                            _isCheckingUpdates
                                ? 'Checking for updates...'
                                : 'Check for Updates',
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            side: const BorderSide(
                              color: AppTheme.borderSubtle,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isCheckingUpdates
                              ? null
                              : _handleManualUpdateCheck,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // App & Spec Info Card
                Card(
                  elevation: 0,
                  color: AppTheme.backgroundLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: AppTheme.borderSubtle,
                      width: 1,
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 18,
                              color: AppTheme.textSecondary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Banana POS System Security & Contract',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Offline-First: Zero network permissions, no external telemetry.\n'
                          '• Pure Integer Arithmetic: Zero floating-point rounding drifts.\n'
                          '• Historical Audit: Archived varieties and sale snapshot immutability.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
