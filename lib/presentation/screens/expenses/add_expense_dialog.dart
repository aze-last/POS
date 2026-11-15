import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/services/pricing_calculator.dart';
import '../../../domain/utils/formatters.dart';
import '../../providers/expense_providers.dart';
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
    return kg * 1000 + g;
  }

  @override
  Widget build(BuildContext context) {
    final activeProductsAsync = ref.watch(activeProductsProvider);

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
                final grams = _computedSpoilageGrams;
                if (grams <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter spoiled weight'),
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
