import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../domain/models/weight.dart';
import '../../../domain/services/pricing_calculator.dart';
import '../../../domain/utils/formatters.dart';
import '../../../domain/utils/weight_parser.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_image_widget.dart';
import '../../widgets/stall_keypad.dart';

/// Modal bottom sheet for entering weight and confirming line price.
///
/// Features:
/// - Scale-style single-stream weight input with on-screen stall keypad
/// - Quick one-tap shortcut chips (+0.5kg, +1.0kg, +2.0kg, Clear)
/// - Price/kg prefilled with product default, editable for this sale only
/// - Live calculated line total
/// - Parsed confirmation preview ("1.300 kg @ P25.00/kg = P32.50")
class WeighingBottomSheet extends ConsumerStatefulWidget {
  final Product product;
  final CartLine? lineToEdit;
  final void Function(Weight weight, int pricePerKgCentavos)? onCustomConfirm;

  const WeighingBottomSheet({
    super.key,
    required this.product,
    this.lineToEdit,
    this.onCustomConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required Product product,
    CartLine? lineToEdit,
    void Function(Weight weight, int pricePerKgCentavos)? onCustomConfirm,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WeighingBottomSheet(
        product: product,
        lineToEdit: lineToEdit,
        onCustomConfirm: onCustomConfirm,
      ),
    );
  }

  @override
  ConsumerState<WeighingBottomSheet> createState() =>
      _WeighingBottomSheetState();
}

class _WeighingBottomSheetState extends ConsumerState<WeighingBottomSheet> {
  late String _weightInput;
  bool _isFirstInput = true;
  late final TextEditingController _priceController;

  bool get isEditing => widget.lineToEdit != null;

  @override
  void initState() {
    super.initState();
    final line = widget.lineToEdit;
    if (line != null) {
      final kg = line.weight.kg;
      final g = line.weight.g;
      if (g == 0) {
        _weightInput = '$kg.0';
      } else {
        _weightInput = '$kg.${g.toString().padLeft(3, '0')}';
      }
    } else {
      _weightInput = '1.0';
    }

    final priceCentavos = line != null
        ? line.pricePerKgCentavos
        : widget.product.defaultPriceCentavos;
    final pricePesos =
        '${priceCentavos ~/ 100}.${(priceCentavos % 100).toString().padLeft(2, '0')}';

    _priceController = TextEditingController(text: pricePesos);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  int get _parsedGrams {
    return parseWeightStringToGrams(_weightInput);
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

  void _onDigit(String digit) {
    setState(() {
      if (_isFirstInput) {
        _weightInput = digit;
        _isFirstInput = false;
        return;
      }
      if (_weightInput == '0') {
        _weightInput = digit;
        return;
      }
      if (_weightInput.contains('.')) {
        final frac = _weightInput.split('.')[1];
        if (frac.length >= 3) return; // Limit to 3 decimal places (grams)
      }
      if (_weightInput.length >= 7) return;

      _weightInput += digit;
    });
  }

  void _onDot() {
    setState(() {
      if (_isFirstInput) {
        _weightInput = '0.';
        _isFirstInput = false;
        return;
      }
      if (_weightInput.isEmpty) {
        _weightInput = '0.';
      } else if (!_weightInput.contains('.')) {
        _weightInput += '.';
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_isFirstInput) {
        _weightInput = '0';
        _isFirstInput = false;
        return;
      }
      if (_weightInput.isNotEmpty) {
        _weightInput = _weightInput.substring(0, _weightInput.length - 1);
        if (_weightInput.isEmpty) {
          _weightInput = '0';
        }
      }
    });
  }

  void _addQuickWeight(int addGrams) {
    final current = _parsedGrams;
    final updated = current + addGrams;
    final kg = updated ~/ 1000;
    final g = updated % 1000;
    setState(() {
      _isFirstInput = false;
      if (g == 0) {
        _weightInput = '$kg.0';
      } else {
        _weightInput = '$kg.${g.toString().padLeft(3, '0')}';
      }
    });
  }

  void _clearWeight() {
    setState(() {
      _weightInput = '0';
      _isFirstInput = false;
    });
  }

  void _confirm() {
    final grams = _parsedGrams;
    final price = _parsedPriceCentavos;

    if (grams <= 0 || price <= 0) return;

    final weight = Weight.fromGrams(grams);

    if (widget.onCustomConfirm != null) {
      widget.onCustomConfirm!(weight, price);
      Navigator.of(context).pop();
      return;
    }

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
              children: [
                ProductImageWidget(
                  imagePath: widget.product.imagePath,
                  width: 52,
                  height: 52,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(width: 12),
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

            // Weight Header
            const Text(
              'Enter Weight (kg and grams):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),

            // Large Stall Weight Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300, width: 1.5),
              ),
              child: Column(
                children: [
                  Text(
                    formatWeight(grams),
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    grams > 0 ? '($grams grams)' : '(Enter weight)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

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
            const SizedBox(height: 12),

            // Large On-Screen Stall Keypad (Option A)
            StallKeypad(
              onDigit: _onDigit,
              onDot: _onDot,
              onBackspace: _onBackspace,
              onClear: _clearWeight,
            ),
            const SizedBox(height: 14),

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
                isDense: true,
                helperText: 'Changing this does not modify the catalog price.',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),

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
                  Expanded(
                    child: Column(
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
                              ? '${formatWeight(grams)} @ ${formatMoney(_parsedPriceCentavos)}/kg'
                              : 'Enter weight to calculate',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
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
            const SizedBox(height: 16),

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
