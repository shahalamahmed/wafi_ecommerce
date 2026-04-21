import 'package:flutter/material.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';

class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 50,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: 'Dashboard',
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2_rounded,
            label: 'Products',
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.shopping_bag_outlined,
            activeIcon: Icons.shopping_bag_rounded,
            label: 'Orders',
          ),
          _buildNavItem(
            index: 4,
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 0.5,
          )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? AppColors.primary
                  : AppColors.textHint,
              size: 22,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 9,
                fontWeight: isActive
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: isActive
                    ? AppColors.primary
                    : AppColors.textHint,
                letterSpacing: 0.3,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}