import 'package:wafi_ecommerce/core/constants/user_role.dart';
import 'package:wafi_ecommerce/core/errors/app_error.dart';

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
  final String? photoUrl;
  final String? coverUrl;
  final AppError? error;
  final Map<String, dynamic> permissions;

  const AuthModel({
    this.status = AuthStatus.initial,
    this.uid,
    this.email,
    this.tenantId,
    this.role,
    this.photoUrl,
    this.coverUrl,
    this.error,
    this.permissions = const {},
  });

  // Typed role
  UserRole get userRole => UserRole.fromString(role);

  // Status
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  // Role shortcuts
  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager';
  bool get isStaff => role == 'staff';
  bool get isViewer => role == 'viewer';

  // Subcollection permission check
  bool _perm(String key, {bool writeOnly = false}) {
    final val = permissions[key] as String?;
    if (writeOnly) return val == 'write';
    return val == 'read' || val == 'write';
  }

  // Combined: role-based OR subcollection permission
  bool get canManageProducts =>
      userRole.canCreateProduct || _perm('products', writeOnly: true);
  bool get canManageOrders =>
      userRole.canCreateOrder || _perm('orders', writeOnly: true);
  bool get canManageCustomers =>
      userRole.canCreateCustomer || _perm('customers', writeOnly: true);
  bool get canManageSettings =>
      userRole.canEditSettings || _perm('settings', writeOnly: true);
  bool get canViewReports =>
      userRole.canViewReports || _perm('reports');
  bool get canManageUsers => userRole.canManageUsers;
  bool get canViewCostPrice => userRole.canViewCostPrice;

  AuthModel copyWith({
    AuthStatus? status,
    String? uid,
    String? email,
    String? tenantId,
    String? role,
    String? photoUrl,
    String? coverUrl,
    AppError? error,
    Map<String, dynamic>? permissions,
  }) {
    return AuthModel(
      status: status ?? this.status,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      tenantId: tenantId ?? this.tenantId,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      error: error, // If passed, use it, otherwise keep current (null if not passed)
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  String toString() => 'AuthModel('
      'status: $status, uid: $uid, '
      'email: $email, tenantId: $tenantId, role: $role)';
}