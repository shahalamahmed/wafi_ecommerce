import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/core/providers.dart';
import 'package:wafi_ecommerce/core/theme/theme_provider.dart';
import 'package:wafi_ecommerce/core/utils/firestore_seeder.dart';
import 'package:wafi_ecommerce/features/auth/auth_provider.dart';
import 'package:wafi_ecommerce/shared/widgets/app_section_header.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_button.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_card.dart';
import 'package:wafi_ecommerce/shared/widgets/snackbar_message.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _seedDemo(BuildContext context) async {
    await FirestoreSeeder.seedAll();
    if (!context.mounted) return;
    SnackbarMessage.show(context: context, message: 'Demo data seeded.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final auth = ref.watch(authControllerProvider);
    final tenantId = auth.tenantId ?? '';
    final tenantAsync = ref.watch(tenantStreamProvider(tenantId));
    final tenant = tenantAsync.valueOrNull;
    final brightness = Theme.of(context).brightness;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Theme, session and bootstrap tools in one place.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryFor(brightness),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppSectionHeader(
            title: 'Theme',
            subtitle: 'Light is default. Dark mode stays neutral and glassy.',
          ),
          const SizedBox(height: 12),
          _ThemePicker(
            selectedMode: themeMode,
            onChanged: (mode) =>
                ref.read(themeProvider.notifier).setThemeMode(mode),
          ),
          const SizedBox(height: 16),
          AppSectionHeader(
            title: 'Store info',
            subtitle: 'Tenant and account details used across the app.',
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(
                  label: 'Store',
                  value: tenant?.name ?? auth.tenantId ?? 'Wafi Store',
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  label: 'Owner',
                  value: tenant?.ownerName ?? auth.email ?? '-',
                ),
                const SizedBox(height: 12),
                _InfoRow(label: 'Tenant ID', value: auth.tenantId ?? '-'),
                const SizedBox(height: 12),
                _InfoRow(
                  label: 'Role',
                  value: (auth.role ?? 'admin').toUpperCase(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppSectionHeader(
            title: 'Tools',
            subtitle: 'Helpful actions for development and setup.',
          ),
          const SizedBox(height: 12),
          GlassButton(
            label: 'Seed Demo Data',
            onPressed: () => _seedDemo(context),
            icon: Icons.auto_fix_high_rounded,
          ),
          const SizedBox(height: 12),
          GlassButton(
            label: 'Sign Out',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (!context.mounted) return;
              SnackbarMessage.show(
                context: context,
                message: 'Signed out successfully.',
              );
            },
            icon: Icons.logout_rounded,
            variant: GlassButtonVariant.danger,
          ),
        ],
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  final ThemeMode selectedMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemePicker({required this.selectedMode, required this.onChanged});

  static const _options = [
    (
      mode: ThemeMode.light,
      label: 'Light',
      hint: 'Bright white surfaces and soft shadows.',
      icon: Icons.light_mode_rounded,
    ),
    (
      mode: ThemeMode.dark,
      label: 'Dark',
      hint: 'Muted graphite surfaces with glass blur.',
      icon: Icons.dark_mode_rounded,
    ),
    (
      mode: ThemeMode.system,
      label: 'System',
      hint: 'Follow the device preference automatically.',
      icon: Icons.settings_suggest_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _options
          .map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ThemeOption(
                label: option.label,
                hint: option.hint,
                icon: option.icon,
                selected: selectedMode == option.mode,
                onTap: () => onChanged(option.mode),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.hint,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(
                  alpha: brightness == Brightness.dark ? 0.18 : 0.08,
                )
              : AppColors.glassSurfaceFor(brightness),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.28)
                : AppColors.glassBorderFor(brightness),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.14)
                    : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: selected
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
                      fontWeight: FontWeight.w700,
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
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSecondaryFor(
                          brightness,
                        ).withValues(alpha: 0.35),
                  width: 1.4,
                ),
              ),
              child: selected
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryFor(brightness),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
