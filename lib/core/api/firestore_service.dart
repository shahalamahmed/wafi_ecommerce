import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService.instance;
});


class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseFirestore get db => _db;

  CollectionReference<Map<String, dynamic>> users() => _db.collection('users');

  DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      users().doc(uid);

  CollectionReference<Map<String, dynamic>> tenants() =>
      _db.collection('tenants');

  DocumentReference<Map<String, dynamic>> tenantDoc(String tenantId) =>
      tenants().doc(tenantId);

  CollectionReference<Map<String, dynamic>> userTenants(String uid) =>
      userDoc(uid).collection('tenants');

  DocumentReference<Map<String, dynamic>> userTenantDoc(
    String uid,
    String tenantId,
  ) => userTenants(uid).doc(tenantId);

  CollectionReference<Map<String, dynamic>> products(String tenantId) =>
      tenantDoc(tenantId).collection('products');

  DocumentReference<Map<String, dynamic>> productDoc(
    String tenantId,
    String productId,
  ) => products(tenantId).doc(productId);

  CollectionReference<Map<String, dynamic>> productVariants(
    String tenantId,
    String productId,
  ) => productDoc(tenantId, productId).collection('variants');

  DocumentReference<Map<String, dynamic>> productVariantDoc(
    String tenantId,
    String productId,
    String variantId,
  ) => productVariants(tenantId, productId).doc(variantId);

  CollectionReference<Map<String, dynamic>> orders(String tenantId) =>
      tenantDoc(tenantId).collection('orders');

  DocumentReference<Map<String, dynamic>> orderDoc(
    String tenantId,
    String orderId,
  ) => orders(tenantId).doc(orderId);

  CollectionReference<Map<String, dynamic>> customers(String tenantId) =>
      tenantDoc(tenantId).collection('customers');

  DocumentReference<Map<String, dynamic>> customerDoc(
    String tenantId,
    String customerId,
  ) => customers(tenantId).doc(customerId);

  CollectionReference<Map<String, dynamic>> categories(String tenantId) =>
      tenantDoc(tenantId).collection('categories');

  DocumentReference<Map<String, dynamic>> categoryDoc(
    String tenantId,
    String categoryId,
  ) => categories(tenantId).doc(categoryId);

  CollectionReference<Map<String, dynamic>> brands(String tenantId) =>
      tenantDoc(tenantId).collection('brands');

  DocumentReference<Map<String, dynamic>> brandDoc(
    String tenantId,
    String brandId,
  ) => brands(tenantId).doc(brandId);

  CollectionReference<Map<String, dynamic>> suppliers(String tenantId) =>
      tenantDoc(tenantId).collection('suppliers');

  DocumentReference<Map<String, dynamic>> supplierDoc(
    String tenantId,
    String supplierId,
  ) => suppliers(tenantId).doc(supplierId);

  CollectionReference<Map<String, dynamic>> coupons(String tenantId) =>
      tenantDoc(tenantId).collection('coupons');

  DocumentReference<Map<String, dynamic>> generalSettings(String tenantId) =>
      tenantDoc(tenantId).collection('settings').doc('general');
}
