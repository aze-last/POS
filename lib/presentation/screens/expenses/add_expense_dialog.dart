import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/services/payout_calculator.dart';
import '../../../domain/services/pricing_calculator.dart';
import '../../../domain/utils/formatters.dart';
import '../../providers/expense_providers.dart';
import '../../providers/payout_providers.dart';
import '../../providers/product_providers.dart';
import '../../theme/app_theme.dart';

/// Modal dialog to record a business expense or produce spoilage loss.
class AddExpenseDialog extends ConsumerStatefulWidget {
  final DateTime date;

  const AddExpenseDialog({super.key, required this.date});

  static Future<bool?> show(BuildContext context, {required DateTime date}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AddExpenseDialog(date: date),
    );
  }

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  String _selectedType = 'transport'; // transport | other | spoilage
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  // Spoilage fields
  int? _selectedProductId;
  final _kgController = TextEditingController();
  final _gController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _kgController.dispose();
    _gController.dispose();
    super.dispose();
  }

  int get _computedSpoilageGrams {
    final kg = int.tryParse(_kgController.text.trim()) ?? 0;
    final g = int.tryParse(_gController.text.trim()) ?? 0;
    if (kg < 0 || g < 0 || g > 999) return 0;
    return kg * 1000 + g;
  }

  @override
  Widget build(BuildContext context) {
    final activeProductsAsync = ref.watch(activeProductsProvider);
    final dailySummaryAsync = ref.watch(dailySummaryStateProvider(widget.date));
    final dailySummary = dailySummaryAsync.value;

    int additionalExpenseCentavos = 0;
    if (_selectedType == 'spoilage') {
      final grams = _computedSpoilageGrams;
      if (_selectedProductId != null && grams > 0) {
        final product = activeProductsAsync.value
            ?.where((p) => p.id == _selectedProductId)
            .firstOrNull;
        if (product != null) {
          additionalExpenseCentavos = PricingCalculator.computeLineCapital(
            grams: grams,
            capitalPerKgCentavos: product.capitalCentavos,
          );
        }
      }
    } else {
      additionalExpenseCentavos =
          parsePesoStringToCentavos(_amountController.text) ?? 0;
    }

    int currentSalary = 0;
    int projectedSalary = 0;
    final hasSummary = dailySummary != null;

    if (dailySummary != null) {
      final calc = dailySummary.calculation;
      currentSalary = calc.actualSalaryCentavos;
      final settings = dailySummary.settings;

      final projectedCalc = PayoutCalculator.calculate(
        salesCentavos: dailySummary.totalChargedCentavos,
        capitalSoldCentavos: dailySummary.capitalSoldCentavos,
        spoilageCentavos:
            dailySummary.spoilageCentavos +
            (_selectedType == 'spoilage' ? additionalExpenseCentavos : 0),
        otherExpensesCentavos:
            dailySummary.otherExpensesCentavos +
            (_selectedType != 'spoilage' ? additionalExpenseCentavos : 0),
        salaryMode: SalaryMode.fromString(settings.salaryMode),
        salaryPercentBasisPoints: settings.salaryPercentBasisPoints,
        fixedDailySalaryCentavos: settings.fixedDailySalaryCentavos,
      );
      projectedSalary = projectedCalc.suggestedSalaryCentavos;
    }

    return AlertDialog(
      title: const Text('Add Expense / Loss'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type Selector (1-tap chips)
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Transport')),
                      selected: _selectedType == 'transport',
                      onSelected: (_) =>
                          setState(() => _selectedType = 'transport'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Spoilage')),
                      selected: _selectedType == 'spoilage',
                      onSelected: (_) =>
                          setState(() => _selectedType = 'spoilage'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Other')),
                      selected: _selectedType == 'other',
                      onSelected: (_) =>
                          setState(() => _selectedType = 'other'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_selectedType == 'spoilage') ...[
                // Product selector
                activeProductsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error loading products: $e'),
                  data: (products) {
                    if (products.isEmpty) {
                      return const Text('No active varieties available.');
                    }
                    _selectedProductId ??= products.first.id;
                    final selectedProduct = products.firstWhere(
                      (p) => p.id == _selectedProductId,
                      orElse: () => products.first,
                    );

                    final spoilageGrams = _computedSpoilageGrams;
                    final computedLoss = spoilageGrams > 0
                        ? PricingCalculator.computeLineCapital(
                            grams: spoilageGrams,
                            capitalPerKgCentavos:
                                selectedProduct.capitalCentavos,
                          )
                        : 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<int>(
                          initialValue: _selectedProductId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Spoiled Variety',
                            border: OutlineInputBorder(),
                          ),
                          items: products.map((p) {
                            return DropdownMenuItem(
                              value: p.id,
                              child: Text(
                                '${p.name} (Capital: ${formatMoney(p.capitalCentavos)}/kg)',
                              ),
                            );
                          }).toList(),
                          onChanged: (id) {
                            setState(() {
                              _selectedProductId = id;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Spoiled Weight:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _kgController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Kilograms',
                                  suffixText: 'kg',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _gController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Grams',
                                  suffixText: 'g',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Quick weight chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ActionChip(
                                label: const Text('+0.5 kg'),
                                onPressed: () {
                                  final current = _computedSpoilageGrams;
                                  final next = current + 500;
                                  setState(() {
                                    _kgController.text = (next ~/ 1000)
                                        .toString();
                                    _gController.text = (next % 1000)
                                        .toString();
                                  });
                                },
                              ),
                              const SizedBox(width: 6),
                              ActionChip(
                                label: const Text('+1.0 kg'),
                                onPressed: () {
                                  final current = _computedSpoilageGrams;
                                  final next = current + 1000;
                                  setState(() {
                                    _kgController.text = (next ~/ 1000)
                                        .toString();
                                    _gController.text = (next % 1000)
                                        .toString();
                                  });
                                },
                              ),
                              const SizedBox(width: 6),
                              ActionChip(
                                label: const Text('+2.0 kg'),
                                onPressed: () {
                                  final current = _computedSpoilageGrams;
                                  final next = current + 2000;
                                  setState(() {
                                    _kgController.text = (next ~/ 1000)
                                        .toString();
                                    _gController.text = (next % 1000)
                                        .toString();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.accentRed.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.accentRed.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Calculated Loss:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentRed,
                                ),
                              ),
                              Text(
                                formatMoney(computedLoss),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: AppTheme.accentRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ] else ...[
                // Transport / Other amount
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount (Pesos)',
                    prefixText: 'P ',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                // Quick chips
                Wrap(
                  spacing: 6,
                  children: [20, 50, 100, 150, 200].map((pesos) {
                    return ActionChip(
                      label: Text('P$pesos'),
                      onPressed: () {
                        setState(() {
                          _amountController.text = pesos.toString();
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 14),

              // Optional note
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: _selectedType == 'spoilage'
                      ? 'Note / Reason (optional)'
                      : 'Description / Note',
                  hintText: _selectedType == 'transport'
                      ? 'e.g. Jeepney fare'
                      : 'e.g. Packing bags',
                  border: const OutlineInputBorder(),
                ),
              ),

              // Live impact on daily salary preview card
              if (hasSummary) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        additionalExpenseCentavos > 0 &&
                            projectedSalary == 0 &&
                            currentSalary > 0
                        ? AppTheme.accentRed.withValues(alpha: 0.08)
                        : (additionalExpenseCentavos > 0 &&
                                  projectedSalary < currentSalary
                              ? AppTheme.warningAmber.withValues(alpha: 0.12)
                              : Colors.blue.shade50),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          additionalExpenseCentavos > 0 &&
                              projectedSalary == 0 &&
                              currentSalary > 0
                          ? AppTheme.accentRed.withValues(alpha: 0.3)
                          : (additionalExpenseCentavos > 0 &&
                                    projectedSalary < currentSalary
                                ? AppTheme.warningAmber.withValues(alpha: 0.4)
                                : Colors.blue.shade200),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 16,
                                color: AppTheme.primaryDark,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Salary Left Today:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            formatMoney(projectedSalary),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color:
                                  additionalExpenseCentavos > 0 &&
                                      projectedSalary == 0 &&
                                      currentSalary > 0
                                  ? AppTheme.accentRed
                                  : (additionalExpenseCentavos > 0 &&
                                            projectedSalary < currentSalary
                                        ? AppTheme.warningAmber
                                        : AppTheme.accentGreen),
                            ),
                          ),
                        ],
                      ),
                      if (additionalExpenseCentavos > 0) ...[
                        const SizedBox(height: 6),
                        if (projectedSalary == 0 && currentSalary > 0) ...[
                          const Text(
                            '🚨 Warning: This expense will wipe out your remaining salary today (P0.00 left)!',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentRed,
                            ),
                          ),
                        ] else if (projectedSalary < currentSalary) ...[
                          Text(
                            '⚠️ Warning: Reduces your salary by ${formatMoney(currentSalary - projectedSalary)} (from ${formatMoney(currentSalary)} to ${formatMoney(projectedSalary)}).',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ] else ...[
                          const Text(
                            '✅ Sufficient profit to cover this expense without reducing your daily salary.',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.accentGreen,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final repo = ref.read(expenseRepositoryProvider);
            try {
              if (_selectedType == 'spoilage') {
                final g = int.tryParse(_gController.text.trim()) ?? 0;
                if (g < 0 || g > 999) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Grams must be between 0 and 999'),
                    ),
                  );
                  return;
                }
                final grams = _computedSpoilageGrams;
                if (grams <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter valid spoiled weight (> 0g)'),
                    ),
                  );
                  return;
                }
                final products = activeProductsAsync.value ?? [];
                if (products.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No varieties available')),
                  );
                  return;
                }
                final product = products.firstWhere(
                  (p) => p.id == (_selectedProductId ?? products.first.id),
                  orElse: () => products.first,
                );

                await repo.addSpoilageExpense(
                  date: widget.date,
                  productId: product.id,
                  grams: grams,
                  capitalPerKgCentavos: product.capitalCentavos,
                  note: _noteController.text.trim().isNotEmpty
                      ? _noteController.text.trim()
                      : null,
                );
              } else {
                final centavos = parsePesoStringToCentavos(
                  _amountController.text,
                );
                if (centavos == null || centavos <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                    ),
                  );
                  return;
                }

                await repo.addGeneralExpense(
                  date: widget.date,
                  type: _selectedType,
                  amountCentavos: centavos,
                  note: _noteController.text.trim().isNotEmpty
                      ? _noteController.text.trim()
                      : null,
                );
              }

              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to add expense: $e'),
                    backgroundColor: AppTheme.accentRed,
                  ),
                );
              }
            }
          },
          child: const Text('Save Expense'),
        ),
      ],
    );
  }
}
