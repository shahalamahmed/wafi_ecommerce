enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthModel {
  final AuthStatus status;
  final String? uid;
  final String? email;
  final String? tenantId;
  final String? role;
  final String? errorMessage;

  const AuthModel({
    this.status = AuthStatus.initial,
    this.uid,
    this.email,
    this.tenantId,
    this.role,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isAdmin => role == 'admin';
  bool get isLoading => status == AuthStatus.loading;

  AuthModel copyWith({
    AuthStatus? status,
    String? uid,
    String? email,
    String? tenantId,
    String? role,
    String? errorMessage,
  }) {
    return AuthModel(
      status: status ?? this.status,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      tenantId: tenantId ?? this.tenantId,
      role: role ?? this.role,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'AuthModel(status: $status, uid: $uid, '
        'email: $email, tenantId: $tenantId, role: $role)';
  }
}