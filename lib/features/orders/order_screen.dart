import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/core/constants/sizes.dart';

import 'package:wafi_ecommerce/core/utils/helpers.dart';
import 'package:wafi_ecommerce/features/auth/auth_provider.dart';
import 'package:wafi_ecommerce/features/orders/order_editor_sheet.dart';
import 'order_provider.dart';
import 'order_model.dart';
import 'order_service.dart';
import 'package:wafi_ecommerce/shared/widgets/app_section_header.dart';
import 'package:wafi_ecommerce/shared/widgets/empty_state.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_card.dart';
import 'package:wafi_ecommerce/shared/widgets/snackbar_message.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final tenantId = ref.read(tenantIdProvider) ?? '';
      ref.read(orderListProvider(tenantId).notifier).loadMore();
    }
  }

  Future<void> _openEditor() async {
    final tenantId = ref.read(tenantIdProvider) ?? '';
    if (tenantId.isEmpty) return;

    final result = await showModalBottomSheet<CreatedOrderResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderEditorSheet(tenantId: tenantId),
    );

    if (!mounted || result == null) return;
    SnackbarMessage.show(
      context: context,
      message: 'Order ${result.orderNumber} created successfully.',
    );
  }

  Future<void> _showDetails(OrderModel order) async {
    final tenantId = ref.read(tenantIdProvider) ?? '';
    if (tenantId.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OrderDetailSheet(tenantId: tenantId, order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenantId = ref.watch(tenantIdProvider) ?? '';
    final orderState = ref.watch(orderListProvider(tenantId));
    final orders = orderState.orders;
    final filtered = orders.where((order) {
      final q = _search.trim().toLowerCase();
      if (q.isEmpty) return true;
      return order.orderNumber.toLowerCase().contains(q) ||
          order.customerName.toLowerCase().contains(q) ||
          order.customerPhone.toLowerCase().contains(q) ||
          order.status.toLowerCase().contains(q);
    }).toList();

    final totalRevenue = orders.fold<double>(
      0,
      (sum, order) => sum + (order.paymentStatus == 'paid' ? order.total : 0),
    );
    final pending = orders.where((order) => order.status == 'pending').length;
    final delivered = orders
        .where((order) => order.status == 'delivered')
        .length;

    return RefreshIndicator(
      onRefresh: () => ref.read(orderListProvider(tenantId).notifier).refresh(),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'Orders',
            subtitle: 'Create orders, track payment and move status forward.',
            actionLabel: 'Create Order',
            onActionTap: () => _openEditor(),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _search = value),
              decoration: const InputDecoration(
                labelText: 'Search orders',
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
                label: 'Orders',
                value: orders.length.toString(),
                accent: AppColors.primary,
              ),
              _MetricTile(
                label: 'Pending',
                value: pending.toString(),
                accent: AppColors.warning,
              ),
              _MetricTile(
                label: 'Delivered',
                value: delivered.toString(),
                accent: AppColors.success,
              ),
              _MetricTile(
                label: 'Revenue',
                value: formatMoney(totalRevenue),
                accent: AppColors.purple,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppSectionHeader(
            title: 'Latest orders',
            subtitle: filtered.isEmpty
                ? 'No order matches the current search.'
                : 'Showing ${filtered.length} orders.',
          ),
          const SizedBox(height: 12),
          if (orderState.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (orderState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(orderState.error!.icon, size: 48, color: orderState.error!.color),
                    const SizedBox(height: 16),
                    Text(orderState.error!.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(orderState.error!.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.read(orderListProvider(tenantId).notifier).fetchOrders(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (filtered.isEmpty)
            EmptyStateCard(
              icon: Icons.shopping_bag_outlined,
              title: 'No orders yet',
              message:
                  'Create your first order and stock will be reduced inside a transaction.',
              actionLabel: 'Create Order',
              onAction: () => _openEditor(),
            )
          else ...[
            Column(
              children: filtered
                  .map(
                    (order) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OrderCard(
                        order: order,
                        onTap: () => _showDetails(order),
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (orderState.isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ],
      ),
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
            child: Icon(Icons.receipt_long_rounded, color: accent, size: 18),
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

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.customerName.isNotEmpty
                          ? order.customerName
                          : 'Walk-in customer',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryFor(brightness),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'detail') {
                    onTap();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'detail', child: Text('View details')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(label: order.status, color: _statusColor(order.status)),
              _Pill(
                label: order.paymentStatus,
                color: _paymentColor(order.paymentStatus),
              ),
              _Pill(
                label: '${order.totalItems} items',
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  formatMoney(order.total),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                formatShortDate(order.createdAt),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryFor(brightness),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'processing':
      case 'confirmed':
        return AppColors.primary;
      case 'shipped':
        return AppColors.purple;
      default:
        return AppColors.warning;
    }
  }

  static Color _paymentColor(String status) {
    switch (status) {
      case 'paid':
        return AppColors.success;
      case 'partial':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
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

class _OrderDetailSheet extends ConsumerWidget {
  final String tenantId;
  final OrderModel order;

  const _OrderDetailSheet({required this.tenantId, required this.order});

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    String status,
  ) async {
    try {
      await ref.read(orderListProvider(tenantId).notifier).updateOrderStatus(
            orderId: order.id,
            status: status,
            changedByUid: ref.read(authControllerProvider).uid ?? '',
            changedByName:
                ref.read(authControllerProvider).email?.split('@').first ?? '',
          );
      if (!context.mounted) return;
      Navigator.of(context).pop();
      SnackbarMessage.show(context: context, message: 'Status updated to $status');
    } catch (e) {
      if (!context.mounted) return;
      SnackbarMessage.show(context: context, message: e.toString(), isError: true);
    }
  }

  Future<void> _changePayment(
    BuildContext context,
    WidgetRef ref,
    String paymentStatus,
  ) async {
    try {
      final result = await ref.read(orderServiceProvider).updatePaymentStatus(
            tenantId: tenantId,
            orderId: order.id,
            paymentStatus: paymentStatus,
            amountPaid: paymentStatus == 'paid' ? order.total : order.amountPaid,
          );
      
      if (!result.isSuccess) throw Exception(result.error?.message);

      if (!context.mounted) return;
      Navigator.of(context).pop();
      
      // Refresh the list to show updated data
      ref.read(orderListProvider(tenantId).notifier).refresh();
      
      SnackbarMessage.show(context: context, message: 'Payment status updated to $paymentStatus');
    } catch (e) {
      if (!context.mounted) return;
      SnackbarMessage.show(context: context, message: e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.orderNumber,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                Text(
                  order.customerName.isNotEmpty
                      ? order.customerName
                      : 'Walk-in customer',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryFor(brightness),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(
                      label: order.status,
                      color: _OrderCard._statusColor(order.status),
                    ),
                    _Pill(
                      label: order.paymentStatus,
                      color: _OrderCard._paymentColor(order.paymentStatus),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const AppSectionHeader(title: 'Items', subtitle: ''),
                const SizedBox(height: 8),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.inventory_2_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.quantity} x ${formatMoney(item.price)}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondaryFor(
                                          brightness,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatMoney(item.subtotal),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const AppSectionHeader(title: 'Totals', subtitle: ''),
                const SizedBox(height: 8),
                _SummaryRow(
                  label: 'Subtotal',
                  value: formatMoney(order.subtotal),
                ),
                _SummaryRow(
                  label: 'Discount',
                  value: formatMoney(order.discount),
                ),
                _SummaryRow(
                  label: 'Coupon',
                  value: formatMoney(order.couponDiscount),
                ),
                _SummaryRow(
                  label: 'Delivery',
                  value: formatMoney(order.deliveryCharge),
                ),
                _SummaryRow(label: 'Tax', value: formatMoney(order.tax)),
                _SummaryRow(
                  label: 'Grand total',
                  value: formatMoney(order.total),
                  strong: true,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonal(
                      onPressed: order.status == 'pending'
                          ? null
                          : () => _changeStatus(context, ref, 'pending'),
                      child: const Text('Pending'),
                    ),
                    FilledButton.tonal(
                      onPressed: () => _changeStatus(context, ref, 'confirmed'),
                      child: const Text('Confirm'),
                    ),
                    FilledButton.tonal(
                      onPressed: () =>
                          _changeStatus(context, ref, 'processing'),
                      child: const Text('Process'),
                    ),
                    FilledButton.tonal(
                      onPressed: () => _changeStatus(context, ref, 'shipped'),
                      child: const Text('Ship'),
                    ),
                    FilledButton.tonal(
                      onPressed: () => _changeStatus(context, ref, 'delivered'),
                      child: const Text('Deliver'),
                    ),
                    FilledButton.tonal(
                      onPressed: () => _changeStatus(context, ref, 'cancelled'),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      onPressed: () => _changePayment(context, ref, 'paid'),
                      child: const Text('Mark Paid'),
                    ),
                    FilledButton.tonal(
                      onPressed: () => _changePayment(context, ref, 'partial'),
                      child: const Text('Partial'),
                    ),
                    FilledButton.tonal(
                      onPressed: () => _changePayment(context, ref, 'unpaid'),
                      child: const Text('Unpaid'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
