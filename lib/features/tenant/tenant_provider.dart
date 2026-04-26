import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/api/firestore_service.dart';
import 'tenant_model.dart';
import 'tenant_service.dart';

final tenantServiceProvider = Provider<TenantService>((ref) {
  return TenantService(firestore: ref.watch(firestoreServiceProvider));
});

final tenantStreamProvider = StreamProvider.family<TenantModel?, String>((
  ref,
  tenantId,
) {
  return ref.watch(tenantServiceProvider).watchTenant(tenantId);
});
