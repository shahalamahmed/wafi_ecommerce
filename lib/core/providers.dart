import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/data/firestore/firestore_service.dart';
import 'package:wafi_ecommerce/models/brand_model.dart';
import 'package:wafi_ecommerce/models/category_model.dart';
import 'package:wafi_ecommerce/models/customer_model.dart';
import 'package:wafi_ecommerce/models/order_model.dart';
import 'package:wafi_ecommerce/models/product_model.dart';
import 'package:wafi_ecommerce/models/supplier_model.dart';
import 'package:wafi_ecommerce/models/tenant_model.dart';
import 'package:wafi_ecommerce/services/brand_service.dart';
import 'package:wafi_ecommerce/services/category_service.dart';
import 'package:wafi_ecommerce/services/customer_service.dart';
import 'package:wafi_ecommerce/services/order_service.dart';
import 'package:wafi_ecommerce/services/product_service.dart';
import 'package:wafi_ecommerce/services/supplier_service.dart';
import 'package:wafi_ecommerce/services/tenant_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService.instance;
});

final tenantServiceProvider = Provider<TenantService>((ref) {
  return TenantService(firestore: ref.watch(firestoreServiceProvider));
});

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(firestore: ref.watch(firestoreServiceProvider));
});

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(firestore: ref.watch(firestoreServiceProvider));
});

final brandServiceProvider = Provider<BrandService>((ref) {
  return BrandService(firestore: ref.watch(firestoreServiceProvider));
});

final supplierServiceProvider = Provider<SupplierService>((ref) {
  return SupplierService(firestore: ref.watch(firestoreServiceProvider));
});

final customerServiceProvider = Provider<CustomerService>((ref) {
  return CustomerService(firestore: ref.watch(firestoreServiceProvider));
});

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(firestore: ref.watch(firestoreServiceProvider));
});

final tenantStreamProvider = StreamProvider.family<TenantModel?, String>((
  ref,
  tenantId,
) {
  return ref.watch(tenantServiceProvider).watchTenant(tenantId);
});

final productsStreamProvider =
    StreamProvider.family<List<ProductModel>, String>((ref, tenantId) {
      return ref.watch(productServiceProvider).watchProducts(tenantId);
    });

final categoriesStreamProvider =
    StreamProvider.family<List<CategoryModel>, String>((ref, tenantId) {
      return ref.watch(categoryServiceProvider).watchCategories(tenantId);
    });

final brandsStreamProvider = StreamProvider.family<List<BrandModel>, String>((
  ref,
  tenantId,
) {
  return ref.watch(brandServiceProvider).watchBrands(tenantId);
});

final suppliersStreamProvider =
    StreamProvider.family<List<SupplierModel>, String>((ref, tenantId) {
      return ref.watch(supplierServiceProvider).watchSuppliers(tenantId);
    });

final customersStreamProvider =
    StreamProvider.family<List<CustomerModel>, String>((ref, tenantId) {
      return ref.watch(customerServiceProvider).watchCustomers(tenantId);
    });

final ordersStreamProvider = StreamProvider.family<List<OrderModel>, String>((
  ref,
  tenantId,
) {
  return ref.watch(orderServiceProvider).watchOrders(tenantId);
});
