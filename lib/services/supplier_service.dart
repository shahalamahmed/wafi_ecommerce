import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/data/firestore/firestore_service.dart';
import 'package:wafi_ecommerce/models/supplier_model.dart';

class SupplierService {
  SupplierService({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService.instance;

  final FirestoreService _firestore;

  Stream<List<SupplierModel>> watchSuppliers(String tenantId) {
    if (tenantId.isEmpty) {
      return Stream.value(const <SupplierModel>[]);
    }

    return _firestore.suppliers(tenantId).snapshots().map((snapshot) {
      final suppliers = snapshot.docs
          .map(SupplierModel.fromFirestore)
          .toList(growable: false);
      suppliers.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return suppliers;
    });
  }

  Future<List<SupplierModel>> fetchSuppliers(String tenantId) async {
    if (tenantId.isEmpty) return const [];
    final snapshot = await _firestore.suppliers(tenantId).get();
    final suppliers = snapshot.docs
        .map(SupplierModel.fromFirestore)
        .toList(growable: false);
    suppliers.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return suppliers;
  }

  Future<String> saveSupplier(String tenantId, SupplierModel supplier) async {
    if (tenantId.isEmpty) {
      throw StateError('Tenant id is required.');
    }

    final docRef = supplier.id.isEmpty
        ? _firestore.suppliers(tenantId).doc()
        : _firestore.supplierDoc(tenantId, supplier.id);
    final data = {
      ...supplier.toMap(),
      if (supplier.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(data, SetOptions(merge: true));
    return docRef.id;
  }

  Future<void> deleteSupplier(String tenantId, String supplierId) async {
    if (tenantId.isEmpty || supplierId.isEmpty) return;
    await _firestore.supplierDoc(tenantId, supplierId).delete();
  }
}
