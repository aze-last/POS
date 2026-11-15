import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/sale_repository.dart';
import '../../../domain/models/weight.dart';
import '../../../domain/services/pricing_calculator.dart';
import '../../../domain/utils/formatters.dart';
import '../../theme/app_theme.dart';
import 'void_confirmation_dialog.dart';

/// Modal bottom sheet displaying complete audit details for a completed or voided sale.
///
/// Features:
/// - Snapshotted itemized lines (product, weight, price, capital snapshot, profit)
/// - Exact total, discount/rounding breakdown, paid & change
/// - Snapshotted profit calculation
/// - Safe void action with day-lock protection
class SaleDetailSheet extends ConsumerWidget {
  final SaleWithDetails saleWithDetails;

  const SaleDetailSheet({super.key, required this.saleWithDetails});

  static Future<void> show(
    BuildContext context, {
    required SaleWithDetails saleWithDetails,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SaleDetailSheet(saleWithDetails: saleWithDetails),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sale = saleWithDetails.sale;
    final items = saleWithDetails.items;
    final isVoided = sale.voided;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Material(
        color: AppTheme.surfaceLight,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sale #${sale.id}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('EEE, MMM d, yyyy · h:mm a')
                            .format(sale.createdAt),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isVoided
                          ? AppTheme.accentRed.withValues(alpha: 0.12)
                          : AppTheme.accentGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isVoided
                            ? AppTheme.accentRed
                            : AppTheme.accentGreen,
                      ),
                    ),
                    child: Text(
                      isVoided ? 'VOIDED' : 'COMPLETED',
                      style: TextStyle(
                        color: isVoided
                            ? AppTheme.accentRed
                            : AppTheme.accentGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (isVoided) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.accentRed.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.accentRed,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This sale is voided and excluded from all sales and profit totals.',
                          style: TextStyle(
                            color: AppTheme.accentRed,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Itemized Snapshotted Lines Header
              const Text(
                'ITEMIZED LINES (SNAPSHOT)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Item cards
              ...items.map((item) {
                final weight = Weight.fromGrams(item.grams);
                final lineValue = PricingCalculator.computeLineValue(
                  grams: item.grams,
                  pricePerKgCentavos: item.pricePerKgCentavos,
                );
                final lineCapital = PricingCalculator.computeLineCapital(
                  grams: item.grams,
                  capitalPerKgCentavos: item.capitalPerKgCentavos,
                );
                final lineProfit = lineValue - lineCapital;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.productNameSnapshot,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            formatMoney(lineValue),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${weight.formatKg()} @ ${formatMoney(item.pricePerKgCentavos)}/kg',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Capital: ${formatMoney(item.capitalPerKgCentavos)}/kg (${formatMoney(lineCapital)})',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${lineProfit >= 0 ? '+' : ''}${formatMoney(lineProfit)} profit',
                            style: TextStyle(
                              color: lineProfit >= 0
                                  ? AppTheme.accentGreen
                                  : AppTheme.accentRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              // Transaction Financial Breakdown
              _SummaryRow(
                label: 'Exact Items Total',
                value: formatMoney(sale.exactTotalCentavos),
              ),
              if (saleWithDetails.discountCentavos > 0)
                _SummaryRow(
                  label: 'Discount / Rounding',
                  value: '-${formatMoney(saleWithDetails.discountCentavos)}',
                  valueColor: AppTheme.accentRed,
                ),
              _SummaryRow(
                label: 'Amount Charged',
                value: formatMoney(sale.chargedCentavos),
                isBold: true,
                fontSize: 17,
              ),
              _SummaryRow(
                label: 'Amount Paid',
                value: formatMoney(sale.paidCentavos),
              ),
              _SummaryRow(
                label: 'Change Returned',
                value: formatMoney(sale.changeCentavos),
              ),
              const SizedBox(height: 4),
              _SummaryRow(
                label: 'Total Capital Cost',
                value: formatMoney(saleWithDetails.totalCapitalCentavos),
              ),
              _SummaryRow(
                label: 'Sale Profit Margin',
                value: formatMoney(saleWithDetails.profitCentavos),
                valueColor: saleWithDetails.profitCentavos >= 0
                    ? AppTheme.accentGreen
                    : AppTheme.accentRed,
                isBold: true,
                fontSize: 17,
              ),

              const SizedBox(height: 24),

              // Actions
              if (!isVoided)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentRed,
                    side: const BorderSide(
                      color: AppTheme.accentRed,
                      width: 1.5,
                    ),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text(
                    'Void This Sale',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    final voided = await VoidConfirmationDialog.show(
                      context,
                      ref,
                      saleWithDetails,
                    );
                    if (voided && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                )
              else
                Center(
                  child: Text(
                    'Voided record preserved for historical audit.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final double fontSize;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.fontSize = 14,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
