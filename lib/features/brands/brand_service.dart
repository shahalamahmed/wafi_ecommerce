import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/api/firestore_service.dart';
import 'package:wafi_ecommerce/core/utils/helpers.dart';
import 'package:wafi_ecommerce/core/errors/error_handler.dart';
import 'package:wafi_ecommerce/core/errors/result.dart';
import 'brand_model.dart';

class BrandResponse {
  final List<BrandModel> items;
  final int totalCount;

  BrandResponse({required this.items, required this.totalCount});
}

class BrandService {
  BrandService({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService.instance;

  final FirestoreService _firestore;

  Stream<List<BrandModel>> watchBrands(String tenantId) {
    if (tenantId.isEmpty) {
      return Stream.value(const <BrandModel>[]);
    }

    return _firestore.brands(tenantId).snapshots().map((snapshot) {
      final brands = snapshot.docs
          .map(BrandModel.fromFirestore)
          .toList(growable: false);
      brands.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return brands;
    });
  }

  Future<Result<BrandResponse>> fetchBrands(
    String tenantId, {
    int skipCount = 0,
    int maxResultCount = 20,
  }) async {
    try {
      if (tenantId.isEmpty) {
        return Result.success(BrandResponse(items: [], totalCount: 0));
      }
      
      final query = _firestore.brands(tenantId);
      final totalSnapshot = await query.count().get();
      final totalCount = totalSnapshot.count ?? 0;

      final snapshot = await query
          .limit(maxResultCount)
          .get();
          
      final brands = snapshot.docs
          .map(BrandModel.fromFirestore)
          .toList();
      
      brands.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      
      return Result.success(BrandResponse(
        items: brands,
        totalCount: totalCount,
      ));
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  Future<Result<String>> saveBrand(String tenantId, BrandModel brand) async {
    try {
      if (tenantId.isEmpty) {
        throw StateError('Tenant id is required.');
      }

      final docRef = brand.id.isEmpty
          ? _firestore.brands(tenantId).doc()
          : _firestore.brandDoc(tenantId, brand.id);
      final previousSnap = brand.id.isEmpty ? null : await docRef.get();
      final previousName = previousSnap != null && previousSnap.exists
          ? BrandModel.fromFirestore(previousSnap).name.trim()
          : '';
      final nextName = brand.name.trim();

      final data = {
        ...brand.toMap(),
        'slug': brand.slug.trim().isEmpty
            ? slugify(brand.name)
            : brand.slug.trim(),
        if (brand.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(data, SetOptions(merge: true));

      if (brand.id.isNotEmpty &&
          previousName.isNotEmpty &&
          previousName != nextName) {
        await _syncProductsForBrand(
          tenantId: tenantId,
          brandId: docRef.id,
          brandName: nextName,
        );
      }

      return Result.success(docRef.id);
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  Future<Result<void>> deleteBrand(String tenantId, String brandId) async {
    try {
      if (tenantId.isEmpty || brandId.isEmpty) return Result.success(null);

      await _clearProductsForDeletedBrand(tenantId: tenantId, brandId: brandId);
      await _firestore.brandDoc(tenantId, brandId).delete();
      return Result.success(null);
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  Future<void> _syncProductsForBrand({
    required String tenantId,
    required String brandId,
    required String brandName,
  }) async {
    final snapshot = await _firestore
        .products(tenantId)
        .where('brandId', isEqualTo: brandId)
        .get();

    await _updateProducts(snapshot.docs, (batch, doc) {
      batch.update(doc.reference, {
        'brandName': brandName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> _clearProductsForDeletedBrand({
    required String tenantId,
    required String brandId,
  }) async {
    final snapshot = await _firestore
        .products(tenantId)
        .where('brandId', isEqualTo: brandId)
        .get();

    await _updateProducts(snapshot.docs, (batch, doc) {
      batch.update(doc.reference, {
        'brandId': '',
        'brandName': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> _updateProducts(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    void Function(
      WriteBatch batch,
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
    )
    applyUpdate,
  ) async {
    if (docs.isEmpty) return;

    var batch = _firestore.db.batch();
    var operationCount = 0;

    Future<void> commitBatch() async {
      if (operationCount == 0) return;
      await batch.commit();
      batch = _firestore.db.batch();
      operationCount = 0;
    }

    for (final doc in docs) {
      applyUpdate(batch, doc);
      operationCount++;
      if (operationCount >= 400) {
        await commitBatch();
      }
    }

    await commitBatch();
  }
}
