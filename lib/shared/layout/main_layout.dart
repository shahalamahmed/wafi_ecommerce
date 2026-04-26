import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/config/theme/theme_provider.dart';
import 'package:wafi_ecommerce/features/auth/auth_provider.dart';
import 'package:wafi_ecommerce/features/customers/customer_screen.dart';
import 'package:wafi_ecommerce/features/dashboard/dashboard_screen.dart';
import 'package:wafi_ecommerce/features/orders/order_screen.dart';
import 'package:wafi_ecommerce/features/products/product_screen.dart';
import 'package:wafi_ecommerce/features/profile/profile_screen.dart';
import 'package:wafi_ecommerce/features/settings/settings.dart';
import 'package:wafi_ecommerce/features/users/user_screen.dart';
import 'package:wafi_ecommerce/features/home/customer_home_screen.dart';
import 'package:wafi_ecommerce/features/cart/cart_provider.dart';
import 'package:wafi_ecommerce/features/cart/cart_screen.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_appbar.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_bottom_nav.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_drawer.dart';

enum _BottomTab { home, products, orders, profile }

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  _BottomTab _currentTab = _BottomTab.home;
  int _activeDrawerIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _PageEntry _pageForTab(_BottomTab tab) {
    switch (tab) {
      case _BottomTab.home:
        return const _PageEntry(
          meta: _PageMeta(title: 'Wafi Store', subtitle: 'Discover collections'),
          page: CustomerHomeScreen(),
          icon: Icons.home_rounded,
        );
      case _BottomTab.products:
        return const _PageEntry(
          meta: _PageMeta(title: 'Products', subtitle: 'Catalog and stock'),
          page: ProductsScreen(),
          icon: Icons.inventory_2_rounded,
        );
      case _BottomTab.orders:
        return const _PageEntry(
          meta: _PageMeta(title: 'Orders', subtitle: 'Track and fulfil'),
          page: OrdersScreen(),
          icon: Icons.receipt_long_rounded,
        );
      case _BottomTab.profile:
        return const _PageEntry(
          meta: _PageMeta(title: 'Profile', subtitle: 'Your account'),
          page: ProfileScreen(),
          icon: Icons.person_rounded,
        );
    }
  }

  // ── Drawer index → page mapping ─────────────────────────────────────────────
  _PageEntry _resolveEntry() {
    switch (_activeDrawerIndex) {
      case kDrawerDashboard:
        return const _PageEntry(
          meta: _PageMeta(title: 'Dashboard', subtitle: 'Store pulse'),
          page: DashboardScreen(),
          icon: Icons.dashboard_rounded,
        );
      case kDrawerCustomers:
        return const _PageEntry(
          meta: _PageMeta(title: 'Customers', subtitle: 'Buyer records'),
          page: CustomersScreen(),
          icon: Icons.people_rounded,
        );
      case kDrawerSettings:
        return const _PageEntry(
          meta: _PageMeta(title: 'Settings', subtitle: 'Workspace tools'),
          page: SettingsScreen(),
          icon: Icons.settings_rounded,
        );
      case kDrawerUsers:
        return const _PageEntry(
          meta: _PageMeta(title: 'Users', subtitle: 'Manage team members'),
          page: UsersScreen(),
          icon: Icons.manage_accounts_rounded,
        );
      default:
        return _pageForTab(_currentTab);
    }
  }

  // ── Tap handlers ────────────────────────────────────────────────────────────
  void _onBottomTabTap(int index) {
    final tab = _BottomTab.values[index];
    if (tab == _currentTab && _activeDrawerIndex == index) return;
    setState(() {
      _currentTab = tab;
      _activeDrawerIndex = index;
    });
  }

  void _onDrawerItemTap(int drawerIndex) {
    setState(() => _activeDrawerIndex = drawerIndex);
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(typedRoleProvider);
    final auth = ref.watch(authControllerProvider);
    final entry = _resolveEntry();

    final bottomIndex = _activeDrawerIndex < 4
        ? _activeDrawerIndex
        : _currentTab.index;

    final showCart = (_activeDrawerIndex < 4) &&
        (_currentTab == _BottomTab.home || _currentTab == _BottomTab.products);

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,

      // ── AppBar ──────────────────────────────────────────────────────────────
      appBar: GlassAppBar(
        title: entry.meta.title,
        subtitle: entry.meta.subtitle,
        leading: GlassAppBarAction(
          icon: Icons.menu_rounded,
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          if (showCart)
            Stack(
              alignment: Alignment.topRight,
              children: [
                GlassAppBarAction(
                  icon: Icons.shopping_cart_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final count = ref.watch(cartProvider).itemCount;
                    if (count == 0) return const SizedBox.shrink();
                    return Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          GlassAppBarAction(
            icon: ref.watch(themeProvider) == ThemeMode.dark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
        ],
      ),


      drawer: GlassDrawer(
        storeName: auth.tenantId ?? auth.email ?? 'Wafi Store',
        email: auth.email ?? '',
        role: role.name,
        currentIndex: _activeDrawerIndex,
        onItemTap: _onDrawerItemTap,
        onLogout: () async {
          await ref.read(authControllerProvider.notifier).logout();
        },
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          const _AppBackdrop(),
          SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: KeyedSubtree(
                key: ValueKey(_activeDrawerIndex),
                child: entry.page,
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: GlassBottomNav(
        currentIndex: bottomIndex,
        onTap: _onBottomTabTap,
      ),
    );
  }
}


class _PageMeta {
  final String title;
  final String subtitle;
  const _PageMeta({required this.title, required this.subtitle});
}

class _PageEntry {
  final _PageMeta meta;
  final Widget page;
  final IconData icon;
  const _PageEntry({
    required this.meta,
    required this.page,
    required this.icon,
  });
}

class _AppBackdrop extends StatelessWidget {
  const _AppBackdrop();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF08080A) : const Color(0xFFFCFCFD),
    );
  }
}