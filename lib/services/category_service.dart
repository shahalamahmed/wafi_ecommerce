import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/data/firestore/firestore_service.dart';
import 'package:wafi_ecommerce/core/utils/text_utils.dart';
import 'package:wafi_ecommerce/models/category_model.dart';

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

  Future<List<CategoryModel>> fetchCategories(String tenantId) async {
    if (tenantId.isEmpty) return const [];
    final snapshot = await _firestore.categories(tenantId).get();
    final categories = snapshot.docs
        .map(CategoryModel.fromFirestore)
        .toList(growable: false);
    return _sortCategories(categories);
  }

  Future<String> saveCategory(String tenantId, CategoryModel category) async {
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

    return docRef.id;
  }

  Future<void> deleteCategory(String tenantId, String categoryId) async {
    if (tenantId.isEmpty || categoryId.isEmpty) return;

    await _clearProductsForDeletedCategory(
      tenantId: tenantId,
      categoryId: categoryId,
    );
    await _firestore.categoryDoc(tenantId, categoryId).delete();
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
