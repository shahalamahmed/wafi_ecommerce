import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/data/firestore/firestore_service.dart';
import 'package:wafi_ecommerce/core/utils/text_utils.dart';
import 'package:wafi_ecommerce/models/brand_model.dart';

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

  Future<List<BrandModel>> fetchBrands(String tenantId) async {
    if (tenantId.isEmpty) return const [];
    final snapshot = await _firestore.brands(tenantId).get();
    final brands = snapshot.docs
        .map(BrandModel.fromFirestore)
        .toList(growable: false);
    brands.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return brands;
  }

  Future<String> saveBrand(String tenantId, BrandModel brand) async {
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

    return docRef.id;
  }

  Future<void> deleteBrand(String tenantId, String brandId) async {
    if (tenantId.isEmpty || brandId.isEmpty) return;

    await _clearProductsForDeletedBrand(tenantId: tenantId, brandId: brandId);
    await _firestore.brandDoc(tenantId, brandId).delete();
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
