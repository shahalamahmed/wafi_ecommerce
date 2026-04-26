import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/api/firestore_service.dart';
import 'package:wafi_ecommerce/core/utils/helpers.dart';
import 'package:wafi_ecommerce/shared/widgets/snackbar_message.dart';
import 'brand_model.dart';
import 'brand_provider.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_card.dart';

class BrandEditorSheet extends ConsumerStatefulWidget {
  final String tenantId;
  final BrandModel? brand;

  const BrandEditorSheet({super.key, required this.tenantId, this.brand});

  @override
  ConsumerState<BrandEditorSheet> createState() => _BrandEditorSheetState();
}

class _BrandEditorSheetState extends ConsumerState<BrandEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _websiteController;
  late final TextEditingController _logoController;
  bool _isActive = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final brand = widget.brand;
    _nameController = TextEditingController(text: brand?.name ?? '');
    _descriptionController = TextEditingController(
      text: brand?.description ?? '',
    );
    _websiteController = TextEditingController(text: brand?.website ?? '');
    _logoController = TextEditingController(text: brand?.logo ?? '');
    _isActive = brand?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final brand = BrandModel(
        id: widget.brand?.id ?? '',
        name: _nameController.text.trim(),
        slug: slugify(_nameController.text),
        logo: _logoController.text.trim(),
        description: _descriptionController.text.trim(),
        website: _websiteController.text.trim(),
        isActive: _isActive,
        productCount: widget.brand?.productCount ?? 0,
        createdAt: widget.brand?.createdAt,
        updatedAt: widget.brand?.updatedAt,
      );

      await ref.read(brandListProvider(widget.tenantId).notifier).saveBrand(brand);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      SnackbarMessage.show(context: context, message: e.toString(), isError: true);
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
                          widget.brand == null ? 'Add Brand' : 'Edit Brand',
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
                    label: 'Brand name',
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Brand name is required'
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
                        child: _Field(
                          controller: _websiteController,
                          label: 'Website',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _logoController,
                          label: 'Logo URL',
                        ),
                      ),
                    ],
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
                              widget.brand == null
                                  ? 'Create Brand'
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
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }
}
