import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/utils/converters.dart';

class BrandModel {
  final String id;
  final String name;
  final String slug;
  final String logo;
  final String description;
  final String website;
  final bool isActive;
  final int productCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BrandModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.logo,
    required this.description,
    required this.website,
    required this.isActive,
    required this.productCount,
    this.createdAt,
    this.updatedAt,
  });

  factory BrandModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return BrandModel(
      id: doc.id,
      name: readString(data, 'name'),
      slug: readString(data, 'slug'),
      logo: readString(data, 'logo'),
      description: readString(data, 'description'),
      website: readString(data, 'website'),
      isActive: readBool(data, 'isActive', fallback: true),
      productCount: readInt(data, 'productCount'),
      createdAt: readDateTime(data, 'createdAt'),
      updatedAt: readDateTime(data, 'updatedAt'),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'slug': slug,
    'logo': logo,
    'description': description,
    'website': website,
    'isActive': isActive,
    'productCount': productCount,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
