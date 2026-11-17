import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/sale_repository.dart';
import '../../../domain/services/pricing_calculator.dart';
import '../../../domain/utils/formatters.dart';
import '../../theme/app_theme.dart';

/// Clean receipt modal dialog shown after completing a sale.
class ReceiptDialog extends StatelessWidget {
  final CompletedSaleResult result;

  const ReceiptDialog({super.key, required this.result});

  static Future<void> show(BuildContext context, CompletedSaleResult result) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ReceiptDialog(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sale = result.sale;
    final items = result.items;
    final dateFormat = DateFormat('MMM d, yyyy · h:mm a');

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.green, size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Sale Complete',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dateFormat.format(sale.createdAt),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const Divider(height: 24),
              // Itemized list with largest-remainder discount allocation
              Builder(
                builder: (context) {
                  final itemValues = items
                      .map(
                        (i) => PricingCalculator.computeLineValue(
                          grams: i.grams,
                          pricePerKgCentavos: i.pricePerKgCentavos,
                        ),
                      )
                      .toList();
                  final allocatedDiscounts = result.discountCentavos > 0
                      ? PricingCalculator.allocateDiscount(
                          lineValuesCentavos: itemValues,
                          totalDiscountCentavos: result.discountCentavos,
                        )
                      : List<int>.filled(items.length, 0);

                  return Column(
                    children: List.generate(items.length, (idx) {
                      final item = items[idx];
                      final lineVal = itemValues[idx];
                      final weightStr = formatWeight(item.grams);
                      final disc = allocatedDiscounts[idx];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.productNameSnapshot} ($weightStr @ ${formatMoney(item.pricePerKgCentavos)}/kg)',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  if (disc > 0)
                                    Text(
                                      'Line Discount: -${formatMoney(disc)}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              formatMoney(lineVal),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  );
                },
              ),
              const Divider(height: 24),
              // Exact Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Exact Total:', style: TextStyle(fontSize: 15)),
                  Text(
                    formatMoney(sale.exactTotalCentavos),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              if (result.discountCentavos > 0) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Discount:',
                      style: TextStyle(color: Colors.green, fontSize: 15),
                    ),
                    Text(
                      '-${formatMoney(result.discountCentavos)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 6),
              // Charged
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Amount Charged:',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      formatMoney(sale.chargedCentavos),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Paid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Amount Paid:',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      formatMoney(sale.paidCentavos),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Big Change Display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'CHANGE DUE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        formatMoney(sale.changeCentavos),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: AppTheme.primaryDark,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Done · New Sale',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
