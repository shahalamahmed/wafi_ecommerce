import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/data/firestore/firestore_service.dart';
import 'package:wafi_ecommerce/core/utils/text_utils.dart';
import 'package:wafi_ecommerce/models/product_model.dart';

class ProductService {
  ProductService({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService.instance;

  final FirestoreService _firestore;

  Stream<List<ProductModel>> watchProducts(
    String tenantId, {
    String query = '',
  }) {
    if (tenantId.isEmpty) {
      return Stream.value(const <ProductModel>[]);
    }

    return _firestore
        .products(tenantId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs.map(ProductModel.fromFirestore).where((
            product,
          ) {
            final normalizedQuery = query.trim().toLowerCase();
            if (normalizedQuery.isEmpty) return true;
            return product.name.toLowerCase().contains(normalizedQuery) ||
                product.sku.toLowerCase().contains(normalizedQuery) ||
                product.categoryName.toLowerCase().contains(normalizedQuery) ||
                product.brandName.toLowerCase().contains(normalizedQuery);
          }).toList();
          return items;
        });
  }

  Future<List<ProductModel>> fetchProducts(String tenantId) async {
    if (tenantId.isEmpty) return const [];
    final snapshot = await _firestore
        .products(tenantId)
        .orderBy('updatedAt', descending: true)
        .get();
    return snapshot.docs.map(ProductModel.fromFirestore).toList();
  }

  Future<ProductModel?> fetchProduct(String tenantId, String productId) async {
    if (tenantId.isEmpty || productId.isEmpty) return null;
    final doc = await _firestore.productDoc(tenantId, productId).get();
    if (!doc.exists) return null;
    return ProductModel.fromFirestore(doc);
  }

  Future<String> saveProduct(String tenantId, ProductModel product) async {
    if (tenantId.isEmpty) {
      throw StateError('Tenant id is required.');
    }

    final docRef = product.id.isEmpty
        ? _firestore.products(tenantId).doc()
        : _firestore.productDoc(tenantId, product.id);
    final previousSnap = product.id.isEmpty ? null : await docRef.get();
    final previousCategoryId = previousSnap != null && previousSnap.exists
        ? ProductModel.fromFirestore(previousSnap).categoryId.trim()
        : '';
    final previousBrandId = previousSnap != null && previousSnap.exists
        ? ProductModel.fromFirestore(previousSnap).brandId.trim()
        : '';
    final nextCategoryId = product.categoryId.trim();
    final nextBrandId = product.brandId.trim();

    final data = {
      ...product.toMap(),
      'slug': product.slug.trim().isEmpty
          ? slugify(product.name)
          : product.slug.trim(),
      'isInStock': product.trackInventory ? product.stock > 0 : true,
      if (product.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
    };

    final batch = _firestore.db.batch();
    batch.set(docRef, data, SetOptions(merge: true));

    if (previousCategoryId != nextCategoryId) {
      if (previousCategoryId.isNotEmpty) {
        final oldCategoryRef = _firestore.categoryDoc(
          tenantId,
          previousCategoryId,
        );
        final oldCategorySnap = await oldCategoryRef.get();
        if (oldCategorySnap.exists) {
          batch.update(oldCategoryRef, {
            'productCount': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      if (nextCategoryId.isNotEmpty) {
        final nextCategoryRef = _firestore.categoryDoc(
          tenantId,
          nextCategoryId,
        );
        batch.set(nextCategoryRef, {
          'productCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }

    if (previousBrandId != nextBrandId) {
      if (previousBrandId.isNotEmpty) {
        final oldBrandRef = _firestore.brandDoc(tenantId, previousBrandId);
        final oldBrandSnap = await oldBrandRef.get();
        if (oldBrandSnap.exists) {
          batch.update(oldBrandRef, {
            'productCount': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      if (nextBrandId.isNotEmpty) {
        final nextBrandRef = _firestore.brandDoc(tenantId, nextBrandId);
        batch.set(nextBrandRef, {
          'productCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }

    await batch.commit();
    return docRef.id;
  }

  Future<void> deleteProduct(String tenantId, String productId) async {
    if (tenantId.isEmpty || productId.isEmpty) return;
    final productRef = _firestore.productDoc(tenantId, productId);
    final productSnap = await productRef.get();
    if (!productSnap.exists) return;

    final product = ProductModel.fromFirestore(productSnap);
    final batch = _firestore.db.batch();
    batch.delete(productRef);

    if (product.categoryId.trim().isNotEmpty) {
      final categoryRef = _firestore.categoryDoc(tenantId, product.categoryId);
      final categorySnap = await categoryRef.get();
      if (categorySnap.exists) {
        batch.update(categoryRef, {
          'productCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    if (product.brandId.trim().isNotEmpty) {
      final brandRef = _firestore.brandDoc(tenantId, product.brandId);
      final brandSnap = await brandRef.get();
      if (brandSnap.exists) {
        batch.update(brandRef, {
          'productCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();
  }

  Future<void> updateStock({
    required String tenantId,
    required String productId,
    required int stock,
  }) async {
    final isInStock = stock > 0;
    await _firestore.productDoc(tenantId, productId).update({
      'stock': stock,
      'isInStock': isInStock,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
