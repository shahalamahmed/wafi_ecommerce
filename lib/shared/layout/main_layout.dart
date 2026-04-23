import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/core/theme/theme_provider.dart';
import 'package:wafi_ecommerce/core/utils/firestore_seeder.dart';
import 'package:wafi_ecommerce/features/auth/auth_provider.dart';
import 'package:wafi_ecommerce/features/customers/customers_screen.dart';
import 'package:wafi_ecommerce/features/dashboard/dashboard_screen.dart';
import 'package:wafi_ecommerce/features/orders/orders_screen.dart';
import 'package:wafi_ecommerce/features/products/products_screen.dart';
import 'package:wafi_ecommerce/features/settings/settings_screen.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_appbar.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_bottom_nav.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;

  late final List<Widget> _pages = const [
    DashboardScreen(),
    ProductsScreen(),
    OrdersScreen(),
    CustomersScreen(),
    SettingsScreen(),
  ];

  late final List<_PageMeta> _pageMeta = const [
    _PageMeta(title: 'Dashboard', subtitle: 'Store pulse and quick actions'),
    _PageMeta(title: 'Products', subtitle: 'Catalog, stock and pricing'),
    _PageMeta(title: 'Orders', subtitle: 'Create, track and fulfil orders'),
    _PageMeta(title: 'Customers', subtitle: 'Loyalty and buyer records'),
    _PageMeta(title: 'Settings', subtitle: 'Theme and workspace tools'),
  ];

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final currentPage = _pageMeta[_currentIndex];

    return Scaffold(
      extendBody: true,
      appBar: GlassAppBar(
        title: currentPage.title,
        subtitle: currentPage.subtitle,
        actions: [
          GlassAppBarAction(
            icon: themeMode == ThemeMode.dark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          if (_currentIndex == 0)
            GlassAppBarAction(
              icon: Icons.auto_fix_high_rounded,
              onTap: () async {
                await FirestoreSeeder.seedAll();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Firestore seeded.')),
                );
              },
            ),
          GlassAppBarAction(
            icon: _currentIndex == 4
                ? Icons.logout_rounded
                : Icons.settings_rounded,
            onTap: _currentIndex == 4
                ? () async {
                    await ref.read(authControllerProvider.notifier).logout();
                  }
                : () {
                    setState(() => _currentIndex = 4);
                  },
            color: _currentIndex == 4 ? AppColors.error : null,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _AppBackdrop(),
          SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: _pages[_currentIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

class _AppBackdrop extends StatelessWidget {
  const _AppBackdrop();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: brightness == Brightness.dark
                  ? [
                      AppColors.bgSecondary,
                      AppColors.bgPrimary,
                      AppColors.bgTertiary,
                    ]
                  : [
                      AppColors.bgSecondaryLight,
                      AppColors.bgPrimaryLight,
                      AppColors.bgTertiaryLight,
                    ],
            ),
          ),
        ),
        Positioned(
          top: -110,
          right: -40,
          child: _GlowOrb(
            size: 250,
            color: AppColors.primary.withValues(
              alpha: brightness == Brightness.dark ? 0.22 : 0.12,
            ),
          ),
        ),
        Positioned(
          top: 220,
          left: -80,
          child: _GlowOrb(
            size: 220,
            color: AppColors.purple.withValues(
              alpha: brightness == Brightness.dark ? 0.16 : 0.08,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}

class _PageMeta {
  final String title;
  final String subtitle;

  const _PageMeta({required this.title, required this.subtitle});
}
