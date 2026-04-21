import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/constants/colors.dart';
import 'package:wafi_ecommerce/core/constants/sizes.dart';
import 'package:wafi_ecommerce/features/auth/auth_model.dart';
import 'package:wafi_ecommerce/features/auth/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final _storeNameController = TextEditingController();
  bool _loginObscure = true;
  bool _registerObscure = true;
  bool _confirmObscure = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    _storeNameController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loginEmailController.text.isEmpty ||
        _loginPasswordController.text.isEmpty) {
      return;
    }
    await ref.read(authControllerProvider.notifier).login(
      email: _loginEmailController.text,
      password: _loginPasswordController.text,
    );
  }

  Future<void> _register() async {
    if (_registerEmailController.text.isEmpty ||
        _registerPasswordController.text.isEmpty ||
        _storeNameController.text.isEmpty) {
      return;
    }
    if (_registerPasswordController.text !=
        _registerConfirmPasswordController.text) {
      return;
    }

    // tenantId হবে storeName lowercase + timestamp
    final tenantId =
        '${_storeNameController.text.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';

    await ref.read(authControllerProvider.notifier).register(
      email: _registerEmailController.text,
      password: _registerPasswordController.text,
      tenantId: tenantId,
      role: 'admin',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.bgPrimary,
              AppColors.bgSecondary,
              AppColors.bgTertiary,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // Logo
                _buildLogo(),

                const SizedBox(height: 40),

                // Glass Card
                _buildGlassCard(authState),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.purple],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),

        const SizedBox(height: 20),

        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Wafi ',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -1,
                ),
              ),
              TextSpan(
                text: 'Ecommerce',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Multi-tenant eCommerce platform',
          style: TextStyle(
            fontSize: AppSizes.fontMd,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard(AuthModel authState) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tab Bar
          _buildTabBar(),

          // Tab Content
          SizedBox(
            height: _tabController.index == 0 ? 340 : 480,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLoginTab(authState),
                _buildRegisterTab(authState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.md),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() {}),
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: AppSizes.fontMd,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: AppSizes.fontMd,
          fontWeight: FontWeight.w400,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Sign In'),
          Tab(text: 'Register'),
        ],
      ),
    );
  }

  Widget _buildLoginTab(AuthModel authState) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        children: [
          // Email
          _buildTextField(
            controller: _loginEmailController,
            hint: 'Email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: AppSizes.md),

          // Password
          _buildTextField(
            controller: _loginPasswordController,
            hint: 'Password',
            icon: Icons.lock_outlined,
            obscure: _loginObscure,
            onToggleObscure: () {
              setState(() => _loginObscure = !_loginObscure);
            },
          ),

          const SizedBox(height: AppSizes.sm),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: AppSizes.fontSm,
                ),
              ),
            ),
          ),

          // Error
          if (authState.status == AuthStatus.error)
            _buildErrorWidget(authState.errorMessage ?? 'Error!'),

          const SizedBox(height: AppSizes.sm),

          // Login Button
          _buildPrimaryButton(
            label: 'Sign In',
            isLoading: authState.isLoading,
            onPressed: _login,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterTab(AuthModel authState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        children: [
          // Store Name
          _buildTextField(
            controller: _storeNameController,
            hint: 'Store name',
            icon: Icons.store_outlined,
          ),

          const SizedBox(height: AppSizes.md),

          // Email
          _buildTextField(
            controller: _registerEmailController,
            hint: 'Email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: AppSizes.md),

          // Password
          _buildTextField(
            controller: _registerPasswordController,
            hint: 'Password',
            icon: Icons.lock_outlined,
            obscure: _registerObscure,
            onToggleObscure: () {
              setState(() => _registerObscure = !_registerObscure);
            },
          ),

          const SizedBox(height: AppSizes.md),

          // Confirm Password
          _buildTextField(
            controller: _registerConfirmPasswordController,
            hint: 'Confirm password',
            icon: Icons.lock_outlined,
            obscure: _confirmObscure,
            onToggleObscure: () {
              setState(() => _confirmObscure = !_confirmObscure);
            },
          ),

          // Error
          if (authState.status == AuthStatus.error)
            _buildErrorWidget(authState.errorMessage ?? 'Error!'),

          const SizedBox(height: AppSizes.lg),

          // Register Button
          _buildPrimaryButton(
            label: 'Create Store',
            isLoading: authState.isLoading,
            onPressed: _register,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppSizes.fontMd,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: AppSizes.iconSm),
        suffixIcon: onToggleObscure != null
            ? IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: AppSizes.iconSm,
          ),
          onPressed: onToggleObscure,
        )
            : null,
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: AppSizes.iconSm,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: AppSizes.fontSm,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
          label,
          style: const TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}