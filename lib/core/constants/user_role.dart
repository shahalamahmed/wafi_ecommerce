
enum UserRole {
  admin,
  manager,
  staff,
  viewer;

  static UserRole fromString(String? value) {
    return UserRole.values.firstWhere(
          (r) => r.name == value,
      orElse: () => UserRole.viewer,
    );
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:   return 'Admin';
      case UserRole.manager: return 'Manager';
      case UserRole.staff:   return 'Staff';
      case UserRole.viewer:  return 'Viewer';
    }
  }

  // ✅ সব role সব কিছু করতে পারবে
  bool get canViewProducts    => true;
  bool get canCreateProduct   => true;
  bool get canEditProduct     => true;
  bool get canDeleteProduct   => true;
  bool get canViewOrders      => true;
  bool get canCreateOrder     => true;
  bool get canUpdateOrder     => true;
  bool get canCancelOrder     => true;
  bool get canDeleteOrder     => true;
  bool get canViewCustomers   => true;
  bool get canCreateCustomer  => true;
  bool get canEditCustomer    => true;
  bool get canDeleteCustomer  => true;
  bool get canViewReports     => true;
  bool get canViewCostPrice   => true;
  bool get canViewSettings    => true;
  bool get canEditSettings    => true;
  bool get canManageUsers     => true;
  bool get canManageCoupons   => true;
  bool get canManageSuppliers => true;
  bool get canDeleteAnything  => true;
  bool get isAtLeastManager   => true;
  bool get isAtLeastStaff     => true;

  bool get canManageProducts  => true;
  bool get canManageOrders    => true;
  bool get canManageCustomers => true;
}