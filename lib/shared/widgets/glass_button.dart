import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/core/constants/sizes.dart';

enum GlassButtonVariant {
  primary,
  secondary,
  danger,
}

class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final double height;
  final GlassButtonVariant variant;
  final EdgeInsetsGeometry? padding;

  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.height = AppSizes.buttonHeight,
    this.variant = GlassButtonVariant.primary,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final scheme = _GlassButtonScheme.fromVariant(variant, brightness);

    final button = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: height,
              padding: padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: scheme.gradient,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scheme.borderColor,
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.shadowColor.withOpacity(isDark ? 0.28 : 0.14),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.foregroundColor,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(
                              icon,
                              size: 18,
                              color: scheme.foregroundColor,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              label,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: scheme.foregroundColor,
                                fontSize: AppSizes.fontMd,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );

    if (expand) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

class GlassDualButtonRow extends StatelessWidget {
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final IconData? primaryIcon;
  final IconData? secondaryIcon;
  final bool isPrimaryLoading;
  final bool stackOnMobile;

  const GlassDualButtonRow({
    super.key,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
    this.primaryIcon,
    this.secondaryIcon,
    this.isPrimaryLoading = false,
    this.stackOnMobile = true,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 360;
    final shouldStack = stackOnMobile && isNarrow;

    final secondaryButton = GlassButton(
      label: secondaryLabel,
      onPressed: onSecondaryPressed,
      icon: secondaryIcon,
      variant: GlassButtonVariant.secondary,
    );

    final primaryButton = GlassButton(
      label: primaryLabel,
      onPressed: onPrimaryPressed,
      icon: primaryIcon,
      isLoading: isPrimaryLoading,
    );

    if (shouldStack) {
      return Column(
        children: [
          secondaryButton,
          const SizedBox(height: 12),
          primaryButton,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: secondaryButton),
        const SizedBox(width: 12),
        Expanded(child: primaryButton),
      ],
    );
  }
}

class _GlassButtonScheme {
  final List<Color> gradient;
  final Color borderColor;
  final Color foregroundColor;
  final Color shadowColor;

  const _GlassButtonScheme({
    required this.gradient,
    required this.borderColor,
    required this.foregroundColor,
    required this.shadowColor,
  });

  factory _GlassButtonScheme.fromVariant(
    GlassButtonVariant variant,
    Brightness brightness,
  ) {
    final isDark = brightness == Brightness.dark;

    switch (variant) {
      case GlassButtonVariant.secondary:
        return _GlassButtonScheme(
          gradient: [
            Colors.white.withOpacity(isDark ? 0.10 : 0.72),
            Colors.white.withOpacity(isDark ? 0.04 : 0.46),
          ],
          borderColor: isDark
              ? Colors.white.withOpacity(0.14)
              : Colors.black.withOpacity(0.08),
          foregroundColor: AppColors.textPrimaryFor(brightness),
          shadowColor: Colors.black,
        );
      case GlassButtonVariant.danger:
        return _GlassButtonScheme(
          gradient: [
            AppColors.error.withOpacity(isDark ? 0.26 : 0.18),
            AppColors.error.withOpacity(isDark ? 0.14 : 0.10),
          ],
          borderColor: AppColors.error.withOpacity(isDark ? 0.30 : 0.22),
          foregroundColor: isDark ? Colors.white : AppColors.error,
          shadowColor: AppColors.error,
        );
      case GlassButtonVariant.primary:
        return _GlassButtonScheme(
          gradient: [
            AppColors.primary.withOpacity(isDark ? 0.34 : 0.24),
            AppColors.purple.withOpacity(isDark ? 0.18 : 0.12),
          ],
          borderColor: AppColors.primary.withOpacity(isDark ? 0.32 : 0.22),
          foregroundColor: isDark ? Colors.white : AppColors.textPrimaryLight,
          shadowColor: AppColors.primary,
        );
    }
  }
}
