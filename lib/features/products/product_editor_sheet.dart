import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wafi_ecommerce/core/utils/helpers.dart';
import 'package:wafi_ecommerce/features/brands/brand_provider.dart';
import 'package:wafi_ecommerce/features/categories/category_provider.dart';
import 'package:wafi_ecommerce/features/brands/brand_model.dart';
import 'package:wafi_ecommerce/features/categories/category_model.dart';
import 'product_model.dart';
import 'product_provider.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_card.dart';

class ProductEditorSheet extends ConsumerStatefulWidget {
  final String tenantId;
  final ProductModel? product;

  const ProductEditorSheet({super.key, required this.tenantId, this.product});

  @override
  ConsumerState<ProductEditorSheet> createState() => _ProductEditorSheetState();
}

class _ProductEditorSheetState extends ConsumerState<ProductEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _skuController;
  late final TextEditingController _tagsController;
  late final TextEditingController _imagesController;
  late final TextEditingController _thumbnailController;
  late final TextEditingController _priceController;
  late final TextEditingController _comparePriceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _discountController;
  late final TextEditingController _stockController;
  late final TextEditingController _lowStockController;
  late final TextEditingController _currencyController;
  late final TextEditingController _variantOptionsController;
  String _categoryId = '';
  String _brandId = '';
  bool _trackInventory = true;
  bool _hasVariants = false;
  bool _isActive = true;
  bool _isFeatured = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _skuController = TextEditingController(text: product?.sku ?? '');
    _tagsController = TextEditingController(
      text: product?.tags.join(', ') ?? '',
    );
    _imagesController = TextEditingController(
      text: product?.images.join(', ') ?? '',
    );
    _thumbnailController = TextEditingController(
      text: product?.thumbnail ?? '',
    );
    _priceController = TextEditingController(
      text: _asText(product?.price ?? 0),
    );
    _comparePriceController = TextEditingController(
      text: _asText(product?.comparePrice ?? 0),
    );
    _costPriceController = TextEditingController(
      text: _asText(product?.costPrice ?? 0),
    );
    _discountController = TextEditingController(
      text: _asText(product?.discount ?? 0),
    );
    _stockController = TextEditingController(
      text: (product?.stock ?? 0).toString(),
    );
    _lowStockController = TextEditingController(
      text: (product?.lowStockAlert ?? 5).toString(),
    );
    _currencyController = TextEditingController(
      text: product?.currency ?? 'BDT',
    );
    _variantOptionsController = TextEditingController(
      text: product?.variantOptions.join(', ') ?? '',
    );
    _categoryId = product?.categoryId ?? '';
    _brandId = product?.brandId ?? '';
    _trackInventory = product?.trackInventory ?? true;
    _hasVariants = product?.hasVariants ?? false;
    _isActive = product?.isActive ?? true;
    _isFeatured = product?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    _tagsController.dispose();
    _imagesController.dispose();
    _thumbnailController.dispose();
    _priceController.dispose();
    _comparePriceController.dispose();
    _costPriceController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    _lowStockController.dispose();
    _currencyController.dispose();
    _variantOptionsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final categories = await ref
          .read(categoryServiceProvider)
          .fetchCategories(widget.tenantId);
      final brands = await ref
          .read(brandServiceProvider)
          .fetchBrands(widget.tenantId);

      final selectedCategory = (categories.data?.items ?? [])
          .cast<CategoryModel?>()
          .firstWhere(
            (category) => category?.id == _categoryId,
            orElse: () => null,
          );
      final selectedBrand = (brands.data?.items ?? [])
          .cast<BrandModel?>()
          .firstWhere(
            (brand) => brand?.id == _brandId,
            orElse: () => null,
          );

      final fallbackCategory =
          widget.product != null &&
              widget.product!.categoryId == _categoryId &&
              widget.product!.categoryName.trim().isNotEmpty
          ? widget.product
          : null;
      final fallbackBrand =
          widget.product != null &&
              widget.product!.brandId == _brandId &&
              widget.product!.brandName.trim().isNotEmpty
          ? widget.product
          : null;

      final product = ProductModel(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        slug: slugify(_nameController.text),
        description: _descriptionController.text.trim(),
        sku: _skuController.text.trim().isEmpty
            ? slugify(_nameController.text).toUpperCase()
            : _skuController.text.trim(),
        categoryId: selectedCategory?.id ?? fallbackCategory?.categoryId ?? '',
        categoryName:
            selectedCategory?.name ?? fallbackCategory?.categoryName ?? '',
        brandId: selectedBrand?.id ?? fallbackBrand?.brandId ?? '',
        brandName: selectedBrand?.name ?? fallbackBrand?.brandName ?? '',
        tags: _splitList(_tagsController.text),
        images: _splitList(_imagesController.text),
        thumbnail: _thumbnailController.text.trim(),
        price: _parseDouble(_priceController.text),
        comparePrice: _parseDouble(_comparePriceController.text),
        costPrice: _parseDouble(_costPriceController.text),
        discount: _parseDouble(_discountController.text),
        currency: _currencyController.text.trim().isEmpty
            ? 'BDT'
            : _currencyController.text.trim(),
        trackInventory: _trackInventory,
        stock: _parseInt(_stockController.text),
        lowStockAlert: _parseInt(_lowStockController.text, fallback: 5),
        isInStock: _trackInventory
            ? _parseInt(_stockController.text) > 0
            : true,
        hasVariants: _hasVariants,
        variantOptions: _splitList(_variantOptionsController.text),
        isActive: _isActive,
        isFeatured: _isFeatured,
        totalSold: widget.product?.totalSold ?? 0,
        createdAt: widget.product?.createdAt,
        updatedAt: widget.product?.updatedAt,
      );

      await ref
          .read(productServiceProvider)
          .saveProduct(widget.tenantId, product);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncCategories = ref.watch(categoryListProvider(widget.tenantId));
    final asyncBrands = ref.watch(brandListProvider(widget.tenantId));
    final categories = asyncCategories.categories;
    final brands = asyncBrands.brands;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = widget.product == null ? 'Add Product' : 'Edit Product';
    final categoryValue =
        categories.any((category) => category.id == _categoryId)
        ? _categoryId
        : '';
    final brandValue = brands.any((brand) => brand.id == _brandId)
        ? _brandId
        : '';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _Field(
                    controller: _nameController,
                    label: 'Product name',
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _descriptionController,
                    label: 'Description',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(controller: _skuController, label: 'SKU'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _currencyController,
                          label: 'Currency',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: categoryValue,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text(''),
                            ),
                            ...categories.map(
                              (category) => DropdownMenuItem<String>(
                                value: category.id,
                                child: Text(category.name),
                              ),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _categoryId = value ?? ''),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: brandValue,
                          decoration: const InputDecoration(labelText: 'Brand'),
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text(''),
                            ),
                            ...brands.map(
                              (brand) => DropdownMenuItem<String>(
                                value: brand.id,
                                child: Text(brand.name),
                              ),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _brandId = value ?? ''),
                        ),
                      ),
                    ],
                  ),
                  if (asyncCategories.error != null || asyncBrands.error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Categories or brands failed to load.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _Field(
                    controller: _thumbnailController,
                    label: 'Thumbnail URL',
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _imagesController,
                    label: 'Images URL list, comma separated',
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _tagsController,
                    label: 'Tags, comma separated',
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _variantOptionsController,
                    label: 'Variant options, comma separated',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: _priceController,
                          label: 'Price',
                          keyboardType: TextInputType.number,
                          validator: (value) => _validateNumber(value, 'Price'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _comparePriceController,
                          label: 'Compare price',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: _costPriceController,
                          label: 'Cost price',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _discountController,
                          label: 'Discount',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: _stockController,
                          label: 'Stock',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _lowStockController,
                          label: 'Low stock alert',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _trackInventory,
                    onChanged: (value) =>
                        setState(() => _trackInventory = value),
                    title: const Text('Track inventory'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    value: _hasVariants,
                    onChanged: (value) => setState(() => _hasVariants = value),
                    title: const Text('Has variants'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    value: _isFeatured,
                    onChanged: (value) => setState(() => _isFeatured = value),
                    title: const Text('Featured product'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                    title: const Text('Active'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isDark ? Colors.black : Colors.white,
                              ),
                            )
                          : Text(
                              widget.product == null
                                  ? 'Create Product'
                                  : 'Save Changes',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _asText(num value) {
    if (value % 1 == 0) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

  static int _parseInt(String value, {int fallback = 0}) {
    return int.tryParse(value.trim()) ?? fallback;
  }

  static double _parseDouble(String value) {
    return double.tryParse(value.trim()) ?? 0;
  }

  static List<String> _splitList(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static String? _validateNumber(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    if (double.tryParse(value.trim()) == null) return 'Enter a valid number';
    return null;
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }
}
