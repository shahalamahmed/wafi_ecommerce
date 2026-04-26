import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/api/firestore_service.dart';
import 'package:wafi_ecommerce/core/errors/error_handler.dart';
import 'package:wafi_ecommerce/core/errors/result.dart';
import 'supplier_model.dart';

class SupplierResponse {
  final List<SupplierModel> items;
  final int totalCount;

  SupplierResponse({required this.items, required this.totalCount});
}

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

  Future<Result<SupplierResponse>> fetchSuppliers(
    String tenantId, {
    int skipCount = 0,
    int maxResultCount = 20,
  }) async {
    try {
      if (tenantId.isEmpty) {
        return Result.success(SupplierResponse(items: [], totalCount: 0));
      }
      
      final query = _firestore.suppliers(tenantId);
      final totalSnapshot = await query.count().get();
      final totalCount = totalSnapshot.count ?? 0;

      final snapshot = await query
          .limit(maxResultCount)
          .get();
          
      final suppliers = snapshot.docs
          .map(SupplierModel.fromFirestore)
          .toList();
      
      suppliers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      
      return Result.success(SupplierResponse(
        items: suppliers,
        totalCount: totalCount,
      ));
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  Future<Result<String>> saveSupplier(String tenantId, SupplierModel supplier) async {
    try {
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
      return Result.success(docRef.id);
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  Future<Result<void>> deleteSupplier(String tenantId, String supplierId) async {
    try {
      if (tenantId.isEmpty || supplierId.isEmpty) return Result.success(null);
      await _firestore.supplierDoc(tenantId, supplierId).delete();
      return Result.success(null);
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }
}
