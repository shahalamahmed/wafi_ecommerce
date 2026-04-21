import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_model.dart';
import 'auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthController extends StateNotifier<AuthModel> {
  final AuthService _authService;

  AuthController(this._authService)
      : super(const AuthModel(status: AuthStatus.initial));

  // Initialize ✅
  Future<void> initializeAuth() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _authService.initializeAuth();

    if (result.isSuccess) {
      state = result.data!;
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: result.error?.message,
      );
    }
  }

  // Login ✅
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
        errorMessage: result.error?.message,
      );
    }
  }

  // Register ✅
  Future<void> register({
    required String email,
    required String password,
    required String tenantId,
    String role = 'admin',
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _authService.register(
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
        errorMessage: result.error?.message,
      );
    }
  }

  // Logout ✅
  Future<void> logout() async {
    await _authService.logout();
    state = const AuthModel(
      status: AuthStatus.unauthenticated,
    );
  }
}

final authControllerProvider =
StateNotifierProvider<AuthController, AuthModel>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});

final tenantIdProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).tenantId;
});

final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).role;
});