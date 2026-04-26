
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/constants/user_role.dart';
import 'package:wafi_ecommerce/features/auth/auth_model.dart';
import 'package:wafi_ecommerce/features/auth/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthNotifier extends Notifier<AuthModel> {
  late final AuthService _authService;

  @override
  AuthModel build() {
    _authService = ref.watch(authServiceProvider);
    
    // Fetch data asynchronously when provider is first initialized
    Future.microtask(() => initializeAuth());
    
    return const AuthModel(status: AuthStatus.initial);
  }

  Future<void> initializeAuth() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _authService.initializeAuth();

    if (result.isSuccess) {
      state = result.data!;
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: result.error,
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _authService.login(
      email: email,
      password: password,
    );

    if (result.isSuccess) {
      state = result.data!;
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        error: result.error,
      );
      throw Exception(result.error?.message ?? 'Login failed');
    }
  }

  Future<void> register({
    required String storeName,
    required String email,
    required String password,
    required String tenantId,
    String role = 'admin',
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _authService.register(
      storeName: storeName,
      email: email,
      password: password,
      tenantId: tenantId,
      role: role,
    );

    if (result.isSuccess) {
      state = result.data!;
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        error: result.error,
      );
      throw Exception(result.error?.message ?? 'Registration failed');
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _authService.loginWithGoogle();

    if (result.isSuccess) {
      state = result.data!;
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        error: result.error,
      );
      throw Exception(result.error?.message ?? 'Google login failed');
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthModel(status: AuthStatus.unauthenticated);
  }

  void updatePhotoUrl(String url) => state = state.copyWith(photoUrl: url);

  void updateCoverUrl(String url) => state = state.copyWith(coverUrl: url);
}

// Main auth provider
final authControllerProvider = NotifierProvider<AuthNotifier, AuthModel>(() {
  return AuthNotifier();
});

final tenantIdProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).tenantId;
});

final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).role;
});

final typedRoleProvider = Provider<UserRole>((ref) {
  return ref.watch(authControllerProvider).userRole;
});

final photoUrlProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).photoUrl;
});

final coverUrlProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).coverUrl;
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).isAdmin;
});

final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).uid;
});