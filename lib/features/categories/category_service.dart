import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/api/firestore_service.dart';
import 'package:wafi_ecommerce/core/utils/helpers.dart';
import 'package:wafi_ecommerce/core/errors/error_handler.dart';
import 'package:wafi_ecommerce/core/errors/result.dart';
import 'category_model.dart';

class CategoryResponse {
  final List<CategoryModel> items;
  final int totalCount;

  CategoryResponse({required this.items, required this.totalCount});
}

class CategoryService {
  CategoryService({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService.instance;

  final FirestoreService _firestore;

  Stream<List<CategoryModel>> watchCategories(String tenantId) {
    if (tenantId.isEmpty) {
      return Stream.value(const <CategoryModel>[]);
    }

    return _firestore.categories(tenantId).snapshots().map((snapshot) {
      final categories = snapshot.docs
          .map(CategoryModel.fromFirestore)
          .toList(growable: false);
      return _sortCategories(categories);
    });
  }

  Future<Result<CategoryResponse>> fetchCategories(
    String tenantId, {
    int skipCount = 0,
    int maxResultCount = 20,
  }) async {
    try {
      if (tenantId.isEmpty) {
        return Result.success(CategoryResponse(items: [], totalCount: 0));
      }
      
      final query = _firestore.categories(tenantId);
      final totalSnapshot = await query.count().get();
      final totalCount = totalSnapshot.count ?? 0;

      final snapshot = await query
          .limit(maxResultCount)
          .get();
          
      final categories = snapshot.docs
          .map(CategoryModel.fromFirestore)
          .toList();
      
      return Result.success(CategoryResponse(
        items: _sortCategories(categories),
        totalCount: totalCount,
      ));
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  Future<Result<String>> saveCategory(String tenantId, CategoryModel category) async {
    try {
      if (tenantId.isEmpty) {
        throw StateError('Tenant id is required.');
      }

      final docRef = category.id.isEmpty
          ? _firestore.categories(tenantId).doc()
          : _firestore.categoryDoc(tenantId, category.id);
      final previousSnap = category.id.isEmpty ? null : await docRef.get();
      final previousName = previousSnap != null && previousSnap.exists
          ? CategoryModel.fromFirestore(previousSnap).name.trim()
          : '';
      final nextName = category.name.trim();

      final data = {
        ...category.toMap(),
        'slug': category.slug.trim().isEmpty
            ? slugify(category.name)
            : category.slug.trim(),
        if (category.id.isEmpty) 'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(data, SetOptions(merge: true));

      if (category.id.isNotEmpty &&
          previousName.isNotEmpty &&
          previousName != nextName) {
        await _syncProductsForCategory(
          tenantId: tenantId,
          categoryId: docRef.id,
          categoryName: nextName,
        );
      }

      return Result.success(docRef.id);
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  Future<Result<void>> deleteCategory(String tenantId, String categoryId) async {
    try {
      if (tenantId.isEmpty || categoryId.isEmpty) return Result.success(null);

      await _clearProductsForDeletedCategory(
        tenantId: tenantId,
        categoryId: categoryId,
      );
      await _firestore.categoryDoc(tenantId, categoryId).delete();
      return Result.success(null);
    } catch (e) {
      return Result.failure(ErrorHandler.handle(e));
    }
  }

  Future<void> _syncProductsForCategory({
    required String tenantId,
    required String categoryId,
    required String categoryName,
  }) async {
    final snapshot = await _firestore
        .products(tenantId)
        .where('categoryId', isEqualTo: categoryId)
        .get();

    await _updateProducts(snapshot.docs, (batch, doc) {
      batch.update(doc.reference, {
        'categoryName': categoryName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> _clearProductsForDeletedCategory({
    required String tenantId,
    required String categoryId,
  }) async {
    final snapshot = await _firestore
        .products(tenantId)
        .where('categoryId', isEqualTo: categoryId)
        .get();

    await _updateProducts(snapshot.docs, (batch, doc) {
      batch.update(doc.reference, {
        'categoryId': '',
        'categoryName': '',
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

  static List<CategoryModel> _sortCategories(List<CategoryModel> categories) {
    final sorted = [...categories];
    sorted.sort((a, b) {
      final levelCompare = a.level.compareTo(b.level);
      if (levelCompare != 0) return levelCompare;
      final orderCompare = a.sortOrder.compareTo(b.sortOrder);
      if (orderCompare != 0) return orderCompare;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return sorted;
  }
}
