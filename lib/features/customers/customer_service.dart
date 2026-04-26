import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/api/firestore_service.dart';
import 'package:wafi_ecommerce/core/errors/error_handler.dart';
import 'package:wafi_ecommerce/core/errors/result.dart';
import 'customer_model.dart';

class CustomerResponse {
  final List<CustomerModel> items;
  final int totalCount;

  CustomerResponse({required this.items, required this.totalCount});
}

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

  Future<Result<CustomerResponse>> fetchCustomers(
    String tenantId, {
    int skipCount = 0,
    int maxResultCount = 20,
  }) async {
    try {
      if (tenantId.isEmpty) {
        return Result.success(CustomerResponse(items: [], totalCount: 0));
      }
      
      final query = _firestore.customers(tenantId).orderBy('updatedAt', descending: true);
      final totalSnapshot = await query.count().get();
      final totalCount = totalSnapshot.count ?? 0;

      final snapshot = await query
          .limit(maxResultCount)
          .get();
          
      final customers = snapshot.docs
          .map(CustomerModel.fromFirestore)
          .toList();
      
      return Result.success(CustomerResponse(
        items: customers,
        totalCount: totalCount,
      ));
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  Future<Result<CustomerModel?>> fetchCustomer(
    String tenantId,
    String customerId,
  ) async {
    try {
      if (tenantId.isEmpty || customerId.isEmpty) return Result.success(null);
      final doc = await _firestore.customerDoc(tenantId, customerId).get();
      if (!doc.exists) return Result.success(null);
      return Result.success(CustomerModel.fromFirestore(doc));
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  Future<Result<String>> saveCustomer(String tenantId, CustomerModel customer) async {
    try {
      final docRef = customer.id.isEmpty
          ? _firestore.customers(tenantId).doc()
          : _firestore.customerDoc(tenantId, customer.id);

      final data = {
        ...customer.toMap(),
        if (customer.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(data, SetOptions(merge: true));
      return Result.success(docRef.id);
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  Future<Result<void>> deleteCustomer(String tenantId, String customerId) async {
    try {
      if (tenantId.isEmpty || customerId.isEmpty) return Result.success(null);
      await _firestore.customerDoc(tenantId, customerId).delete();
      return Result.success(null);
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }
}
