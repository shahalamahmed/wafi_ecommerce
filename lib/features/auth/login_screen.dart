import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/core/constants/sizes.dart';
import 'package:wafi_ecommerce/features/auth/auth_model.dart';
import 'package:wafi_ecommerce/features/auth/auth_provider.dart';
import 'package:wafi_ecommerce/shared/widgets/auth_widgets.dart';
import 'package:wafi_ecommerce/shared/widgets/glass_button.dart';
import 'package:wafi_ecommerce/shared/widgets/snackbar_message.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onRegisterTap;

  const LoginScreen({super.key, required this.onRegisterTap});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      SnackbarMessage.show(
        context: context,
        message: 'Email and password are required.',
        isError: true,
      );
      return;
    }

    await ref.read(authControllerProvider.notifier).login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    if (authState.status == AuthStatus.authenticated) {
      SnackbarMessage.show(
        context: context,
        message: 'Signed in successfully.',
      );
    } else if (authState.status == AuthStatus.error) {
      SnackbarMessage.show(
        context: context,
        message: authState.errorMessage ?? 'Unable to sign in.',
        isError: true,
      );
    }
  }

  Future<void> _googleLogin() async {
    await ref.read(authControllerProvider.notifier).loginWithGoogle();

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    if (authState.status == AuthStatus.authenticated) {
      SnackbarMessage.show(
        context: context,
        message: 'Google sign in successful.',
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
                  title: 'Welcome back',
                  subtitle: 'Sign in to your store',
                  brightness: brightness,
                ),

                const SizedBox(height: 32),

                // Glass card
                AuthGlassCard(
                  isDark: isDark,
                  brightness: brightness,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: AppSizes.fontSm,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.sm),

                      GlassButton(
                        label: 'Sign In',
                        onPressed: _login,
                        isLoading: authState.isLoading,
                      ),

                      const SizedBox(height: AppSizes.md),

                      const AuthDivider(label: 'or continue with'),

                      const SizedBox(height: AppSizes.md),

                      GoogleSignInButton(onPressed: _googleLogin),

                      const SizedBox(height: AppSizes.lg),

                      // Register link
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontSize: AppSizes.fontSm,
                                color: AppColors.textSecondaryFor(brightness),
                              ),
                            ),
                            GestureDetector(
                              onTap: widget.onRegisterTap,
                              child: const Text(
                                'Create store →',
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
