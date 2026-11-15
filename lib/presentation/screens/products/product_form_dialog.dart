import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../domain/utils/formatters.dart';
import '../../providers/product_providers.dart';
import '../../theme/app_theme.dart';

/// Modal bottom sheet for adding or editing a banana product.
class ProductFormDialog extends ConsumerStatefulWidget {
  final Product? productToEdit;

  const ProductFormDialog({super.key, this.productToEdit});

  static Future<bool?> show(BuildContext context, {Product? product}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProductFormDialog(productToEdit: product),
    );
  }

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _capitalController;

  String? _errorMessage;
  bool _isSaving = false;

  bool get isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');

    // Display pesos nicely (e.g. 3000 centavos -> "30.00")
    final priceStr = p != null
        ? '${p.defaultPriceCentavos ~/ 100}.${(p.defaultPriceCentavos % 100).toString().padLeft(2, '0')}'
        : '';
    final capitalStr = p != null
        ? '${p.capitalCentavos ~/ 100}.${(p.capitalCentavos % 100).toString().padLeft(2, '0')}'
        : '';

    _priceController = TextEditingController(text: priceStr);
    _capitalController = TextEditingController(text: capitalStr);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _capitalController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final priceCentavos = parsePesoStringToCentavos(_priceController.text);
    final capitalCentavos = parsePesoStringToCentavos(_capitalController.text);

    if (priceCentavos == null || priceCentavos <= 0) {
      setState(() => _errorMessage = 'Price must be greater than P0.00');
      return;
    }
    if (capitalCentavos == null || capitalCentavos <= 0) {
      setState(() => _errorMessage = 'Capital must be greater than P0.00');
      return;
    }

    setState(() => _isSaving = true);
    final repo = ref.read(productRepositoryProvider);

    try {
      if (isEditing) {
        await repo.updateProduct(
          id: widget.productToEdit!.id,
          name: name,
          defaultPriceCentavos: priceCentavos,
          capitalCentavos: capitalCentavos,
        );
      } else {
        await repo.addProduct(
          name: name,
          defaultPriceCentavos: priceCentavos,
          capitalCentavos: capitalCentavos,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = e
              .toString()
              .replaceFirst('ArgumentError: ', '')
              .replaceFirst('Invalid argument(s): ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Banana Variety' : 'Add Banana Variety',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppTheme.dangerColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppTheme.dangerColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Product Name
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Banana Name (e.g. Cardava)',
                  hintText: 'Enter variety name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a banana variety name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Default Selling Price (P/kg)
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Default Selling Price (P/kg)',
                  hintText: '35.00',
                  border: OutlineInputBorder(),
                  prefixText: 'P ',
                  prefixStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter selling price';
                  }
                  final c = parsePesoStringToCentavos(val);
                  if (c == null || c <= 0) {
                    return 'Must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Capital Cost (P/kg)
              TextFormField(
                controller: _capitalController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Capital Cost (P/kg)',
                  hintText: '25.00',
                  border: OutlineInputBorder(),
                  prefixText: 'P ',
                  prefixStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  helperText: 'Shown prominently in catalog. Changes are logged to capital history.',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter capital cost';
                  }
                  final c = parsePesoStringToCentavos(val);
                  if (c == null || c <= 0) {
                    return 'Must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Save Action Button (min height 54dp for one-handed thumb tap)
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(isEditing ? 'Save Changes' : 'Add to Catalog'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
