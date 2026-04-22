import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/core/constants/sizes.dart';
import 'package:wafi_ecommerce/features/auth/auth_provider.dart';
import 'package:wafi_ecommerce/features/settings/settings.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_appbar.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_bottom_nav.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_card.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_drawer.dart';
import 'package:wafi_ecommerce/shared/widgets/snackbar_message.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;

  static const List<_NavItemData> _items = [
    _NavItemData(
      title: 'Dashboard',
      subtitle: 'Store pulse and quick actions',
      chip: 'LIVE',
      icon: Icons.space_dashboard_rounded,
    ),
    _NavItemData(
      title: 'Products',
      subtitle: 'Catalog, stock and pricing insights',
      chip: '124 ITEMS',
      icon: Icons.inventory_2_rounded,
    ),
    _NavItemData(
      title: 'Orders',
      subtitle: 'Incoming orders and fulfillment flow',
      chip: '18 PENDING',
      icon: Icons.shopping_bag_rounded,
    ),
    _NavItemData(
      title: 'Customers',
      subtitle: 'Audience, retention and segments',
      chip: '2.4K USERS',
      icon: Icons.people_rounded,
    ),
    _NavItemData(
      title: 'Settings',
      subtitle: 'Store preferences and system controls',
      chip: 'SECURE',
      icon: Icons.settings_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final currentItem = _items[_currentIndex];
    final email = authState.email ?? 'admin@wafi.shop';
    final storeName = authState.tenantId ?? 'Wafi Store';
    final role = authState.role ?? 'admin';

    return Scaffold(
      extendBody: true,
      drawer: GlassDrawer(
        storeName: storeName,
        email: email,
        role: role,
        currentIndex: _currentIndex,
        onItemTap: _handleNavTap,
        onLogout: () async {
          await ref.read(authControllerProvider.notifier).logout();
          if (!mounted) return;
          SnackbarMessage.show(
            context: context,
            message: 'Signed out successfully.',
          );
        },
      ),
      appBar: GlassAppBar(
        title: currentItem.title,
        subtitle: currentItem.subtitle,
        leading: Builder(
          builder: (context) => _GlassCircleButton(
            icon: Icons.grid_view_rounded,
            onTap: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          GlassAppBarAction(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
          GlassAppBarAction(
            icon: Icons.search_rounded,
            onTap: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          const _LayoutBackdrop(),
          SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _currentIndex == 4
                  ? const SettingsScreen(key: ValueKey('settings'))
                  : _MainLayoutBody(
                      key: ValueKey(_currentIndex),
                      item: currentItem,
                      currentIndex: _currentIndex,
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _currentIndex,
        onTap: _handleNavTap,
      ),
    );
  }

  void _handleNavTap(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }
}

class _MainLayoutBody extends StatelessWidget {
  final _NavItemData item;
  final int currentIndex;

  const _MainLayoutBody({
    super.key,
    required this.item,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 140),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _HeroPanel(item: item),
              const SizedBox(height: 18),
              _MetricRow(currentIndex: currentIndex),
              const SizedBox(height: 18),
              _SectionTitle(
                title: 'Overview',
                actionLabel: 'This Week',
              ),
              const SizedBox(height: 12),
              _OverviewGrid(currentIndex: currentIndex),
              const SizedBox(height: 18),
              _SectionTitle(
                title: 'Recent Activity',
                actionLabel: 'Refresh',
              ),
              const SizedBox(height: 12),
              _ActivityList(currentIndex: currentIndex),
            ]),
          ),
        ),
      ],
    );
  }
}

class _LayoutBackdrop extends StatelessWidget {
  const _LayoutBackdrop();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
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
          top: -120,
          right: -40,
          child: _GlowOrb(
            size: 260,
            color: AppColors.primary.withOpacity(isDark ? 0.26 : 0.18),
          ),
        ),
        Positioned(
          top: 220,
          left: -70,
          child: _GlowOrb(
            size: 220,
            color: AppColors.purple.withOpacity(isDark ? 0.22 : 0.14),
          ),
        ),
        Positioned(
          bottom: 90,
          right: -50,
          child: _GlowOrb(
            size: 190,
            color: Colors.cyanAccent.withOpacity(isDark ? 0.14 : 0.08),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final _NavItemData item;

  const _HeroPanel({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withOpacity(0.16),
                  Colors.white.withOpacity(0.05),
                ]
              : [
                  Colors.white.withOpacity(0.78),
                  AppColors.primary.withOpacity(0.06),
                ],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.18)
              : Colors.black.withOpacity(0.06),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.24 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PanelBadge(label: item.chip),
                        const SizedBox(height: 14),
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Glass surface er mood maintain kore cleaner hierarchy, faster scan ar premium dashboard feel ene dichi.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                                fontSize: AppSizes.fontMd,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: AppColors.primary.withOpacity(0.16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.26),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      item.icon,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark
                      ? Colors.black.withOpacity(0.14)
                      : Colors.white.withOpacity(0.48),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.black.withOpacity(0.06),
                    width: 0.6,
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        label: 'Revenue',
                        value: '\$12.4K',
                      ),
                    ),
                    Expanded(
                      child: _MiniStat(
                        label: 'Growth',
                        value: '+18.6%',
                      ),
                    ),
                    Expanded(
                      child: _MiniStat(
                        label: 'Conversion',
                        value: '4.8%',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final int currentIndex;

  const _MetricRow({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _MetricData(
        label: 'Today',
        value: '${24 + currentIndex * 3}',
        accent: AppColors.primary,
      ),
      _MetricData(
        label: 'Pending',
        value: '${7 + currentIndex}',
        accent: AppColors.warning,
      ),
      _MetricData(
        label: 'Completed',
        value: '${32 + currentIndex * 4}',
        accent: AppColors.success,
      ),
    ];

    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: stats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final stat = stats[index];
          return SizedBox(
            width: 154,
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: stat.accent,
                      boxShadow: [
                        BoxShadow(
                          color: stat.accent.withOpacity(0.35),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    stat.value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String actionLabel;

  const _SectionTitle({
    required this.title,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.glassSurfaceFor(brightness),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.glassBorderFor(brightness),
              width: 0.5,
            ),
          ),
          child: Text(
            actionLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryFor(brightness),
                ),
          ),
        ),
      ],
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  final int currentIndex;

  const _OverviewGrid({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        title: 'Traffic',
        value: '+${12 + currentIndex}%',
        icon: Icons.north_east_rounded,
        tone: AppColors.primary
      ),
      (
        title: 'Returns',
        value: '${1.2 + currentIndex / 10}%',
        icon: Icons.keyboard_return_rounded,
        tone: AppColors.warning
      ),
      (
        title: 'Reviews',
        value: '4.${8 - (currentIndex % 2)}/5',
        icon: Icons.star_rounded,
        tone: AppColors.success
      ),
      (
        title: 'Alerts',
        value: '${2 + currentIndex}',
        icon: Icons.bolt_rounded,
        tone: AppColors.purple
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.14,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: card.tone.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  card.icon,
                  color: card.tone,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                card.value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                card.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityList extends StatelessWidget {
  final int currentIndex;

  const _ActivityList({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final items = [
      _ActivityData(
        title: 'New order confirmed',
        subtitle: 'Order #WAF-${1024 + currentIndex} just moved to packing.',
        color: AppColors.primary,
      ),
      _ActivityData(
        title: 'Low stock alert',
        subtitle: 'Premium hoodie variant is below reorder threshold.',
        color: AppColors.warning,
      ),
      _ActivityData(
        title: 'Customer review added',
        subtitle: 'A returning buyer left a 5-star review this afternoon.',
        color: AppColors.success,
      ),
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.blur_on_rounded,
                        color: item.color,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.45,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PanelBadge extends StatelessWidget {
  final String label;

  const _PanelBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.primary.withOpacity(0.16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: brightness == Brightness.dark
              ? AppColors.primary
              : AppColors.primaryDark,
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassCircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.glassSurfaceFor(brightness),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.glassBorderFor(brightness),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.textPrimaryFor(brightness),
          size: 20,
        ),
      ),
    );
  }
}

class _NavItemData {
  final String title;
  final String subtitle;
  final String chip;
  final IconData icon;

  const _NavItemData({
    required this.title,
    required this.subtitle,
    required this.chip,
    required this.icon,
  });
}

class _MetricData {
  final String label;
  final String value;
  final Color accent;

  const _MetricData({
    required this.label,
    required this.value,
    required this.accent,
  });
}

class _ActivityData {
  final String title;
  final String subtitle;
  final Color color;

  const _ActivityData({
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
