import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/utils/converters.dart';

class ProductModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String sku;
  final String categoryId;
  final String categoryName;
  final String brandId;
  final String brandName;
  final List<String> tags;
  final List<String> images;
  final String thumbnail;
  final double price;
  final double comparePrice;
  final double costPrice;
  final double discount;
  final String currency;
  final bool trackInventory;
  final int stock;
  final int lowStockAlert;
  final bool isInStock;
  final bool hasVariants;
  final List<String> variantOptions;
  final bool isActive;
  final bool isFeatured;
  final int totalSold;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.sku,
    required this.categoryId,
    required this.categoryName,
    required this.brandId,
    required this.brandName,
    required this.tags,
    required this.images,
    required this.thumbnail,
    required this.price,
    required this.comparePrice,
    required this.costPrice,
    required this.discount,
    required this.currency,
    required this.trackInventory,
    required this.stock,
    required this.lowStockAlert,
    required this.isInStock,
    required this.hasVariants,
    required this.variantOptions,
    required this.isActive,
    required this.isFeatured,
    required this.totalSold,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return ProductModel(
      id: doc.id,
      name: readString(data, 'name'),
      slug: readString(data, 'slug'),
      description: readString(data, 'description'),
      sku: readString(data, 'sku'),
      categoryId: readString(data, 'categoryId'),
      categoryName: readString(data, 'categoryName'),
      brandId: readString(data, 'brandId'),
      brandName: readString(data, 'brandName'),
      tags: readStringList(data, 'tags'),
      images: readStringList(data, 'images'),
      thumbnail: readString(data, 'thumbnail'),
      price: readDouble(data, 'price'),
      comparePrice: readDouble(data, 'comparePrice'),
      costPrice: readDouble(data, 'costPrice'),
      discount: readDouble(data, 'discount'),
      currency: readString(data, 'currency', fallback: 'BDT'),
      trackInventory: readBool(data, 'trackInventory', fallback: true),
      stock: readInt(data, 'stock'),
      lowStockAlert: readInt(data, 'lowStockAlert', fallback: 5),
      isInStock: readBool(
        data,
        'isInStock',
        fallback: readInt(data, 'stock') > 0,
      ),
      hasVariants: readBool(data, 'hasVariants'),
      variantOptions: readStringList(data, 'variantOptions'),
      isActive: readBool(data, 'isActive', fallback: true),
      isFeatured: readBool(data, 'isFeatured'),
      totalSold: readInt(data, 'totalSold'),
      createdAt: readDateTime(data, 'createdAt'),
      updatedAt: readDateTime(data, 'updatedAt'),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'slug': slug,
    'description': description,
    'sku': sku,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'brandId': brandId,
    'brandName': brandName,
    'tags': tags,
    'images': images,
    'thumbnail': thumbnail,
    'price': price,
    'comparePrice': comparePrice,
    'costPrice': costPrice,
    'discount': discount,
    'currency': currency,
    'trackInventory': trackInventory,
    'stock': stock,
    'lowStockAlert': lowStockAlert,
    'isInStock': isInStock,
    'hasVariants': hasVariants,
    'variantOptions': variantOptions,
    'isActive': isActive,
    'isFeatured': isFeatured,
    'totalSold': totalSold,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  bool get isLowStock => stock <= lowStockAlert && stock > 0;

  bool get isOutOfStock => stock <= 0;

  double get profitMargin =>
      price > 0 ? ((price - costPrice) / price) * 100 : 0;

  double get profitAmount => price - costPrice;
}
