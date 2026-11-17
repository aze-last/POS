import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/database/app_database.dart';
import '../../../data/services/product_image_service.dart';
import '../../../domain/models/product_validator.dart';
import '../../../domain/utils/formatters.dart';
import '../../providers/product_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_image_widget.dart';

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
  final _imageService = ProductImageService();

  String? _imagePath;
  bool _imageChanged = false;
  String? _errorMessage;
  bool _isSaving = false;

  bool get isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');
    _imagePath = p?.imagePath;

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

  Future<void> _pickImage(ImageSource source) async {
    final path = await _imageService.pickAndSaveImage(source: source);
    if (path != null) {
      setState(() {
        _imagePath = path;
        _imageChanged = true;
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppTheme.primaryDark,
                ),
                title: const Text(
                  'Take Photo with Camera',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppTheme.primaryDark,
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final nameErr = ProductValidator.validateName(name);
    if (nameErr != null) {
      setState(() => _errorMessage = nameErr);
      return;
    }

    final priceCentavos = parsePesoStringToCentavos(_priceController.text);
    final priceErr = ProductValidator.validatePriceCentavos(priceCentavos);
    if (priceErr != null) {
      setState(() => _errorMessage = priceErr);
      return;
    }

    final capitalCentavos = parsePesoStringToCentavos(_capitalController.text);
    final capitalErr = ProductValidator.validateCapitalCentavos(
      capitalCentavos,
    );
    if (capitalErr != null) {
      setState(() => _errorMessage = capitalErr);
      return;
    }

    setState(() => _isSaving = true);
    final repo = ref.read(productRepositoryProvider);

    try {
      if (isEditing) {
        final pId = widget.productToEdit!.id;
        await repo.updateProduct(
          id: pId,
          name: name,
          defaultPriceCentavos: priceCentavos!,
          capitalCentavos: capitalCentavos!,
          imagePath: _imagePath,
          updateImage: _imageChanged,
        );
        ref.invalidate(capitalHistoryProvider(pId));
      } else {
        await repo.createProduct(
          name: name,
          defaultPriceCentavos: priceCentavos!,
          capitalCentavos: capitalCentavos!,
          imagePath: _imagePath,
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

              // Product Picture Selector
              Center(
                child: _imagePath != null
                    ? Column(
                        children: [
                          ProductImageWidget(
                            imagePath: _imagePath,
                            width: 130,
                            height: 130,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.photo_camera_outlined,
                                  size: 18,
                                ),
                                label: const Text('Change Photo'),
                                onPressed: _showImagePickerOptions,
                              ),
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: AppTheme.accentRed,
                                ),
                                label: const Text(
                                  'Remove',
                                  style: TextStyle(color: AppTheme.accentRed),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _imagePath = null;
                                    _imageChanged = true;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      )
                    : InkWell(
                        onTap: _showImagePickerOptions,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.amber.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 36,
                                color: Colors.amber.shade900,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add Banana Photo',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Take a photo or choose from gallery',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),

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
