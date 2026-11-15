import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../domain/models/weight.dart';
import '../../../domain/services/pricing_calculator.dart';
import '../../../domain/utils/formatters.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';

/// Modal bottom sheet for entering weight and confirming line price.
///
/// Features:
/// - Discrete kg and g numeric inputs (0-999 for g, total > 0)
/// - One-tap quick weight shortcut chips (+0.5kg, +1.0kg, +2.0kg)
/// - Price/kg prefilled with product default, editable for this sale only
/// - Live calculated line total
/// - Parsed confirmation preview ("1.300 kg @ P25.00/kg = P32.50")
class WeighingBottomSheet extends ConsumerStatefulWidget {
  final Product product;
  final CartLine? lineToEdit;

  const WeighingBottomSheet({
    super.key,
    required this.product,
    this.lineToEdit,
  });

  static Future<void> show(
    BuildContext context, {
    required Product product,
    CartLine? lineToEdit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          WeighingBottomSheet(product: product, lineToEdit: lineToEdit),
    );
  }

  @override
  ConsumerState<WeighingBottomSheet> createState() =>
      _WeighingBottomSheetState();
}

class _WeighingBottomSheetState extends ConsumerState<WeighingBottomSheet> {
  late final TextEditingController _kgController;
  late final TextEditingController _gController;
  late final TextEditingController _priceController;

  bool get isEditing => widget.lineToEdit != null;

  @override
  void initState() {
    super.initState();
    final line = widget.lineToEdit;
    final initialKg = line != null ? line.weight.kg.toString() : '1';
    final initialG = line != null
        ? line.weight.g.toString().padLeft(3, '0')
        : '000';

    final priceCentavos = line != null
        ? line.pricePerKgCentavos
        : widget.product.defaultPriceCentavos;
    final pricePesos =
        '${priceCentavos ~/ 100}.${(priceCentavos % 100).toString().padLeft(2, '0')}';

    _kgController = TextEditingController(text: initialKg);
    _gController = TextEditingController(text: initialG);
    _priceController = TextEditingController(text: pricePesos);
  }

  @override
  void dispose() {
    _kgController.dispose();
    _gController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  int get _parsedGrams {
    final kg = int.tryParse(_kgController.text.trim()) ?? 0;
    final g = int.tryParse(_gController.text.trim()) ?? 0;
    if (kg < 0 || g < 0 || g > 999) return 0;
    return kg * 1000 + g;
  }

  int get _parsedPriceCentavos {
    return parsePesoStringToCentavos(_priceController.text) ?? 0;
  }

  int get _computedLineValue {
    final grams = _parsedGrams;
    final price = _parsedPriceCentavos;
    if (grams <= 0 || price <= 0) return 0;
    return PricingCalculator.computeLineValue(
      grams: grams,
      pricePerKgCentavos: price,
    );
  }

  void _addQuickWeight(int addGrams) {
    final current = _parsedGrams;
    final updated = current + addGrams;
    setState(() {
      _kgController.text = (updated ~/ 1000).toString();
      _gController.text = (updated % 1000).toString().padLeft(3, '0');
    });
  }

  void _clearWeight() {
    setState(() {
      _kgController.text = '0';
      _gController.text = '000';
    });
  }

  void _confirm() {
    final grams = _parsedGrams;
    final price = _parsedPriceCentavos;

    if (grams <= 0 || price <= 0) return;

    final weight = Weight.fromGrams(grams);
    final notifier = ref.read(cartProvider.notifier);

    if (isEditing) {
      notifier.updateLine(widget.lineToEdit!.id, weight, price);
    } else {
      final line = CartLine(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        productId: widget.product.id,
        productName: widget.product.name,
        weight: weight,
        pricePerKgCentavos: price,
        capitalPerKgCentavos: widget.product.capitalCentavos,
      );
      notifier.addLine(line);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final grams = _parsedGrams;
    final lineValue = _computedLineValue;
    final isValid = grams > 0 && _parsedPriceCentavos > 0;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Default: ${formatMoney(widget.product.defaultPriceCentavos)}/kg · Capital: ${formatMoney(widget.product.capitalCentavos)}/kg',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
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

            // Two-Field Weight Input (kg & g)
            const Text(
              'Enter Weight (kg and grams):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _kgController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Kilograms (kg)',
                      border: OutlineInputBorder(),
                      suffixText: 'kg',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '.',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _gController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Grams (g: 0-999)',
                      border: OutlineInputBorder(),
                      suffixText: 'g',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Quick weight chips for 1-tap stall convenience
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: const Text('+0.5 kg (500g)'),
                  onPressed: () => _addQuickWeight(500),
                ),
                ActionChip(
                  label: const Text('+1.0 kg'),
                  onPressed: () => _addQuickWeight(1000),
                ),
                ActionChip(
                  label: const Text('+2.0 kg'),
                  onPressed: () => _addQuickWeight(2000),
                ),
                ActionChip(
                  avatar: const Icon(Icons.refresh, size: 16),
                  label: const Text('Clear'),
                  onPressed: _clearWeight,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price/kg (prefilled with default, editable FOR THIS SALE ONLY)
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Price per kg (for this sale only)',
                border: OutlineInputBorder(),
                prefixText: 'P ',
                prefixStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                helperText: 'Changing this does not modify the catalog price.',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Parsed Confirmation & Live Total Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calculated Line Total:',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        grams > 0
                            ? '${(grams / 1000).toStringAsFixed(3)} kg @ ${formatMoney(_parsedPriceCentavos)}/kg'
                            : 'Enter weight to calculate',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formatMoney(lineValue),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Confirm Button (54dp height)
            ElevatedButton(
              onPressed: isValid ? _confirm : null,
              child: Text(
                isEditing ? 'Update Line' : 'Add to Cart',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
