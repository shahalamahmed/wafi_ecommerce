import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/config/theme/theme_provider.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/features/auth/auth_provider.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_button.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_card.dart';
import 'package:wafi_ecommerce/shared/widgets/snackbar_message.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final authState = ref.watch(authControllerProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LiquidSettingsHero(
            storeName: authState.tenantId ?? 'Wafi Store',
            email: authState.email ?? 'admin@wafi.shop',
          ),
          const SizedBox(height: 18),
          const _SectionHeader(
            title: 'Theme Mode',
            subtitle: 'Dark, light, ba system preference follow korbe.',
          ),
          const SizedBox(height: 12),
          _ThemeModeCard(
            selectedMode: themeMode,
            onModeSelected: (mode) {
              ref.read(themeProvider.notifier).setThemeMode(mode);
              SnackbarMessage.show(
                context: context,
                message: '${_themeModeLabel(mode)} mode applied.',
              );
            },
          ),
          const SizedBox(height: 18),
          const _SectionHeader(title: 'Session', subtitle: ''),
          const SizedBox(height: 12),
          _LogoutCard(
            onLogout: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (!context.mounted) return;
              SnackbarMessage.show(
                context: context,
                message: 'Signed out successfully.',
              );
            },
          ),
        ],
      ),
    );
  }
}

String _themeModeLabel(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'Light';
    case ThemeMode.dark:
      return 'Dark';
    case ThemeMode.system:
      return 'System';
  }
}

class _LiquidSettingsHero extends StatelessWidget {
  final String storeName;
  final String email;

  const _LiquidSettingsHero({required this.storeName, required this.email});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.18),
                  AppColors.primary.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.06),
                ]
              : [
                  Colors.white.withValues(alpha: 0.86),
                  AppColors.primary.withValues(alpha: 0.07),
                  Colors.white.withValues(alpha: 0.68),
                ],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.black.withValues(alpha: 0.06),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.08),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.9),
                            AppColors.purple.withValues(alpha: 0.75),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settings',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Liquid glass look maintain kore essential control gula ekjaygay rakha hoise.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondaryFor(brightness),
                                  height: 1.45,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.05),
                      width: 0.6,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _HeroInfoTile(label: 'Store', value: storeName),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HeroInfoTile(label: 'Account', value: email),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroInfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _HeroInfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondaryFor(brightness),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimaryFor(brightness),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondaryFor(brightness),
          ),
        ),
      ],
    );
  }
}

class _ThemeModeCard extends StatelessWidget {
  final ThemeMode selectedMode;
  final ValueChanged<ThemeMode> onModeSelected;

  const _ThemeModeCard({
    required this.selectedMode,
    required this.onModeSelected,
  });

  static const List<
    ({ThemeMode mode, String label, String hint, IconData icon})
  >
  _options = [
    (
      mode: ThemeMode.dark,
      label: 'Dark',
      hint: 'Deep contrast liquid glass vibe.',
      icon: Icons.dark_mode_rounded,
    ),
    (
      mode: ThemeMode.light,
      label: 'Light',
      hint: 'Bright surface with soft transparency.',
      icon: Icons.light_mode_rounded,
    ),
    (
      mode: ThemeMode.system,
      label: 'System',
      hint: 'Device preference automatically follow korbe.',
      icon: Icons.settings_suggest_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: _options
            .map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ThemeModeOption(
                  label: option.label,
                  hint: option.hint,
                  icon: option.icon,
                  isSelected: selectedMode == option.mode,
                  onTap: () => onModeSelected(option.mode),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeOption({
    required this.label,
    required this.hint,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    AppColors.primary.withValues(alpha: 0.22),
                    AppColors.purple.withValues(alpha: 0.14),
                  ]
                : [
                    Colors.white.withValues(alpha: isDark ? 0.08 : 0.44),
                    Colors.white.withValues(alpha: isDark ? 0.03 : 0.20),
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.32)
                : isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.06),
            width: 0.7,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: isDark ? 0.08 : 0.38),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondaryFor(brightness),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimaryFor(brightness),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hint,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryFor(brightness),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.16),
                  width: 1.4,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 15,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  final VoidCallback onLogout;

  const _LogoutCard({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.logout_rounded, color: AppColors.error),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logout',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimaryFor(brightness),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current session to  safely sign out',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryFor(brightness),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GlassButton(
            label: 'Sign Out',
            onPressed: onLogout,
            icon: Icons.logout_rounded,
            variant: GlassButtonVariant.danger,
          ),
        ],
      ),
    );
  }
}
