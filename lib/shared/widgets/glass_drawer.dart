import 'package:flutter/material.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/core/constants/sizes.dart';

// Drawer index constants — MainLayout এর সাথে match করতে হবে
const int kDrawerDashboard = 10;
const int kDrawerCustomers = 11;
const int kDrawerSettings  = 12;
const int kDrawerUsers     = 13;

class GlassDrawer extends StatelessWidget {
  final String storeName;
  final String email;
  final String role;
  final int currentIndex;
  final Function(int) onItemTap;
  final VoidCallback onLogout;

  const GlassDrawer({
    super.key,
    required this.storeName,
    required this.email,
    required this.role,
    required this.currentIndex,
    required this.onItemTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      width: MediaQuery.of(context).size.width * 0.78,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.bgSecondary, AppColors.bgPrimary]
              : [AppColors.bgSecondaryLight, AppColors.bgPrimaryLight],
        ),
        border: Border(
          right: BorderSide(
            color: AppColors.glassBorderFor(brightness),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(brightness),
            const SizedBox(height: 8),
            Divider(
              color: AppColors.glassBorderFor(brightness),
              thickness: 0.5,
              indent: 20,
              endIndent: 20,
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  // ── Section label ──────────────────────────────────────
                  _buildSectionLabel('Management', brightness),
                  const SizedBox(height: 4),

                  _buildMenuItem(
                    index: kDrawerDashboard,
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    context: context,
                    brightness: brightness,
                  ),
                  _buildMenuItem(
                    index: kDrawerCustomers,
                    icon: Icons.people_outline_rounded,
                    activeIcon: Icons.people_rounded,
                    label: 'Customers',
                    context: context,
                    brightness: brightness,
                  ),

                  const SizedBox(height: 12),

                  // ── Section label ──────────────────────────────────────
                  _buildSectionLabel('System', brightness),
                  const SizedBox(height: 4),

                  _buildMenuItem(
                    index: kDrawerSettings,
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    label: 'Settings',
                    context: context,
                    brightness: brightness,
                  ),
                  _buildMenuItem(
                    index: kDrawerUsers,
                    icon: Icons.manage_accounts_outlined,
                    activeIcon: Icons.manage_accounts_rounded,
                    label: 'Users',
                    context: context,
                    brightness: brightness,
                  ),
                ],
              ),
            ),

            Divider(
              color: AppColors.glassBorderFor(brightness),
              thickness: 0.5,
              indent: 20,
              endIndent: 20,
            ),
            _buildLogoutButton(context, brightness),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 2),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: AppColors.textSecondaryFor(brightness),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildHeader(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassSurfaceFor(brightness),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.glassBorderFor(brightness),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.purple],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                storeName.isNotEmpty ? storeName[0].toUpperCase() : 'W',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: TextStyle(
                    color: AppColors.textPrimaryFor(brightness),
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    color: AppColors.textSecondaryFor(brightness),
                    fontSize: AppSizes.fontXs,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required BuildContext context,
    required Brightness brightness,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        onItemTap(index);
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isActive
              ? Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 0.5,
          )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? AppColors.primary
                  : AppColors.textSecondaryFor(brightness),
              size: 20,
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? AppColors.primary
                    : AppColors.textSecondaryFor(brightness),
                fontSize: AppSizes.fontMd,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isActive) ...[
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, Brightness brightness) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onLogout();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.error.withValues(
              alpha: brightness == Brightness.dark ? 0.2 : 0.25,
            ),
            width: 0.5,
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
            SizedBox(width: 14),
            Text(
              'Logout',
              style: TextStyle(
                color: AppColors.error,
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}