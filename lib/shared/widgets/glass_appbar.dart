import 'package:flutter/material.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/core/constants/sizes.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  const GlassAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSurfaceFor(brightness),
        border: Border(
          bottom: BorderSide(
            color: AppColors.glassBorderFor(brightness),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          child: Row(
            children: [
              // Leading
              if (showBackButton)
                _buildIconButton(
                  context: context,
                  icon: Icons.arrow_back_ios_rounded,
                  onTap: () => Navigator.pop(context),
                )
              else if (leading != null)
                leading!,

              const SizedBox(width: 12),

              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textPrimaryFor(brightness),
                        fontSize: AppSizes.fontXl,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: AppColors.textSecondaryFor(brightness),
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.glassSurfaceFor(brightness),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.glassBorderFor(brightness),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.textPrimaryFor(brightness),
          size: 18,
        ),
      ),
    );
  }
}

// AppBar Action Button
class GlassAppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const GlassAppBarAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: AppColors.glassSurfaceFor(brightness),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.glassBorderFor(brightness),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          color: color ?? AppColors.textPrimaryFor(brightness),
          size: 18,
        ),
      ),
    );
  }
}
