import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/sale_repository.dart';
import '../../../domain/models/weight.dart';
import '../../../domain/services/pricing_calculator.dart';
import '../../../domain/utils/formatters.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_providers.dart';
import '../../providers/sale_providers.dart';
import '../../theme/app_theme.dart';
import '../pos/weighing_bottom_sheet.dart';

/// Modal sheet for editing an existing sale with full cart and payment controls.
///
/// Spec Section 5.3 & 9:
/// - Reuses weighing bottom sheet, cart controls, and domain money math.
/// - Allows adding, removing, and modifying line products, weight, and price.
/// - Enforces at least 1 remaining line; blocks removing the last line.
/// - Tracks dirty state; asks "Discard changes?" on pop if modified.
/// - Disables Save until changes exist and all validation passes.
/// - Locked payout day guard blocks edits with "This day is paid out. Reopen it first."
class EditSaleDialog extends ConsumerStatefulWidget {
  final SaleWithDetails saleWithDetails;

  const EditSaleDialog({super.key, required this.saleWithDetails});

  static Future<bool?> show(
    BuildContext context,
    SaleWithDetails saleWithDetails,
  ) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditSaleDialog(saleWithDetails: saleWithDetails),
    );
  }

  @override
  ConsumerState<EditSaleDialog> createState() => _EditSaleDialogState();
}

class _EditSaleDialogState extends ConsumerState<EditSaleDialog> {
  late List<_EditableLine> _lines;
  late TextEditingController _chargedController;
  late TextEditingController _paidController;
  late TextEditingController _reasonController;

  late final int _originalChargedCentavos;
  late final int _originalPaidCentavos;
  late final List<_OriginalLineState> _originalLines;

  bool _isSaving = false;
  String? _error;
  bool _isDayLocked = false;

  @override
  void initState() {
    super.initState();
    final sale = widget.saleWithDetails.sale;
    _originalChargedCentavos = sale.chargedCentavos;
    _originalPaidCentavos = sale.paidCentavos;

    _lines = widget.saleWithDetails.items
        .map(
          (i) => _EditableLine(
            originalItemId: i.id,
            productId: i.productId,
            name: i.productNameSnapshot,
            grams: i.grams,
            pricePerKgCentavos: i.pricePerKgCentavos,
            capitalPerKgCentavos: i.capitalPerKgCentavos,
          ),
        )
        .toList();

    _originalLines = _lines
        .map(
          (l) => _OriginalLineState(
            productId: l.productId,
            grams: l.grams,
            pricePerKgCentavos: l.pricePerKgCentavos,
          ),
        )
        .toList();

    _chargedController = TextEditingController(
      text: formatCentavosToDecimal(sale.chargedCentavos),
    );
    _paidController = TextEditingController(
      text: formatCentavosToDecimal(sale.paidCentavos),
    );
    _reasonController = TextEditingController();

    _checkDayLock();
  }

  @override
  void dispose() {
    _chargedController.dispose();
    _paidController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _checkDayLock() async {
    final repo = ref.read(saleRepositoryProvider);
    final locked = await repo.isDayLocked(
      widget.saleWithDetails.sale.createdAt,
    );
    if (mounted) {
      setState(() {
        _isDayLocked = locked;
      });
    }
  }

  int get _computedExactTotalCentavos => _lines.fold<int>(
    0,
    (sum, l) =>
        sum +
        PricingCalculator.computeLineValue(
          grams: l.grams,
          pricePerKgCentavos: l.pricePerKgCentavos,
        ),
  );

  int get _parsedChargedCentavos =>
      parsePesoStringToCentavos(_chargedController.text) ?? 0;

  int get _parsedPaidCentavos =>
      parsePesoStringToCentavos(_paidController.text) ?? 0;

  int get _computedDiscountCentavos {
    final exact = _computedExactTotalCentavos;
    final charged = _parsedChargedCentavos;
    return exact > charged ? exact - charged : 0;
  }

  List<int> get _lineDiscountsCentavos {
    final lineValues = [
      for (final l in _lines)
        PricingCalculator.computeLineValue(
          grams: l.grams,
          pricePerKgCentavos: l.pricePerKgCentavos,
        ),
    ];
    return PricingCalculator.allocateDiscount(
      lineValuesCentavos: lineValues,
      totalDiscountCentavos: _computedDiscountCentavos,
    );
  }

  bool get _isDirty {
    if (_lines.length != _originalLines.length) return true;
    for (int i = 0; i < _lines.length; i++) {
      final current = _lines[i];
      final orig = _originalLines[i];
      if (current.productId != orig.productId ||
          current.grams != orig.grams ||
          current.pricePerKgCentavos != orig.pricePerKgCentavos) {
        return true;
      }
    }
    if (_parsedChargedCentavos != _originalChargedCentavos) return true;
    if (_parsedPaidCentavos != _originalPaidCentavos) return true;
    if (_reasonController.text.trim().isNotEmpty) return true;
    return false;
  }

  bool get _isValid {
    if (_lines.isEmpty) return false;
    for (final l in _lines) {
      if (l.grams <= 0 || l.pricePerKgCentavos <= 0) return false;
    }
    final charged = _parsedChargedCentavos;
    final paid = _parsedPaidCentavos;
    if (charged <= 0) return false;
    if (paid < charged) return false;
    return true;
  }

  void _syncChargedText(int centavos) {
    setState(() {
      _chargedController.text = formatCentavosToDecimal(centavos);
    });
  }

  void _syncPaidText(int centavos) {
    setState(() {
      _paidController.text = formatCentavosToDecimal(centavos);
    });
  }

  void _roundDownCharged() {
    final current = _parsedChargedCentavos;
    final rounded = (current ~/ 100) * 100;
    _syncChargedText(rounded > 0 ? rounded : current);
  }

  void _roundUpCharged() {
    final current = _parsedChargedCentavos;
    final rounded = ((current + 99) ~/ 100) * 100;
    _syncChargedText(rounded);
  }

  Future<void> _handlePop() async {
    if (!_isDirty) {
      Navigator.of(context).pop(false);
      return;
    }

    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes to this sale. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep Editing'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.accentRed),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (discard == true && mounted) {
      Navigator.of(context).pop(false);
    }
  }

  Future<void> _promptAddLine() async {
    final products = await ref
        .read(productRepositoryProvider)
        .getActiveProducts();
    if (!mounted) return;

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active products available to add.')),
      );
      return;
    }

    final selectedProduct = await showDialog<Product>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Banana Variety'),
        children: products.map((p) {
          return SimpleDialogOption(
            onPressed: () => Navigator.of(ctx).pop(p),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${formatMoney(p.defaultPriceCentavos)}/kg',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );

    if (selectedProduct == null || !mounted) return;

    await WeighingBottomSheet.show(
      context,
      product: selectedProduct,
      onCustomConfirm: (weight, price) {
        setState(() {
          _lines.add(
            _EditableLine(
              originalItemId:
                  null, // New line: will snapshot current catalog capital
              productId: selectedProduct.id,
              name: selectedProduct.name,
              grams: weight.grams,
              pricePerKgCentavos: price,
              capitalPerKgCentavos: selectedProduct.capitalCentavos,
            ),
          );
          _syncChargedText(_computedExactTotalCentavos);
        });
      },
    );
  }

  Future<void> _editLine(int index) async {
    final line = _lines[index];
    final products = await ref
        .read(productRepositoryProvider)
        .getActiveProducts();
    Product? prod;
    for (final p in products) {
      if (p.id == line.productId) {
        prod = p;
        break;
      }
    }
    prod ??= Product(
      id: line.productId,
      name: line.name,
      defaultPriceCentavos: line.pricePerKgCentavos,
      capitalCentavos: line.capitalPerKgCentavos,
      sortOrder: 0,
      archived: true,
    );

    if (!mounted) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.scale_outlined),
              title: const Text('Edit Weight & Price'),
              onTap: () => Navigator.of(ctx).pop('weight'),
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz_outlined),
              title: const Text('Change Variety'),
              onTap: () => Navigator.of(ctx).pop('variety'),
            ),
          ],
        ),
      ),
    );

    if (action == 'variety') {
      if (!mounted) return;
      final newProd = await showDialog<Product>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text('Change Variety'),
          children: products.map((p) {
            return SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(p),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${formatMoney(p.defaultPriceCentavos)}/kg',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );

      if (newProd != null && mounted) {
        setState(() {
          line.productId = newProd.id;
          line.name = newProd.name;
          line.pricePerKgCentavos = newProd.defaultPriceCentavos;
          line.capitalPerKgCentavos = newProd.capitalCentavos;
          _syncChargedText(_computedExactTotalCentavos);
        });
      }
    } else if (action == 'weight') {
      if (!mounted) return;
      await WeighingBottomSheet.show(
        context,
        product: prod,
        lineToEdit: CartLine(
          id: index.toString(),
          productId: line.productId,
          productName: line.name,
          weight: Weight.fromGrams(line.grams),
          pricePerKgCentavos: line.pricePerKgCentavos,
          capitalPerKgCentavos: line.capitalPerKgCentavos,
        ),
        onCustomConfirm: (weight, price) {
          setState(() {
            line.grams = weight.grams;
            line.pricePerKgCentavos = price;
            _syncChargedText(_computedExactTotalCentavos);
          });
        },
      );
    }
  }

  void _removeLine(int index) {
    if (_lines.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.dangerColor,
          content: Text(
            'A sale must keep at least one line. Use Void to remove everything.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _lines.removeAt(index);
      _syncChargedText(_computedExactTotalCentavos);
    });
  }

  Future<void> _reopenDay() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reopen Day Payout?'),
        content: const Text(
          'Reopening unlocks this day and permits modifying sales. You will need to review and mark the payout again in Daily Summary.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.warningAmber,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reopen Day'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final repo = ref.read(saleRepositoryProvider);
      await repo.reopenDay(widget.saleWithDetails.sale.createdAt);
      if (mounted) {
        setState(() {
          _isDayLocked = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Day reopened successfully. Edits unlocked.'),
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_isDirty || !_isValid || _isSaving) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final repo = ref.read(saleRepositoryProvider);
      final saleId = widget.saleWithDetails.sale.id;

      final saleInputs = _lines
          .map(
            (l) => SaleLineInput(
              originalItemId: l.originalItemId,
              productId: l.productId,
              productName: l.name,
              weight: Weight.fromGrams(l.grams),
              pricePerKgCentavos: l.pricePerKgCentavos,
              capitalPerKgCentavos: l.capitalPerKgCentavos,
            ),
          )
          .toList();

      final reason = _reasonController.text.trim().isNotEmpty
          ? _reasonController.text.trim()
          : null;

      await repo.editSale(
        saleId: saleId,
        newLines: saleInputs,
        chargedCentavos: _parsedChargedCentavos,
        paidCentavos: _parsedPaidCentavos,
        reason: reason,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _error = e.toString().replaceFirst(
            'SaleModificationLockedException: ',
            '',
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final exact = _computedExactTotalCentavos;
    final charged = _parsedChargedCentavos;
    final paid = _parsedPaidCentavos;
    final discount = _computedDiscountCentavos;
    final isPaidSufficient = paid >= charged && charged > 0;
    final lineDiscounts = _lineDiscountsCentavos;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handlePop();
      },
      child: Material(
        color: AppTheme.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Sale #${widget.saleWithDetails.sale.id}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      const Text(
                        'Original date and Sale ID are preserved',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _handlePop,
                  ),
                ],
              ),
              const Divider(height: 16),

              // Scrollable body
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Locked Day Alert Banner
                      if (_isDayLocked) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.warningAmber.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.warningAmber,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.lock,
                                    color: AppTheme.warningAmber,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'This day is paid out. Reopen it first.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.warningAmber,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(40),
                                ),
                                icon: const Icon(Icons.lock_open, size: 18),
                                label: const Text('Reopen Day Payout'),
                                onPressed: _reopenDay,
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: AppTheme.dangerColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],

                      // Lines List with Header and Add Line Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Line Items (${_lines.length})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Item'),
                            onPressed: _isDayLocked ? null : _promptAddLine,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      ..._lines.asMap().entries.map((entry) {
                        final index = entry.key;
                        final line = entry.value;
                        final lineVal = PricingCalculator.computeLineValue(
                          grams: line.grams,
                          pricePerKgCentavos: line.pricePerKgCentavos,
                        );
                        final lineDiscount = index < lineDiscounts.length
                            ? lineDiscounts[index]
                            : 0;

                        return Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              onTap: _isDayLocked
                                  ? null
                                  : () => _editLine(index),
                              title: Text(
                                line.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${formatWeight(line.grams)} @ ${formatMoney(line.pricePerKgCentavos)}/kg',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  if (lineDiscount > 0)
                                    Text(
                                      'Discount: -${formatMoney(lineDiscount)} (Net: ${formatMoney(lineVal - lineDiscount)})',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.accentGreen,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    formatMoney(lineVal),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: _lines.length > 1
                                          ? AppTheme.dangerColor
                                          : Colors.grey.shade400,
                                    ),
                                    tooltip: _lines.length > 1
                                        ? 'Remove line'
                                        : 'A sale must have at least one line',
                                    onPressed: _isDayLocked
                                        ? null
                                        : () => _removeLine(index),
                                  ),
                                ],
                              ),
                            ),
                            if (index < _lines.length - 1)
                              const Divider(height: 1),
                          ],
                        );
                      }),

                      const Divider(height: 16),

                      // Exact Total & Rounding Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Exact Total:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            formatMoney(exact),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Amount to Charge
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _chargedController,
                              enabled: !_isDayLocked,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Amount to Charge',
                                prefixText: 'P ',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              minimumSize: const Size(0, 48),
                            ),
                            onPressed: _isDayLocked ? null : _roundDownCharged,
                            child: const Text(
                              'Round\nDown',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              minimumSize: const Size(0, 48),
                            ),
                            onPressed: _isDayLocked ? null : _roundUpCharged,
                            child: const Text(
                              'Round\nUp',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),

                      if (discount > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Discount: -${formatMoney(discount)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Amount Paid
                      TextFormField(
                        controller: _paidController,
                        enabled: !_isDayLocked,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Amount Paid',
                          prefixText: 'P ',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 6),

                      // Quick Cash Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ActionChip(
                              label: const Text('Exact'),
                              onPressed: _isDayLocked
                                  ? null
                                  : () => _syncPaidText(charged),
                            ),
                            const SizedBox(width: 6),
                            ActionChip(
                              label: const Text('P50'),
                              onPressed: _isDayLocked
                                  ? null
                                  : () => _syncPaidText(5000),
                            ),
                            const SizedBox(width: 6),
                            ActionChip(
                              label: const Text('P100'),
                              onPressed: _isDayLocked
                                  ? null
                                  : () => _syncPaidText(10000),
                            ),
                            const SizedBox(width: 6),
                            ActionChip(
                              label: const Text('P200'),
                              onPressed: _isDayLocked
                                  ? null
                                  : () => _syncPaidText(20000),
                            ),
                            const SizedBox(width: 6),
                            ActionChip(
                              label: const Text('P500'),
                              onPressed: _isDayLocked
                                  ? null
                                  : () => _syncPaidText(5000),
                            ),
                            const SizedBox(width: 6),
                            ActionChip(
                              label: const Text('P1,000'),
                              onPressed: _isDayLocked
                                  ? null
                                  : () => _syncPaidText(100000),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Live Change / Remaining Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isPaidSufficient
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isPaidSufficient
                                ? Colors.green.shade300
                                : Colors.red.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isPaidSufficient
                                  ? 'CHANGE DUE:'
                                  : 'REMAINING DUE:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isPaidSufficient
                                    ? Colors.green.shade800
                                    : AppTheme.dangerColor,
                              ),
                            ),
                            Text(
                              isPaidSufficient
                                  ? formatMoney(paid - charged)
                                  : formatMoney(
                                      charged > paid ? charged - paid : 0,
                                    ),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isPaidSufficient
                                    ? Colors.green.shade900
                                    : AppTheme.dangerColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Optional Reason Field
                      TextFormField(
                        controller: _reasonController,
                        enabled: !_isDayLocked,
                        decoration: const InputDecoration(
                          labelText: 'Reason for edit (optional)',
                          hintText:
                              'e.g. Corrected weight after customer re-weighed',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Save Action Button
              ElevatedButton(
                onPressed: (_isDirty && _isValid && !_isDayLocked && !_isSaving)
                    ? _save
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDark,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        !_isDirty ? 'No Changes to Save' : 'Save Changes',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

class _EditableLine {
  final int? originalItemId;
  int productId;
  String name;
  int grams;
  int pricePerKgCentavos;
  int capitalPerKgCentavos;

  _EditableLine({
    required this.originalItemId,
    required this.productId,
    required this.name,
    required this.grams,
    required this.pricePerKgCentavos,
    required this.capitalPerKgCentavos,
  });
}

class _OriginalLineState {
  final int productId;
  final int grams;
  final int pricePerKgCentavos;

  const _OriginalLineState({
    required this.productId,
    required this.grams,
    required this.pricePerKgCentavos,
  });
}
