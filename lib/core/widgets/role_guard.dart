import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/constants/user_role.dart';
import 'package:wafi_ecommerce/features/auth/auth_model.dart';
import 'package:wafi_ecommerce/features/auth/auth_provider.dart';

class RoleGuard extends ConsumerWidget {
  final bool Function(UserRole role) canAccess;

  final Widget child;

  final Widget? fallback;

  const RoleGuard({
    super.key,
    required this.canAccess,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(typedRoleProvider);
    return canAccess(role) ? child : (fallback ?? const SizedBox.shrink());
  }
}


class AuthGuard extends ConsumerWidget {
  final bool Function(AuthModel auth) canAccess;
  final Widget child;
  final Widget? fallback;

  const AuthGuard({
    super.key,
    required this.canAccess,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return canAccess(auth) ? child : (fallback ?? const SizedBox.shrink());
  }
}