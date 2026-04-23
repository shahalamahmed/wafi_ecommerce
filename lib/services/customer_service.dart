import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/data/firestore/firestore_service.dart';
import 'package:wafi_ecommerce/models/customer_model.dart';

class CustomerService {
  CustomerService({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService.instance;

  final FirestoreService _firestore;

  Stream<List<CustomerModel>> watchCustomers(String tenantId) {
    if (tenantId.isEmpty) {
      return Stream.value(const <CustomerModel>[]);
    }

    return _firestore
        .customers(tenantId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(CustomerModel.fromFirestore).toList(),
        );
  }

  Future<List<CustomerModel>> fetchCustomers(String tenantId) async {
    if (tenantId.isEmpty) return const [];
    final snapshot = await _firestore
        .customers(tenantId)
        .orderBy('updatedAt', descending: true)
        .get();
    return snapshot.docs.map(CustomerModel.fromFirestore).toList();
  }

  Future<CustomerModel?> fetchCustomer(
    String tenantId,
    String customerId,
  ) async {
    if (tenantId.isEmpty || customerId.isEmpty) return null;
    final doc = await _firestore.customerDoc(tenantId, customerId).get();
    if (!doc.exists) return null;
    return CustomerModel.fromFirestore(doc);
  }

  Future<String> saveCustomer(String tenantId, CustomerModel customer) async {
    final docRef = customer.id.isEmpty
        ? _firestore.customers(tenantId).doc()
        : _firestore.customerDoc(tenantId, customer.id);

    final data = {
      ...customer.toMap(),
      if (customer.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(data, SetOptions(merge: true));
    return docRef.id;
  }

  Future<void> deleteCustomer(String tenantId, String customerId) async {
    if (tenantId.isEmpty || customerId.isEmpty) return;
    await _firestore.customerDoc(tenantId, customerId).delete();
  }
}
