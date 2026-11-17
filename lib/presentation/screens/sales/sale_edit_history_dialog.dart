import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../../domain/models/weight.dart';
import '../../../domain/utils/formatters.dart';
import '../../providers/sale_providers.dart';
import '../../theme/app_theme.dart';

/// Modal dialog displaying immutable before-and-after audit history for a sale.
///
/// Spec Section 4 & 5.3:
/// - Immutable audit trail; no UI path can delete edit history.
/// - Shows full comparison: totals, lines, charged, paid, change, profit.
class SaleEditHistoryDialog extends ConsumerWidget {
  final int saleId;

  const SaleEditHistoryDialog({super.key, required this.saleId});

  static Future<void> show(BuildContext context, {required int saleId}) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => SaleEditHistoryDialog(saleId: saleId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editsAsync = ref.watch(saleEditsProvider(saleId));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 550,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.history,
                          color: AppTheme.primaryDark,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Edit History: Sale #$saleId',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Content
              Expanded(
                child: editsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text(
                      'Error loading edits: $e',
                      style: const TextStyle(color: AppTheme.accentRed),
                    ),
                  ),
                  data: (edits) {
                    if (edits.isEmpty) {
                      return const Center(
                        child: Text(
                          'No edit records found for this sale.',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: edits.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final edit = edits[index];
                        final editNum = edits.length - index;
                        return _EditEntryCard(edit: edit, editNumber: editNum);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditEntryCard extends StatelessWidget {
  final SaleEdit edit;
  final int editNumber;

  const _EditEntryCard({required this.edit, required this.editNumber});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> before = {};
    Map<String, dynamic> after = {};

    try {
      before = jsonDecode(edit.beforeJson) as Map<String, dynamic>;
      after = jsonDecode(edit.afterJson) as Map<String, dynamic>;
    } catch (_) {}

    final beforeCharged = before['charged_centavos'] as int? ?? 0;
    final afterCharged = after['charged_centavos'] as int? ?? 0;
    final beforePaid = before['paid_centavos'] as int? ?? 0;
    final afterPaid = after['paid_centavos'] as int? ?? 0;
    final beforeChange = before['change_centavos'] as int? ?? 0;
    final afterChange = after['change_centavos'] as int? ?? 0;
    final beforeExact = before['exact_total_centavos'] as int? ?? 0;
    final afterExact = after['exact_total_centavos'] as int? ?? 0;

    final beforeLines = (before['lines'] as List?) ?? [];
    final afterLines = (after['lines'] as List?) ?? [];

    final beforeProfit = beforeCharged - _computeCapital(beforeLines);
    final afterProfit = afterCharged - _computeCapital(afterLines);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Edit Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Edit #$editNumber',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ),
              Text(
                DateFormat('MMM d, yyyy · h:mm a').format(edit.editedAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),

          if (edit.reason != null && edit.reason!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.comment_outlined,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Reason: ${edit.reason!}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          // Comparison Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            color: Colors.grey.shade100,
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Metric',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Before',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'After',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          _ComparisonRow(
            label: 'Charged',
            beforeVal: formatMoney(beforeCharged),
            afterVal: formatMoney(afterCharged),
          ),
          _ComparisonRow(
            label: 'Exact Total',
            beforeVal: formatMoney(beforeExact),
            afterVal: formatMoney(afterExact),
          ),
          _ComparisonRow(
            label: 'Paid',
            beforeVal: formatMoney(beforePaid),
            afterVal: formatMoney(afterPaid),
          ),
          _ComparisonRow(
            label: 'Change',
            beforeVal: formatMoney(beforeChange),
            afterVal: formatMoney(afterChange),
          ),
          _ComparisonRow(
            label: 'Profit',
            beforeVal: formatMoney(beforeProfit),
            afterVal: formatMoney(afterProfit),
            highlight: true,
          ),

          const SizedBox(height: 10),
          const Text(
            'Lines (After Edit):',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          ...afterLines.map((l) {
            final name = l['product_name'] as String? ?? 'Product';
            final grams = l['grams'] as int? ?? 0;
            final price = l['price_per_kg_centavos'] as int? ?? 0;
            final val = l['line_value_centavos'] as int? ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '• $name (${Weight.fromGrams(grams).formatKg()} @ ${formatMoney(price)}/kg)',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatMoney(val),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  int _computeCapital(List<dynamic> lines) {
    return lines.fold<int>(0, (sum, l) {
      final grams = l['grams'] as int? ?? 0;
      final cap = l['capital_per_kg_centavos'] as int? ?? 0;
      return sum + ((cap * grams + 500) ~/ 1000);
    });
  }
}

class _ComparisonRow extends StatelessWidget {
  final String label;
  final String beforeVal;
  final String afterVal;
  final bool highlight;

  const _ComparisonRow({
    required this.label,
    required this.beforeVal,
    required this.afterVal,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final changed = beforeVal != afterVal;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: changed
            ? Colors.amber.shade50.withValues(alpha: 0.5)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                color: highlight ? AppTheme.primaryDark : AppTheme.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              beforeVal,
              style: TextStyle(
                fontSize: 12,
                color: changed ? AppTheme.accentRed : AppTheme.textSecondary,
                decoration: changed ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              afterVal,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: changed ? AppTheme.accentGreen : AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
