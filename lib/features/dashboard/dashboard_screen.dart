import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/core/api/firestore_service.dart';
import 'package:wafi_ecommerce/core/constants/user_role.dart';
import 'package:wafi_ecommerce/core/utils/helpers.dart';
import 'package:wafi_ecommerce/core/utils/seeder.dart';
import 'package:wafi_ecommerce/core/widgets/role_guard.dart';
import 'package:wafi_ecommerce/features/auth/auth_provider.dart';
import 'package:wafi_ecommerce/features/customers/customer_editor_sheet.dart';
import 'package:wafi_ecommerce/features/dashboard/users_management_screen.dart';
import 'package:wafi_ecommerce/features/orders/order_editor_sheet.dart';
import 'package:wafi_ecommerce/features/products/product_editor_sheet.dart';
import 'package:wafi_ecommerce/shared/widgets/app_section_header.dart';
import 'package:wafi_ecommerce/shared/widgets/empty_state.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_button.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_card.dart';
import 'package:wafi_ecommerce/features/customers/customer_model.dart';
import 'package:wafi_ecommerce/features/customers/customer_provider.dart';
import 'package:wafi_ecommerce/features/orders/order_model.dart';
import 'package:wafi_ecommerce/features/orders/order_provider.dart';
import 'package:wafi_ecommerce/features/products/product_model.dart';
import 'package:wafi_ecommerce/features/products/product_provider.dart';
import 'package:wafi_ecommerce/features/tenant/tenant_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _seedDemo(BuildContext context) async {
    await FirestoreSeeder.seedAll();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Firestore seeded.')));
  }

  Future<void> _openProductEditor(BuildContext context, WidgetRef ref) async {
    final tenantId = ref.read(tenantIdProvider) ?? '';
    if (tenantId.isEmpty) return;
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductEditorSheet(tenantId: tenantId),
    );
  }

  Future<void> _openOrderEditor(BuildContext context, WidgetRef ref) async {
    final tenantId = ref.read(tenantIdProvider) ?? '';
    if (tenantId.isEmpty) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderEditorSheet(tenantId: tenantId),
    );
  }

  Future<void> _openCustomerEditor(BuildContext context, WidgetRef ref) async {
    final tenantId = ref.read(tenantIdProvider) ?? '';
    if (tenantId.isEmpty) return;
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerEditorSheet(tenantId: tenantId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantId = ref.watch(tenantIdProvider) ?? '';
    final auth = ref.watch(authControllerProvider);
    final tenantAsync = ref.watch(tenantStreamProvider(tenantId));
    final productState = ref.watch(productListProvider(tenantId));
    final orderState = ref.watch(orderListProvider(tenantId));
    final customerState = ref.watch(customerListProvider(tenantId));

    final tenant = tenantAsync.valueOrNull;
    final products = productState.products;
    final orders = orderState.orders;
    final customers = customerState.customers;

    final lowStockProducts = products
        .where((product) => product.isLowStock)
        .toList();
    final recentOrders = orders.take(4).toList();
    final revenue = orders.fold<double>(
      0,
      (sum, order) => sum + (order.paymentStatus == 'paid' ? order.total : 0),
    );
    final activeOrders = orders
        .where(
          (order) => order.status == 'pending' || order.status == 'processing',
        )
        .length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroPanel(
            storeName: tenant?.name ?? auth.tenantId ?? 'Wafi Store',
            owner: tenant?.ownerName ?? auth.email ?? 'Owner',
            revenue: revenue,
            totalOrders: orders.length,
            totalProducts: products.length,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              GlassButton(
                label: 'Add Product',
                onPressed: () => _openProductEditor(context, ref),
                icon: Icons.add_box_rounded,
                expand: false,
              ),
              GlassButton(
                label: 'Create Order',
                onPressed: () => _openOrderEditor(context, ref),
                icon: Icons.shopping_cart_checkout_rounded,
                expand: false,
              ),
              GlassButton(
                label: 'Add Customer',
                onPressed: () => _openCustomerEditor(context, ref),
                icon: Icons.person_add_rounded,
                expand: false,
                variant: GlassButtonVariant.secondary,
              ),
              // dashboard_screen.dart এ
              RoleGuard(
                canAccess: (role) => role == UserRole.admin,
                child: ListTile(
                  leading: const Icon(Icons.manage_accounts),
                  title:   const Text('Manage Users'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UsersManagementScreen(),
                    ),
                  ),
                ),
              ),
              GlassButton(
                label: 'Seed Demo',
                onPressed: () => _seedDemo(context),
                icon: Icons.auto_fix_high_rounded,
                expand: false,
                variant: GlassButtonVariant.secondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: [
              _MetricTile(
                label: 'Products',
                value: products.length.toString(),
                accent: AppColors.primary,
              ),
              _MetricTile(
                label: 'Orders',
                value: orders.length.toString(),
                accent: AppColors.purple,
              ),
              _MetricTile(
                label: 'Customers',
                value: customers.length.toString(),
                accent: AppColors.success,
              ),
              _MetricTile(
                label: 'Active',
                value: activeOrders.toString(),
                accent: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppSectionHeader(
            title: 'Low stock',
            subtitle: 'Products that need attention before stock hits zero.',
          ),
          const SizedBox(height: 12),
          if (productState.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (lowStockProducts.isEmpty)
            const EmptyStateCard(
              icon: Icons.inventory_2_outlined,
              title: 'Stock looks healthy',
              message: 'No product is currently below the low stock threshold.',
            )
          else
            Column(
              children: lowStockProducts
                  .map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ProductRow(product: product),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 16),
          AppSectionHeader(
            title: 'Recent orders',
            subtitle: 'Latest orders and current fulfilment state.',
          ),
          const SizedBox(height: 12),
          if (orderState.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (recentOrders.isEmpty)
            const EmptyStateCard(
              icon: Icons.receipt_long_rounded,
              title: 'No recent orders',
              message: 'Create an order to see recent activity here.',
            )
          else
            Column(
              children: recentOrders
                  .map(
                    (order) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _OrderRow(order: order),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final String storeName;
  final String owner;
  final double revenue;
  final int totalOrders;
  final int totalProducts;

  const _HeroPanel({
    required this.storeName,
    required this.owner,
    required this.revenue,
    required this.totalOrders,
    required this.totalProducts,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GlassGradientCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: brightness == Brightness.dark ? 0.08 : 0.24,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Live store overview',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            storeName,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Owner: $owner',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MiniStat(label: 'Revenue', value: formatMoney(revenue)),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'Orders',
                  value: totalOrders.toString(),
                ),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'Products',
                  value: totalProducts.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
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
            child: Icon(Icons.analytics_rounded, color: accent, size: 18),
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

class _ProductRow extends StatelessWidget {
  final ProductModel product;

  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.stock} in stock â€¢ ${product.categoryName.isNotEmpty ? product.categoryName : 'No category'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatMoney(product.price, symbol: product.currency),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final OrderModel order;

  const _OrderRow({required this.order});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderNumber,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.customerName.isNotEmpty
                      ? order.customerName
                      : 'Walk-in customer',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatMoney(order.total),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
