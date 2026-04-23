import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/providers.dart';
import 'package:wafi_ecommerce/core/utils/text_utils.dart';
import 'package:wafi_ecommerce/features/auth/auth_provider.dart';
import 'package:wafi_ecommerce/models/product_model.dart';
import 'package:wafi_ecommerce/services/order_service.dart';
import 'package:wafi_ecommerce/shared/widgets/empty_state.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_card.dart';

class OrderEditorSheet extends ConsumerStatefulWidget {
  final String tenantId;

  const OrderEditorSheet({super.key, required this.tenantId});

  @override
  ConsumerState<OrderEditorSheet> createState() => _OrderEditorSheetState();
}

class _OrderEditorSheetState extends ConsumerState<OrderEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _couponCodeController = TextEditingController();
  final _couponDiscountController = TextEditingController(text: '0');
  final _deliveryChargeController = TextEditingController(text: '100');
  final _taxController = TextEditingController(text: '0');
  final _amountPaidController = TextEditingController(text: '0');
  final _streetController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController(text: 'Dhaka');
  final _districtController = TextEditingController(text: 'Dhaka');
  final _postalCodeController = TextEditingController();
  final _trackingNumberController = TextEditingController();
  final _noteController = TextEditingController();
  final _internalNoteController = TextEditingController();
  String _paymentStatus = 'unpaid';
  String _paymentMethod = 'cash';
  String _status = 'pending';
  String _shippingMethod = 'courier';
  String _source = 'pos';
  bool _saving = false;
  final List<_OrderLineDraft> _lines = [_OrderLineDraft()];

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _discountController.dispose();
    _couponCodeController.dispose();
    _couponDiscountController.dispose();
    _deliveryChargeController.dispose();
    _taxController.dispose();
    _amountPaidController.dispose();
    _streetController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _postalCodeController.dispose();
    _trackingNumberController.dispose();
    _noteController.dispose();
    _internalNoteController.dispose();
    super.dispose();
  }

  Future<void> _save(List<ProductModel> products) async {
    if (!_formKey.currentState!.validate()) return;

    final items = <OrderLineRequest>[];
    for (final line in _lines) {
      if (line.productId == null || line.quantity <= 0) {
        continue;
      }
      items.add(
        OrderLineRequest(productId: line.productId!, quantity: line.quantity),
      );
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one product item.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final auth = ref.read(authControllerProvider);
      final request = CreateOrderRequest(
        customerId: '',
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        customerEmail: _customerEmailController.text.trim(),
        items: items,
        discount: _parseDouble(_discountController.text),
        couponCode: _couponCodeController.text.trim().isEmpty
            ? null
            : _couponCodeController.text.trim(),
        couponDiscount: _parseDouble(_couponDiscountController.text),
        deliveryCharge: _parseDouble(_deliveryChargeController.text),
        tax: _parseDouble(_taxController.text),
        paymentStatus: _paymentStatus,
        paymentMethod: _paymentMethod,
        amountPaid: _parseDouble(_amountPaidController.text),
        status: _status,
        shippingMethod: _shippingMethod,
        shippingAddress: {
          'name': _customerNameController.text.trim(),
          'phone': _customerPhoneController.text.trim(),
          'street': _streetController.text.trim(),
          'area': _areaController.text.trim(),
          'city': _cityController.text.trim(),
          'district': _districtController.text.trim(),
          'postalCode': _postalCodeController.text.trim(),
          'country': 'Bangladesh',
        },
        trackingNumber: _trackingNumberController.text.trim(),
        source: _source,
        note: _noteController.text.trim(),
        internalNote: _internalNoteController.text.trim(),
        createdByUid: auth.uid ?? '',
        createdByName: auth.email?.split('@').first ?? 'staff',
      );

      final result = await ref
          .read(orderServiceProvider)
          .createOrder(widget.tenantId, request);
      if (!mounted) return;
      Navigator.of(context).pop(result);
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
    final asyncProducts = ref.watch(productsStreamProvider(widget.tenantId));
    final products = asyncProducts.valueOrNull ?? const <ProductModel>[];
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                          'Create Order',
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
                  const _SectionTitle(title: 'Customer'),
                  const SizedBox(height: 10),
                  _Field(
                    controller: _customerNameController,
                    label: 'Customer name',
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Customer name is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: _customerPhoneController,
                          label: 'Phone',
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Phone is required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _customerEmailController,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _SectionTitle(title: 'Items'),
                  const SizedBox(height: 10),
                  if (asyncProducts.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (products.isEmpty)
                    const EmptyStateCard(
                      icon: Icons.inventory_2_outlined,
                      title: 'Add products first',
                      message:
                          'You need at least one product in the catalog to create an order.',
                    )
                  else
                    Column(
                      children: [
                        ..._lines.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _OrderLineField(
                              key: ValueKey(entry.key),
                              products: products,
                              draft: entry.value,
                              onRemove: _lines.length > 1
                                  ? () => setState(
                                      () => _lines.removeAt(entry.key),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              setState(() => _lines.add(_OrderLineDraft())),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add item'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  const _SectionTitle(title: 'Pricing & Payment'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: _discountController,
                          label: 'Discount',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _couponCodeController,
                          label: 'Coupon code',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: _couponDiscountController,
                          label: 'Coupon discount',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _deliveryChargeController,
                          label: 'Delivery charge',
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
                          controller: _taxController,
                          label: 'Tax',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _amountPaidController,
                          label: 'Amount paid',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SelectChip(
                    label: 'Payment',
                    value: _paymentStatus,
                    options: const ['unpaid', 'partial', 'paid'],
                    onChanged: (value) =>
                        setState(() => _paymentStatus = value),
                  ),
                  const SizedBox(height: 12),
                  _SelectChip(
                    label: 'Method',
                    value: _paymentMethod,
                    options: const ['cash', 'bkash', 'nagad', 'card'],
                    onChanged: (value) =>
                        setState(() => _paymentMethod = value),
                  ),
                  const SizedBox(height: 12),
                  _SelectChip(
                    label: 'Status',
                    value: _status,
                    options: const [
                      'pending',
                      'confirmed',
                      'processing',
                      'shipped',
                      'delivered',
                      'cancelled',
                    ],
                    onChanged: (value) => setState(() => _status = value),
                  ),
                  const SizedBox(height: 12),
                  _SelectChip(
                    label: 'Shipping',
                    value: _shippingMethod,
                    options: const ['courier', 'self-pickup'],
                    onChanged: (value) =>
                        setState(() => _shippingMethod = value),
                  ),
                  const SizedBox(height: 12),
                  _SelectChip(
                    label: 'Source',
                    value: _source,
                    options: const ['pos', 'phone', 'online'],
                    onChanged: (value) => setState(() => _source = value),
                  ),
                  const SizedBox(height: 16),
                  const _SectionTitle(title: 'Shipping address'),
                  const SizedBox(height: 10),
                  _Field(controller: _streetController, label: 'Street'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: _areaController,
                          label: 'Area',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _cityController,
                          label: 'City',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: _districtController,
                          label: 'District',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _postalCodeController,
                          label: 'Postal code',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _trackingNumberController,
                    label: 'Tracking number',
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _noteController,
                    label: 'Customer note',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _internalNoteController,
                    label: 'Internal note',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _OrderSummary(
                    tenantId: widget.tenantId,
                    lines: _lines,
                    products: products,
                    discount: _parseDouble(_discountController.text),
                    couponDiscount: _parseDouble(
                      _couponDiscountController.text,
                    ),
                    deliveryCharge: _parseDouble(
                      _deliveryChargeController.text,
                    ),
                    tax: _parseDouble(_taxController.text),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : () => _save(products),
                      child: _saving
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isDark ? Colors.black : Colors.white,
                              ),
                            )
                          : const Text('Create Order'),
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

  static double _parseDouble(String value) {
    return double.tryParse(value.trim()) ?? 0;
  }
}

class _OrderLineDraft {
  String? productId;
  int quantity = 1;
}

class _OrderLineField extends StatelessWidget {
  final List<ProductModel> products;
  final _OrderLineDraft draft;
  final VoidCallback? onRemove;

  const _OrderLineField({
    super.key,
    required this.products,
    required this.draft,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: draft.productId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Product'),
                  items: products
                      .map(
                        (product) => DropdownMenuItem<String>(
                          value: product.id,
                          child: Text(
                            '${product.name} • ${formatMoney(product.price, symbol: product.currency)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => draft.productId = value,
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: draft.quantity.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  onChanged: (value) {
                    draft.quantity = int.tryParse(value.trim()) ?? 1;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final String tenantId;
  final List<_OrderLineDraft> lines;
  final List<ProductModel> products;
  final double discount;
  final double couponDiscount;
  final double deliveryCharge;
  final double tax;

  const _OrderSummary({
    required this.tenantId,
    required this.lines,
    required this.products,
    required this.discount,
    required this.couponDiscount,
    required this.deliveryCharge,
    required this.tax,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = lines.fold<double>(0, (sum, line) {
      final product = products.firstWhere(
        (item) => item.id == line.productId,
        orElse: () => ProductModel(
          id: '',
          name: '',
          slug: '',
          description: '',
          sku: '',
          categoryId: '',
          categoryName: '',
          brandId: '',
          brandName: '',
          tags: const [],
          images: const [],
          thumbnail: '',
          price: 0,
          comparePrice: 0,
          costPrice: 0,
          discount: 0,
          currency: 'BDT',
          trackInventory: true,
          stock: 0,
          lowStockAlert: 0,
          isInStock: false,
          hasVariants: false,
          variantOptions: const [],
          isActive: true,
          isFeatured: false,
          totalSold: 0,
        ),
      );
      return sum + (product.price * line.quantity);
    });

    final total = (subtotal - discount - couponDiscount + deliveryCharge + tax)
        .clamp(0, double.infinity);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated total',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Subtotal', value: formatMoney(subtotal)),
          _SummaryRow(label: 'Discount', value: formatMoney(discount)),
          _SummaryRow(label: 'Coupon', value: formatMoney(couponDiscount)),
          _SummaryRow(label: 'Delivery', value: formatMoney(deliveryCharge)),
          _SummaryRow(label: 'Tax', value: formatMoney(tax)),
          const Divider(height: 20),
          _SummaryRow(
            label: 'Grand total',
            value: formatMoney(total),
            strong: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _SelectChip({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: options
          .map(
            (option) => DropdownMenuItem<String>(
              value: option,
              child: Text(capitalizeWords(option.replaceAll('_', ' '))),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
