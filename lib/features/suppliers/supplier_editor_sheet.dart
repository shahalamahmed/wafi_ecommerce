import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/providers.dart';
import 'package:wafi_ecommerce/models/supplier_model.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_card.dart';

class SupplierEditorSheet extends ConsumerStatefulWidget {
  final String tenantId;
  final SupplierModel? supplier;

  const SupplierEditorSheet({super.key, required this.tenantId, this.supplier});

  @override
  ConsumerState<SupplierEditorSheet> createState() =>
      _SupplierEditorSheetState();
}

class _SupplierEditorSheetState extends ConsumerState<SupplierEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _contactPersonController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _tradeTermsController;
  late final TextEditingController _currencyController;
  bool _isActive = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final supplier = widget.supplier;
    _nameController = TextEditingController(text: supplier?.name ?? '');
    _contactPersonController = TextEditingController(
      text: supplier?.contactPerson ?? '',
    );
    _emailController = TextEditingController(text: supplier?.email ?? '');
    _phoneController = TextEditingController(text: supplier?.phone ?? '');
    _addressController = TextEditingController(text: supplier?.address ?? '');
    _tradeTermsController = TextEditingController(
      text: supplier?.tradeTerms ?? '',
    );
    _currencyController = TextEditingController(
      text: supplier?.currency ?? 'BDT',
    );
    _isActive = supplier?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _tradeTermsController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final supplier = SupplierModel(
        id: widget.supplier?.id ?? '',
        name: _nameController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        tradeTerms: _tradeTermsController.text.trim(),
        currency: _currencyController.text.trim().isEmpty
            ? 'BDT'
            : _currencyController.text.trim(),
        isActive: _isActive,
        totalOrders: widget.supplier?.totalOrders ?? 0,
        totalSpent: widget.supplier?.totalSpent ?? 0,
        createdAt: widget.supplier?.createdAt,
        updatedAt: widget.supplier?.updatedAt,
      );

      await ref
          .read(supplierServiceProvider)
          .saveSupplier(widget.tenantId, supplier);
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
                          widget.supplier == null
                              ? 'Add Supplier'
                              : 'Edit Supplier',
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
                    label: 'Supplier name',
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Supplier name is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: _contactPersonController,
                          label: 'Contact person',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _phoneController,
                          label: 'Phone',
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: _emailController,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
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
                  _Field(
                    controller: _addressController,
                    label: 'Address',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _tradeTermsController,
                    label: 'Trade terms',
                  ),
                  const SizedBox(height: 12),
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
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              widget.supplier == null
                                  ? 'Create Supplier'
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
