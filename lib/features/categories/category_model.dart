import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/utils/converters.dart';

class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String parentId;
  final int level;
  final int sortOrder;
  final String image;
  final bool isActive;
  final int productCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.parentId,
    required this.level,
    required this.sortOrder,
    required this.image,
    required this.isActive,
    required this.productCount,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return CategoryModel(
      id: doc.id,
      name: readString(data, 'name'),
      slug: readString(data, 'slug'),
      description: readString(data, 'description'),
      parentId: readString(data, 'parentId'),
      level: readInt(data, 'level'),
      sortOrder: readInt(data, 'sortOrder'),
      image: readString(data, 'image'),
      isActive: readBool(data, 'isActive', fallback: true),
      productCount: readInt(data, 'productCount'),
      createdAt: readDateTime(data, 'createdAt'),
      updatedAt: readDateTime(data, 'updatedAt'),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'slug': slug,
    'description': description,
    'parentId': parentId.isEmpty ? null : parentId,
    'level': level,
    'sortOrder': sortOrder,
    'image': image,
    'isActive': isActive,
    'productCount': productCount,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
