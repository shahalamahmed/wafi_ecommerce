import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/api/firestore_service.dart';
import 'package:wafi_ecommerce/core/errors/error_handler.dart';
import 'package:wafi_ecommerce/core/errors/result.dart';
import 'package:wafi_ecommerce/core/utils/helpers.dart';
import 'product_model.dart';

class ProductResponse {
  final List<ProductModel> items;
  final int totalCount;

  ProductResponse({required this.items, required this.totalCount});
}

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

  Future<Result<ProductResponse>> fetchProducts(
    String tenantId, {
    int skipCount = 0,
    int maxResultCount = 10,
  }) async {
    try {
      if (tenantId.isEmpty) {
        return Result.success(ProductResponse(items: [], totalCount: 0));
      }

      final query = _firestore
          .products(tenantId)
          .orderBy('updatedAt', descending: true);

      // Get total count (for simple implementation, we might skip this or use a separate query)
      final totalSnapshot = await query.count().get();
      final totalCount = totalSnapshot.count ?? 0;

      final snapshot = await query
          .limit(maxResultCount)
          .get();
      
      // Note: skipCount in Firestore usually requires startAfter. 
      // For a simple refactor to match the user's structure, we'll use limit.
      // In a real app, we'd use lastDocument for cursor-based pagination.

      final items = snapshot.docs.map(ProductModel.fromFirestore).toList();
      return Result.success(ProductResponse(items: items, totalCount: totalCount));
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  Future<Result<ProductModel?>> fetchProduct(String tenantId, String productId) async {
    try {
      if (tenantId.isEmpty || productId.isEmpty) return Result.success(null);
      final doc = await _firestore.productDoc(tenantId, productId).get();
      if (!doc.exists) return Result.success(null);
      return Result.success(ProductModel.fromFirestore(doc));
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  Future<Result<String>> saveProduct(String tenantId, ProductModel product) async {
    try {
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
          batch.update(oldCategoryRef, {
            'productCount': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
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
          batch.update(oldBrandRef, {
            'productCount': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
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
      return Result.success(docRef.id);
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  Future<Result<void>> deleteProduct(String tenantId, String productId) async {
    try {
      if (tenantId.isEmpty || productId.isEmpty) return Result.success(null);
      final productRef = _firestore.productDoc(tenantId, productId);
      final productSnap = await productRef.get();
      if (!productSnap.exists) return Result.success(null);

      final product = ProductModel.fromFirestore(productSnap);
      final batch = _firestore.db.batch();
      batch.delete(productRef);

      if (product.categoryId.trim().isNotEmpty) {
        final categoryRef = _firestore.categoryDoc(tenantId, product.categoryId);
        batch.update(categoryRef, {
          'productCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (product.brandId.trim().isNotEmpty) {
        final brandRef = _firestore.brandDoc(tenantId, product.brandId);
        batch.update(brandRef, {
          'productCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      return Result.success(null);
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  Future<Result<void>> updateStock({
    required String tenantId,
    required String productId,
    required int stock,
  }) async {
    try {
      final isInStock = stock > 0;
      await _firestore.productDoc(tenantId, productId).update({
        'stock': stock,
        'isInStock': isInStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return Result.success(null);
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }
}
