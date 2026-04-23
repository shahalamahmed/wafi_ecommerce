import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/core/constants/sizes.dart';
import 'package:wafi_ecommerce/features/auth/auth_model.dart';
import 'package:wafi_ecommerce/features/auth/auth_provider.dart';
import 'package:wafi_ecommerce/shared/widgets/auth_widgets.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_button.dart';
import 'package:wafi_ecommerce/shared/widgets/snackbar_message.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final VoidCallback onLoginTap;

  const RegisterScreen({super.key, required this.onLoginTap});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _storeNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _confirmObscure = true;

  @override
  void dispose() {
    _storeNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_storeNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      SnackbarMessage.show(
        context: context,
        message: 'Store name, email and password are required.',
        isError: true,
      );
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      SnackbarMessage.show(
        context: context,
        message: 'Password and confirm password must match.',
        isError: true,
      );
      return;
    }

    const tenantId = 'wafi_store_1776856408474';

    await ref
        .read(authControllerProvider.notifier)
        .register(
          storeName: _storeNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          tenantId: tenantId,
          role: 'admin',
        );

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    if (authState.status == AuthStatus.authenticated) {
      SnackbarMessage.show(
        context: context,
        message: 'Store created successfully.',
      );
    } else if (authState.status == AuthStatus.error) {
      SnackbarMessage.show(
        context: context,
        message: authState.errorMessage ?? 'Unable to create store.',
        isError: true,
      );
    }
  }

  Future<void> _googleRegister() async {
    await ref.read(authControllerProvider.notifier).loginWithGoogle();

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    if (authState.status == AuthStatus.authenticated) {
      SnackbarMessage.show(
        context: context,
        message: 'Google account connected successfully.',
      );
    } else if (authState.status == AuthStatus.error) {
      SnackbarMessage.show(
        context: context,
        message: authState.errorMessage ?? 'Google sign in failed.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      body: AuthBackground(
        isDark: isDark,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                AuthHeroHeader(
                  title: 'Create store',
                  subtitle: 'Start your journey',
                  brightness: brightness,
                ),

                const SizedBox(height: 32),

                AuthGlassCard(
                  isDark: isDark,
                  brightness: brightness,
                  child: Column(
                    children: [
                      AuthTextField(
                        controller: _storeNameController,
                        hint: 'Store name',
                        icon: Icons.store_outlined,
                        brightness: brightness,
                      ),
                      const SizedBox(height: AppSizes.md),
                      AuthTextField(
                        controller: _emailController,
                        hint: 'Email address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        brightness: brightness,
                      ),
                      const SizedBox(height: AppSizes.md),
                      AuthTextField(
                        controller: _passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outlined,
                        obscure: _obscure,
                        brightness: brightness,
                        onToggleObscure: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                      const SizedBox(height: AppSizes.md),
                      AuthTextField(
                        controller: _confirmController,
                        hint: 'Confirm password',
                        icon: Icons.lock_outlined,
                        obscure: _confirmObscure,
                        brightness: brightness,
                        onToggleObscure: () =>
                            setState(() => _confirmObscure = !_confirmObscure),
                      ),

                      const SizedBox(height: AppSizes.lg),

                      GlassButton(
                        label: 'Create Store',
                        onPressed: _register,
                        isLoading: authState.isLoading,
                      ),

                      const SizedBox(height: AppSizes.md),
                      const AuthDivider(label: 'or continue with'),
                      const SizedBox(height: AppSizes.md),

                      GoogleSignInButton(onPressed: _googleRegister),

                      const SizedBox(height: AppSizes.lg),

                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                fontSize: AppSizes.fontSm,
                                color: AppColors.textSecondaryFor(brightness),
                              ),
                            ),
                            GestureDetector(
                              onTap: widget.onLoginTap,
                              child: const Text(
                                'Sign in →',
                                style: TextStyle(
                                  fontSize: AppSizes.fontSm,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
