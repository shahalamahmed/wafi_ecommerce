import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/providers.dart';
import 'package:wafi_ecommerce/core/utils/text_utils.dart';
import 'package:wafi_ecommerce/models/category_model.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_card.dart';

class CategoryEditorSheet extends ConsumerStatefulWidget {
  final String tenantId;
  final CategoryModel? category;

  const CategoryEditorSheet({super.key, required this.tenantId, this.category});

  @override
  ConsumerState<CategoryEditorSheet> createState() =>
      _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends ConsumerState<CategoryEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageController;
  late final TextEditingController _sortOrderController;
  bool _isActive = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _nameController = TextEditingController(text: category?.name ?? '');
    _descriptionController = TextEditingController(
      text: category?.description ?? '',
    );
    _imageController = TextEditingController(text: category?.image ?? '');
    _sortOrderController = TextEditingController(
      text: (category?.sortOrder ?? 0).toString(),
    );
    _isActive = category?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final category = CategoryModel(
        id: widget.category?.id ?? '',
        name: _nameController.text.trim(),
        slug: slugify(_nameController.text),
        description: _descriptionController.text.trim(),
        parentId: widget.category?.parentId ?? '',
        level: widget.category?.level ?? 0,
        sortOrder: int.tryParse(_sortOrderController.text.trim()) ?? 0,
        image: _imageController.text.trim(),
        isActive: _isActive,
        productCount: widget.category?.productCount ?? 0,
        createdAt: widget.category?.createdAt,
        updatedAt: widget.category?.updatedAt,
      );

      await ref
          .read(categoryServiceProvider)
          .saveCategory(widget.tenantId, category);

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
                          widget.category == null
                              ? 'Add Category'
                              : 'Edit Category',
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
                    label: 'Category name',
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Category name is required'
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
                          controller: _sortOrderController,
                          label: 'Sort order',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _imageController,
                          label: 'Image URL',
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
                              widget.category == null
                                  ? 'Create Category'
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
