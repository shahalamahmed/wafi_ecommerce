import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/core/constants/sizes.dart';
import 'package:wafi_ecommerce/core/providers.dart';
import 'package:wafi_ecommerce/core/utils/text_utils.dart';
import 'package:wafi_ecommerce/features/auth/auth_provider.dart';
import 'package:wafi_ecommerce/features/brands/brand_editor_sheet.dart';
import 'package:wafi_ecommerce/features/brands/brands_providers.dart';
import 'package:wafi_ecommerce/features/categories/categories_providers.dart';
import 'package:wafi_ecommerce/features/categories/category_editor_sheet.dart';
import 'package:wafi_ecommerce/features/products/product_editor_sheet.dart';
import 'package:wafi_ecommerce/features/products/products_providers.dart';
import 'package:wafi_ecommerce/features/suppliers/supplier_editor_sheet.dart';
import 'package:wafi_ecommerce/features/suppliers/suppliers_providers.dart';
import 'package:wafi_ecommerce/models/brand_model.dart';
import 'package:wafi_ecommerce/models/category_model.dart';
import 'package:wafi_ecommerce/models/product_model.dart';
import 'package:wafi_ecommerce/models/supplier_model.dart';
import 'package:wafi_ecommerce/shared/widgets/app_section_header.dart';
import 'package:wafi_ecommerce/shared/widgets/empty_state.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_card.dart';
import 'package:wafi_ecommerce/shared/widgets/snackbar_message.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  String _search = '';
  String _selectedCategoryId = '';
  String _selectedBrandId = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openEditor({ProductModel? product}) async {
    final tenantId = ref.read(tenantIdProvider) ?? '';
    if (tenantId.isEmpty) return;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductEditorSheet(tenantId: tenantId, product: product),
    );

    if (!mounted || result != true) return;
    SnackbarMessage.show(
      context: context,
      message: product == null
          ? 'Product created successfully.'
          : 'Product updated successfully.',
    );
  }

  Future<void> _openCategoryEditor({CategoryModel? category}) async {
    final tenantId = ref.read(tenantIdProvider) ?? '';
    if (tenantId.isEmpty) return;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          CategoryEditorSheet(tenantId: tenantId, category: category),
    );

    if (!mounted || result != true) return;
    SnackbarMessage.show(
      context: context,
      message: category == null
          ? 'Category created successfully.'
          : 'Category updated successfully.',
    );
  }

  Future<void> _openBrandEditor({BrandModel? brand}) async {
    final tenantId = ref.read(tenantIdProvider) ?? '';
    if (tenantId.isEmpty) return;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BrandEditorSheet(tenantId: tenantId, brand: brand),
    );

    if (!mounted || result != true) return;
    SnackbarMessage.show(
      context: context,
      message: brand == null
          ? 'Brand created successfully.'
          : 'Brand updated successfully.',
    );
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    final tenantId = ref.read(tenantIdProvider) ?? '';
    if (tenantId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          'Delete ${category.name}? Products in this category will become uncategorized.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref
        .read(categoryServiceProvider)
        .deleteCategory(tenantId, category.id);
    if (!mounted) return;
    SnackbarMessage.show(context: context, message: 'Category deleted.');
  }

  Future<void> _deleteBrand(BrandModel brand) async {
    final tenantId = ref.read(tenantIdProvider) ?? '';
    if (tenantId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete brand?'),
        content: Text(
          'Delete ${brand.name}? Products using this brand will become unbranded.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(brandServiceProvider).deleteBrand(tenantId, brand.id);
    if (!mounted) return;
    SnackbarMessage.show(context: context, message: 'Brand deleted.');
  }

  Future<void> _openSupplierEditor({SupplierModel? supplier}) async {
    final tenantId = ref.read(tenantIdProvider) ?? '';
    if (tenantId.isEmpty) return;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          SupplierEditorSheet(tenantId: tenantId, supplier: supplier),
    );

    if (!mounted || result != true) return;
    SnackbarMessage.show(
      context: context,
      message: supplier == null
          ? 'Supplier created successfully.'
          : 'Supplier updated successfully.',
    );
  }

  Future<void> _deleteSupplier(SupplierModel supplier) async {
    final tenantId = ref.read(tenantIdProvider) ?? '';
    if (tenantId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete supplier?'),
        content: Text('Delete ${supplier.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref
        .read(supplierServiceProvider)
        .deleteSupplier(tenantId, supplier.id);
    if (!mounted) return;
    SnackbarMessage.show(context: context, message: 'Supplier deleted.');
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final tenantId = ref.read(tenantIdProvider) ?? '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Delete ${product.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || tenantId.isEmpty) return;

    await ref.read(productServiceProvider).deleteProduct(tenantId, product.id);

    if (!mounted) return;
    SnackbarMessage.show(context: context, message: 'Product deleted.');
  }

  @override
  Widget build(BuildContext context) {
    final tenantId = ref.watch(tenantIdProvider) ?? '';
    final asyncProducts = ref.watch(productListProvider(tenantId));
    final asyncCategories = ref.watch(categoryListProvider(tenantId));
    final asyncBrands = ref.watch(brandListProvider(tenantId));
    final asyncSuppliers = ref.watch(supplierListProvider(tenantId));
    final products = asyncProducts.valueOrNull ?? const <ProductModel>[];
    final categories = asyncCategories.valueOrNull ?? const <CategoryModel>[];
    final brands = asyncBrands.valueOrNull ?? const <BrandModel>[];
    final suppliers = asyncSuppliers.valueOrNull ?? const <SupplierModel>[];
    final activeCategoryId =
        categories.any((category) => category.id == _selectedCategoryId)
        ? _selectedCategoryId
        : '';
    final activeBrandId = brands.any((brand) => brand.id == _selectedBrandId)
        ? _selectedBrandId
        : '';
    final filtered = products.where((product) {
      final q = _search.trim().toLowerCase();
      final matchesQuery =
          q.isEmpty ||
          product.name.toLowerCase().contains(q) ||
          product.sku.toLowerCase().contains(q) ||
          product.categoryName.toLowerCase().contains(q) ||
          product.brandName.toLowerCase().contains(q);
      final matchesCategory =
          activeCategoryId.isEmpty || product.categoryId == activeCategoryId;
      final matchesBrand =
          activeBrandId.isEmpty || product.brandId == activeBrandId;
      return matchesQuery && matchesCategory && matchesBrand;
    }).toList();

    final totalStock = products.fold<int>(
      0,
      (runningStock, product) => runningStock + product.stock,
    );
    final lowStockCount = products
        .where((product) => product.isLowStock)
        .length;
    final featuredCount = products
        .where((product) => product.isFeatured)
        .length;
    final categoryProductCounts = <String, int>{};
    final brandProductCounts = <String, int>{};
    for (final product in products) {
      final categoryId = product.categoryId.trim();
      final brandId = product.brandId.trim();
      if (categoryId.isNotEmpty) {
        categoryProductCounts.update(
          categoryId,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
      if (brandId.isNotEmpty) {
        brandProductCounts.update(
          brandId,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'Products',
            subtitle: 'Manage catalog, stock, pricing and visibility.',
            actionLabel: 'Add Product',
            onActionTap: () => _openEditor(),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _search = value),
              decoration: const InputDecoration(
                labelText: 'Search products',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('All (${products.length})'),
                    selected: activeCategoryId.isEmpty,
                    onSelected: (_) => setState(() => _selectedCategoryId = ''),
                  ),
                ),
                ...categories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        '${category.name} (${categoryProductCounts[category.id] ?? 0})',
                      ),
                      selected: activeCategoryId == category.id,
                      onSelected: (_) =>
                          setState(() => _selectedCategoryId = category.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All brands'),
                    selected: activeBrandId.isEmpty,
                    onSelected: (_) => setState(() => _selectedBrandId = ''),
                  ),
                ),
                ...brands.map(
                  (brand) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        '${brand.name} (${brandProductCounts[brand.id] ?? 0})',
                      ),
                      selected: activeBrandId == brand.id,
                      onSelected: (_) =>
                          setState(() => _selectedBrandId = brand.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _MetricTile(
                label: 'Items',
                value: products.length.toString(),
                accent: AppColors.primary,
              ),
              _MetricTile(
                label: 'Stock',
                value: totalStock.toString(),
                accent: AppColors.success,
              ),
              _MetricTile(
                label: 'Low stock',
                value: lowStockCount.toString(),
                accent: AppColors.warning,
              ),
              _MetricTile(
                label: 'Featured',
                value: featuredCount.toString(),
                accent: AppColors.purple,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppSectionHeader(
            title: 'Categories',
            subtitle: categories.isEmpty
                ? 'Group products so catalog filtering stays clean.'
                : 'Showing ${categories.length} categories.',
            actionLabel: 'Add Category',
            onActionTap: () => _openCategoryEditor(),
          ),
          const SizedBox(height: 12),
          if (asyncCategories.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (categories.isEmpty)
            EmptyStateCard(
              icon: Icons.category_outlined,
              title: 'No categories yet',
              message: 'Create categories before assigning products to them.',
              actionLabel: 'Create Category',
              onAction: () => _openCategoryEditor(),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories
                    .map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 240,
                          child: _CategoryCard(
                            category: category,
                            productCount:
                                categoryProductCounts[category.id] ??
                                category.productCount,
                            onFilter: () => setState(
                              () => _selectedCategoryId = category.id,
                            ),
                            onEdit: () =>
                                _openCategoryEditor(category: category),
                            onDelete: () => _deleteCategory(category),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),
          AppSectionHeader(
            title: 'Brands',
            subtitle: brands.isEmpty
                ? 'Keep product brands standardized across the catalog.'
                : 'Showing ${brands.length} brands.',
            actionLabel: 'Add Brand',
            onActionTap: () => _openBrandEditor(),
          ),
          const SizedBox(height: 12),
          if (asyncBrands.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (brands.isEmpty)
            EmptyStateCard(
              icon: Icons.branding_watermark_outlined,
              title: 'No brands yet',
              message: 'Create brands before assigning products to them.',
              actionLabel: 'Create Brand',
              onAction: () => _openBrandEditor(),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: brands
                    .map(
                      (brand) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 240,
                          child: _BrandCard(
                            brand: brand,
                            productCount:
                                brandProductCounts[brand.id] ??
                                brand.productCount,
                            onEdit: () => _openBrandEditor(brand: brand),
                            onDelete: () => _deleteBrand(brand),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),
          AppSectionHeader(
            title: 'Suppliers',
            subtitle: suppliers.isEmpty
                ? 'Track purchase partners and vendor contacts.'
                : 'Showing ${suppliers.length} suppliers.',
            actionLabel: 'Add Supplier',
            onActionTap: () => _openSupplierEditor(),
          ),
          const SizedBox(height: 12),
          if (asyncSuppliers.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (suppliers.isEmpty)
            EmptyStateCard(
              icon: Icons.local_shipping_outlined,
              title: 'No suppliers yet',
              message:
                  'Create suppliers to keep procurement contacts organized.',
              actionLabel: 'Create Supplier',
              onAction: () => _openSupplierEditor(),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: suppliers
                    .map(
                      (supplier) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 260,
                          child: _SupplierCard(
                            supplier: supplier,
                            onEdit: () =>
                                _openSupplierEditor(supplier: supplier),
                            onDelete: () => _deleteSupplier(supplier),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),
          AppSectionHeader(
            title: 'Catalog',
            subtitle: filtered.isEmpty
                ? 'No products match the current filters.'
                : 'Showing ${filtered.length} products.',
          ),
          const SizedBox(height: 12),
          if (asyncProducts.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (filtered.isEmpty)
            EmptyStateCard(
              icon: Icons.inventory_2_outlined,
              title: 'No products yet',
              message: 'Add your first product to start the catalog.',
              actionLabel: 'Create Product',
              onAction: () => _openEditor(),
            )
          else
            Column(
              children: filtered
                  .map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ProductCard(
                        product: product,
                        onEdit: () => _openEditor(product: product),
                        onDelete: () => _deleteProduct(product),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final int productCount;
  final VoidCallback onFilter;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.productCount,
    required this.onFilter,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'filter') onFilter();
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'filter',
                    child: Text('Filter products'),
                  ),
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            category.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            category.description.trim().isEmpty
                ? 'No description added yet.'
                : category.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryFor(brightness),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(
                label: category.isActive ? 'Active' : 'Inactive',
                color: category.isActive
                    ? AppColors.success
                    : AppColors.warning,
              ),
              _StatusPill(
                label: '$productCount products',
                color: AppColors.primary,
              ),
              _StatusPill(
                label: 'Sort ${category.sortOrder}',
                color: AppColors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final BrandModel brand;
  final int productCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BrandCard({
    required this.brand,
    required this.productCount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.branding_watermark_rounded,
                  color: AppColors.purple,
                  size: 20,
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            brand.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            brand.description.trim().isEmpty
                ? (brand.website.trim().isEmpty
                      ? 'No description added yet.'
                      : brand.website)
                : brand.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryFor(brightness),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(
                label: brand.isActive ? 'Active' : 'Inactive',
                color: brand.isActive ? AppColors.success : AppColors.warning,
              ),
              _StatusPill(
                label: '$productCount products',
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupplierCard extends StatelessWidget {
  final SupplierModel supplier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SupplierCard({
    required this.supplier,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            supplier.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            supplier.contactPerson.trim().isEmpty
                ? (supplier.phone.trim().isEmpty
                      ? 'No contact added yet.'
                      : supplier.phone)
                : supplier.contactPerson,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryFor(brightness),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            supplier.email.trim().isEmpty ? supplier.address : supplier.email,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryFor(brightness),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(
                label: supplier.isActive ? 'Active' : 'Inactive',
                color: supplier.isActive
                    ? AppColors.success
                    : AppColors.warning,
              ),
              _StatusPill(
                label: supplier.tradeTerms.trim().isEmpty
                    ? 'No terms'
                    : supplier.tradeTerms,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.circle_rounded, color: accent, size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 64,
              height: 64,
              color: AppColors.primary.withValues(alpha: 0.12),
              child: product.thumbnail.trim().isNotEmpty
                  ? Image.network(
                      product.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stackTrace) => const Icon(
                        Icons.inventory_2_rounded,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(
                      Icons.inventory_2_rounded,
                      color: AppColors.primary,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  [
                        if (product.categoryName.isNotEmpty)
                          product.categoryName,
                        if (product.brandName.isNotEmpty) product.brandName,
                      ].join(' | ').isEmpty
                      ? 'Uncategorized | Unbranded'
                      : [
                          if (product.categoryName.isNotEmpty)
                            product.categoryName,
                          if (product.brandName.isNotEmpty) product.brandName,
                        ].join(' | '),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryFor(brightness),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusPill(
                      label: product.isActive ? 'Active' : 'Inactive',
                      color: product.isActive
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    _StatusPill(
                      label: product.isOutOfStock
                          ? 'Out of stock'
                          : 'Stock ${product.stock}',
                      color: product.isOutOfStock
                          ? AppColors.error
                          : product.isLowStock
                          ? AppColors.warning
                          : AppColors.primary,
                    ),
                    _StatusPill(
                      label: product.isFeatured ? 'Featured' : 'Regular',
                      color: product.isFeatured
                          ? AppColors.purple
                          : AppColors.textSecondaryFor(brightness),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${formatMoney(product.price, symbol: product.currency)}  |  SKU ${product.sku}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
