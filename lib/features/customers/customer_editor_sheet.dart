import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/providers.dart';
import 'package:wafi_ecommerce/models/customer_model.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_card.dart';

class CustomerEditorSheet extends ConsumerStatefulWidget {
  final String tenantId;
  final CustomerModel? customer;

  const CustomerEditorSheet({super.key, required this.tenantId, this.customer});

  @override
  ConsumerState<CustomerEditorSheet> createState() =>
      _CustomerEditorSheetState();
}

class _CustomerEditorSheetState extends ConsumerState<CustomerEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _avatarController;
  late final TextEditingController _streetController;
  late final TextEditingController _areaController;
  late final TextEditingController _cityController;
  late final TextEditingController _districtController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _loyaltyController;
  late final TextEditingController _totalOrdersController;
  late final TextEditingController _totalSpentController;
  String _group = 'regular';
  String _source = 'walk-in';
  bool _isActive = true;
  bool _isBlocked = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    final address = customer?.defaultAddress ?? const <String, dynamic>{};
    _nameController = TextEditingController(text: customer?.name ?? '');
    _emailController = TextEditingController(text: customer?.email ?? '');
    _phoneController = TextEditingController(text: customer?.phone ?? '');
    _avatarController = TextEditingController(text: customer?.avatar ?? '');
    _streetController = TextEditingController(
      text: address['street']?.toString() ?? '',
    );
    _areaController = TextEditingController(
      text: address['area']?.toString() ?? '',
    );
    _cityController = TextEditingController(
      text: address['city']?.toString() ?? '',
    );
    _districtController = TextEditingController(
      text: address['district']?.toString() ?? '',
    );
    _postalCodeController = TextEditingController(
      text: address['postalCode']?.toString() ?? '',
    );
    _loyaltyController = TextEditingController(
      text: (customer?.loyaltyPoints ?? 0).toString(),
    );
    _totalOrdersController = TextEditingController(
      text: (customer?.totalOrders ?? 0).toString(),
    );
    _totalSpentController = TextEditingController(
      text: (customer?.totalSpent ?? 0).toString(),
    );
    _group = customer?.customerGroup ?? 'regular';
    _source = customer?.source ?? 'walk-in';
    _isActive = customer?.isActive ?? true;
    _isBlocked = customer?.isBlocked ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();
    _streetController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _postalCodeController.dispose();
    _loyaltyController.dispose();
    _totalOrdersController.dispose();
    _totalSpentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final totalOrders = int.tryParse(_totalOrdersController.text.trim()) ?? 0;
      final totalSpent =
          double.tryParse(_totalSpentController.text.trim()) ?? 0;
      final customer = CustomerModel(
        id: widget.customer?.id ?? '',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        avatar: _avatarController.text.trim(),
        defaultAddress: {
          'label': 'Primary',
          'street': _streetController.text.trim(),
          'area': _areaController.text.trim(),
          'city': _cityController.text.trim(),
          'district': _districtController.text.trim(),
          'postalCode': _postalCodeController.text.trim(),
          'country': 'Bangladesh',
        },
        customerGroup: _group,
        loyaltyPoints: int.tryParse(_loyaltyController.text.trim()) ?? 0,
        totalOrders: totalOrders,
        totalSpent: totalSpent,
        averageOrderValue: totalOrders > 0 ? totalSpent / totalOrders : 0,
        source: _source,
        isActive: _isActive,
        isBlocked: _isBlocked,
      );

      await ref
          .read(customerServiceProvider)
          .saveCustomer(widget.tenantId, customer);
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
                          widget.customer == null
                              ? 'Add Customer'
                              : 'Edit Customer',
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
                    label: 'Customer name',
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: _phoneController,
                          label: 'Phone',
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _emailController,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Field(controller: _avatarController, label: 'Avatar URL'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: _streetController,
                          label: 'Street',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _areaController,
                          label: 'Area',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: _cityController,
                          label: 'City',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _districtController,
                          label: 'District',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: _postalCodeController,
                          label: 'Postal code',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _loyaltyController,
                          label: 'Loyalty points',
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
                          controller: _totalOrdersController,
                          label: 'Total orders',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _totalSpentController,
                          label: 'Total spent',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _group,
                    decoration: const InputDecoration(
                      labelText: 'Customer group',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'regular',
                        child: Text('Regular'),
                      ),
                      DropdownMenuItem(value: 'vip', child: Text('VIP')),
                      DropdownMenuItem(
                        value: 'wholesale',
                        child: Text('Wholesale'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _group = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _source,
                    decoration: const InputDecoration(labelText: 'Source'),
                    items: const [
                      DropdownMenuItem(
                        value: 'walk-in',
                        child: Text('Walk-in'),
                      ),
                      DropdownMenuItem(value: 'online', child: Text('Online')),
                      DropdownMenuItem(value: 'phone', child: Text('Phone')),
                      DropdownMenuItem(value: 'pos', child: Text('POS')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _source = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                    title: const Text('Active'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    value: _isBlocked,
                    onChanged: (value) => setState(() => _isBlocked = value),
                    title: const Text('Blocked'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              widget.customer == null
                                  ? 'Create Customer'
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
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }
}
