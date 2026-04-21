import 'package:flutter/material.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/core/constants/sizes.dart';

// Glass Card — Normal
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ??
            const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.glassSurface,
          borderRadius: borderRadius ??
              BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// Glass Card — Gradient (highlighted)
class GlassGradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;

  const GlassGradientCard({
    super.key,
    required this.child,
    this.padding,
    this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ??
            const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors ??
                [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.purple.withOpacity(0.2),
                ],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}