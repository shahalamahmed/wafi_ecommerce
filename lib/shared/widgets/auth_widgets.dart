import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/core/constants/sizes.dart';

// Background gradient
class AuthBackground extends StatelessWidget {
  final bool isDark;
  final Widget child;
  const AuthBackground({super.key, required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.bgPrimary, AppColors.bgSecondary, AppColors.bgTertiary]
              : [AppColors.bgPrimaryLight, AppColors.bgSecondaryLight, AppColors.bgTertiaryLight],
        ),
      ),
      child: child,
    );
  }
}

// Hero header (logo + title)
class AuthHeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Brightness brightness;

  const AuthHeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.purple],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(isDark ? 0.4 : 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryFor(brightness),
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: AppSizes.fontMd,
            color: AppColors.textSecondaryFor(brightness),
          ),
        ),
      ],
    );
  }
}

// Glass card wrapper
class AuthGlassCard extends StatelessWidget {
  final bool isDark;
  final Brightness brightness;
  final Widget child;

  const AuthGlassCard({
    super.key,
    required this.isDark,
    required this.brightness,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassSurfaceFor(brightness),
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            border: Border.all(
              color: AppColors.glassBorderFor(brightness),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSizes.lg),
          child: child,
        ),
      ),
    );
  }
}

// Text field
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final Brightness brightness;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.brightness,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: TextStyle(
        color: AppColors.textPrimaryFor(brightness),
        fontSize: AppSizes.fontMd,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: AppSizes.iconSm),
        suffixIcon: onToggleObscure != null
            ? IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: AppSizes.iconSm,
          ),
          onPressed: onToggleObscure,
        )
            : null,
      ),
    );
  }
}

// Divider
class AuthDivider extends StatelessWidget {
  final String label;
  const AuthDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.glassBorderFor(brightness),
            thickness: 0.5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.fontXs,
              color: AppColors.textHintFor(brightness),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.glassBorderFor(brightness),
            thickness: 0.5,
          ),
        ),
      ],
    );
  }
}

// Google button
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          side: BorderSide(
            color: AppColors.glassBorderFor(brightness),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.google, size: 18, color: const Color(0xFF4285F4)),
            const SizedBox(width: 10),
            Text(
              'Continue with Google',
              style: TextStyle(
                color: AppColors.textPrimaryFor(brightness),
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

// Error widget
class AuthErrorWidget extends StatelessWidget {
  final String message;
  const AuthErrorWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.error.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: AppSizes.iconSm),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: AppSizes.fontSm),
            ),
          ),
        ],
      ),
    );
  }
}