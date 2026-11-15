import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/sale_repository.dart';
import '../../../domain/utils/formatters.dart';
import '../../providers/sale_providers.dart';
import '../../theme/app_theme.dart';

/// Helper dialogs for safely voiding sales with confirmation and day-lock enforcement.
class VoidConfirmationDialog {
  /// Opens the void workflow:
  /// 1. Checks if the sale's day payout is locked.
  /// 2. If locked, requires the user to confirm reopening the day.
  /// 3. Confirms the destructive void action.
  /// 4. Voids the sale and provides snackbar feedback.
  static Future<bool> show(
    BuildContext context,
    WidgetRef ref,
    SaleWithDetails saleWithDetails,
  ) async {
    final sale = saleWithDetails.sale;
    final repo = ref.read(saleRepositoryProvider);

    final isLocked = await repo.isDayLocked(sale.createdAt);
    if (!context.mounted) return false;

    if (isLocked) {
      final shouldReopen = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(
            Icons.lock_clock,
            size: 40,
            color: AppTheme.warningAmber,
          ),
          title: const Text('Day Payout Locked'),
          content: Text(
            'The daily payout for ${DateFormat.yMMMd().format(sale.createdAt)} is locked.\n\n'
            'To void or edit sales on this day, the day payout must be reopened first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Reopen Day'),
            ),
          ],
        ),
      );

      if (shouldReopen != true) return false;

      // Reopen day in repository
      await repo.reopenDay(sale.createdAt);
      if (!context.mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Day ${DateFormat.yMMMd().format(sale.createdAt)} reopened.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    if (!context.mounted) return false;

    // Proceed to void confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          size: 44,
          color: AppTheme.accentRed,
        ),
        title: Text('Void Sale #${sale.id}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Charged: ${formatMoney(sale.chargedCentavos)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${DateFormat('MMM d, yyyy · h:mm a').format(sale.createdAt)}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.accentRed.withValues(alpha: 0.3),
                ),
              ),
              child: const Text(
                'This sale will be kept for audit records, but permanently excluded from sales totals, net profit, and payout formulas.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.accentRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
              foregroundColor: Colors.white,
              minimumSize: const Size(110, 48),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Void Sale'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await repo.voidSale(sale.id);
        if (!context.mounted) return true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sale #${sale.id} has been voided.'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
        return true;
      } on SaleModificationLockedException catch (e) {
        if (!context.mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppTheme.accentRed,
          ),
        );
        return false;
      }
    }

    return false;
  }
}
