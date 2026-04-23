import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/core/constants/sizes.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final String? profileImageUrl;
  final VoidCallback? onProfileTap;

  const GlassAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.profileImageUrl,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final leadingWidgets = leading == null ? null : <Widget>[leading!];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: brightness == Brightness.dark
              ? [const Color(0xCC101317), const Color(0xB31A1F26)]
              : [Colors.white.withValues(alpha: 0.96), const Color(0xFFF7F4EE)],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.glassBorderFor(brightness),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: brightness == Brightness.dark ? 0.18 : 0.05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
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
              else
                ...?leadingWidgets,

              if (showBackButton || leading != null) const SizedBox(width: 12),

              // Title
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.purple],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
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
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondaryFor(brightness),
                                fontSize: AppSizes.fontXs,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              ...?actions,
              if (profileImageUrl case final imageUrl?)
                GlassProfileAvatarAction(
                  imageUrl: imageUrl,
                  onTap: onProfileTap ?? () {},
                ),
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

class GlassProfileAvatarAction extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const GlassProfileAvatarAction({
    super.key,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(2.2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.purple,
                AppColors.primaryDark,
              ],
            ),
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(imageUrl),
            ),
          ),
        ),
      ),
    );
  }
}
