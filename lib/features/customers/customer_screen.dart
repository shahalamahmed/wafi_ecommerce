import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/core/constants/sizes.dart';

import 'package:wafi_ecommerce/core/utils/helpers.dart';
import 'package:wafi_ecommerce/features/auth/auth_provider.dart';
import 'package:wafi_ecommerce/features/customers/customer_editor_sheet.dart';
import 'customer_provider.dart';
import 'customer_model.dart';
import 'package:wafi_ecommerce/shared/widgets/app_section_header.dart';
import 'package:wafi_ecommerce/shared/widgets/empty_state.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_card.dart';
import 'package:wafi_ecommerce/shared/widgets/snackbar_message.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openEditor({CustomerModel? customer}) async {
    final tenantId = ref.read(tenantIdProvider) ?? '';
    if (tenantId.isEmpty) return;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          CustomerEditorSheet(tenantId: tenantId, customer: customer),
    );

    if (!mounted || result != true) return;
    SnackbarMessage.show(
      context: context,
      message: customer == null
          ? 'Customer created successfully.'
          : 'Customer updated successfully.',
    );
  }

  Future<void> _deleteCustomer(CustomerModel customer) async {
    final tenantId = ref.read(tenantIdProvider) ?? '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete customer?'),
        content: Text('Delete ${customer.name}?'),
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

    await ref
        .read(customerServiceProvider)
        .deleteCustomer(tenantId, customer.id);
    if (!mounted) return;
    SnackbarMessage.show(context: context, message: 'Customer deleted.');
  }

  @override
  Widget build(BuildContext context) {
    final tenantId = ref.watch(tenantIdProvider) ?? '';
    final customerState = ref.watch(customerListProvider(tenantId));
    final customers = customerState.customers;
    final filtered = customers.where((customer) {
      final q = _search.trim().toLowerCase();
      if (q.isEmpty) return true;
      return customer.name.toLowerCase().contains(q) ||
          customer.phone.toLowerCase().contains(q) ||
          customer.email.toLowerCase().contains(q) ||
          customer.customerGroup.toLowerCase().contains(q);
    }).toList();

    final vipCount = customers
        .where((customer) => customer.customerGroup == 'vip')
        .length;
    final blockedCount = customers
        .where((customer) => customer.isBlocked)
        .length;
    final totalSpent = customers.fold<double>(
      0,
      (sum, customer) => sum + customer.totalSpent,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'Customers',
            subtitle: 'Track buyers, loyalty and customer lifetime value.',
            actionLabel: 'Add Customer',
            onActionTap: () => _openEditor(),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _search = value),
              decoration: const InputDecoration(
                labelText: 'Search customers',
                prefixIcon: Icon(Icons.search_rounded),
              ),
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
                label: 'Customers',
                value: customers.length.toString(),
                accent: AppColors.primary,
              ),
              _MetricTile(
                label: 'VIP',
                value: vipCount.toString(),
                accent: AppColors.purple,
              ),
              _MetricTile(
                label: 'Blocked',
                value: blockedCount.toString(),
                accent: AppColors.error,
              ),
              _MetricTile(
                label: 'Spent',
                value: formatMoney(totalSpent),
                accent: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppSectionHeader(
            title: 'Customer list',
            subtitle: filtered.isEmpty
                ? 'No customer matches the current search.'
                : 'Showing ${filtered.length} customers.',
          ),
          const SizedBox(height: 12),
          if (customerState.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (filtered.isEmpty)
            EmptyStateCard(
              icon: Icons.people_outline_rounded,
              title: 'No customers yet',
              message:
                  'Add a customer manually or create an order to auto-create one.',
              actionLabel: 'Add Customer',
              onAction: () => _openEditor(),
            )
          else
            Column(
              children: filtered
                  .map(
                    (customer) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CustomerCard(
                        customer: customer,
                        onEdit: () => _openEditor(customer: customer),
                        onDelete: () => _deleteCustomer(customer),
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
            child: Icon(Icons.person_rounded, color: accent, size: 18),
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

class _CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomerCard({
    required this.customer,
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
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Text(
              initialsFrom(customer.name),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
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
                        customer.name,
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
                  customer.phone.isNotEmpty ? customer.phone : customer.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryFor(brightness),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(
                      label: customer.customerGroup,
                      color: AppColors.primary,
                    ),
                    _Pill(
                      label: customer.isBlocked ? 'Blocked' : 'Active',
                      color: customer.isBlocked
                          ? AppColors.error
                          : AppColors.success,
                    ),
                    _Pill(
                      label: customer.city.isNotEmpty
                          ? customer.city
                          : 'No city',
                      color: AppColors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${customer.totalOrders} orders  â€¢  ${formatMoney(customer.totalSpent)}',
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

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

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
        capitalizeWords(label.replaceAll('_', ' ')),
        style: TextStyle(
          color: color,
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
