import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/api/firestore_service.dart';
import 'package:wafi_ecommerce/core/utils/helpers.dart';
import 'tenant_model.dart';

class TenantService {
  TenantService({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService.instance;

  final FirestoreService _firestore;

  Stream<TenantModel?> watchTenant(String tenantId) {
    if (tenantId.isEmpty) {
      return Stream.value(null);
    }

    return _firestore.tenantDoc(tenantId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return TenantModel.fromFirestore(doc);
    });
  }

  Future<TenantModel?> fetchTenant(String tenantId) async {
    if (tenantId.isEmpty) return null;
    final doc = await _firestore.tenantDoc(tenantId).get();
    if (!doc.exists) return null;
    return TenantModel.fromFirestore(doc);
  }

  Future<void> bootstrapTenant({
    required String tenantId,
    required String storeName,
    required String ownerUid,
    required String ownerName,
    required String ownerEmail,
    String role = 'admin',
  }) async {
    final trimmedStoreName = storeName.trim().isEmpty
        ? 'My Store'
        : storeName.trim();
    final slug = slugify(trimmedStoreName);

    await _firestore.tenantDoc(tenantId).set({
      'name': trimmedStoreName,
      'slug': slug,
      'ownerName': ownerName,
      'ownerUid': ownerUid,
      'email': ownerEmail,
      'phone': '',
      'address': '',
      'logo': '',
      'currency': 'BDT',
      'currencySymbol': '৳',
      'timezone': 'Asia/Dhaka',
      'storeType': 'general',
      'isActive': true,
      'plan': 'free',
      'totalProducts': 0,
      'totalOrders': 0,
      'totalCustomers': 0,
      'totalRevenue': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _firestore.generalSettings(tenantId).set({
      'storeName': trimmedStoreName,
      'logo': '',
      'favicon': '',
      'phone': '',
      'email': ownerEmail,
      'address': '',
      'currency': 'BDT',
      'currencySymbol': '৳',
      'timezone': 'Asia/Dhaka',
      'language': 'en',
      'defaultDeliveryCharge': 100,
      'freeDeliveryAbove': 5000,
      'deliveryMethods': ['courier', 'self-pickup'],
      'acceptedPayments': ['cash', 'bkash', 'nagad', 'card'],
      'bkashNumber': '',
      'nagadNumber': '',
      'lowStockAlertAt': 5,
      'trackInventory': true,
      'allowNegativeStock': false,
      'autoConfirmOrders': false,
      'orderPrefix': 'WF',
      'orderStartNumber': 1,
      'showCostOnInvoice': false,
      'invoiceFooterNote': 'Thank you for shopping with us!',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _firestore.userDoc(ownerUid).set({
      'email': ownerEmail,
      'tenantId': tenantId,
      'role': role,
      'photoUrl': null,
      'coverUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _firestore.userTenantDoc(ownerUid, tenantId).set({
      'role': role,
      'permissions': {
        'products': 'write',
        'orders': 'write',
        'customers': 'write',
        'reports': 'read',
        'settings': 'write',
      },
      'isActive': true,
      'invitedBy': null,
      'joinedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
