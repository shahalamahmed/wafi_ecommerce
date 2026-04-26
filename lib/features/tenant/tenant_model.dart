import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/utils/converters.dart';

class TenantModel {
  final String id;
  final String name;
  final String slug;
  final String ownerName;
  final String ownerUid;
  final String email;
  final String phone;
  final String address;
  final String logo;
  final String currency;
  final String currencySymbol;
  final String timezone;
  final String storeType;
  final bool isActive;
  final String plan;
  final int totalProducts;
  final int totalOrders;
  final int totalCustomers;
  final double totalRevenue;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TenantModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.ownerName,
    required this.ownerUid,
    required this.email,
    required this.phone,
    required this.address,
    required this.logo,
    required this.currency,
    required this.currencySymbol,
    required this.timezone,
    required this.storeType,
    required this.isActive,
    required this.plan,
    required this.totalProducts,
    required this.totalOrders,
    required this.totalCustomers,
    required this.totalRevenue,
    this.createdAt,
    this.updatedAt,
  });

  factory TenantModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return TenantModel(
      id: doc.id,
      name: readString(data, 'name'),
      slug: readString(data, 'slug'),
      ownerName: readString(data, 'ownerName'),
      ownerUid: readString(data, 'ownerUid'),
      email: readString(data, 'email'),
      phone: readString(data, 'phone'),
      address: readString(data, 'address'),
      logo: readString(data, 'logo'),
      currency: readString(data, 'currency', fallback: 'BDT'),
      currencySymbol: readString(data, 'currencySymbol', fallback: '৳'),
      timezone: readString(data, 'timezone', fallback: 'Asia/Dhaka'),
      storeType: readString(data, 'storeType', fallback: 'general'),
      isActive: readBool(data, 'isActive', fallback: true),
      plan: readString(data, 'plan', fallback: 'free'),
      totalProducts: readInt(data, 'totalProducts'),
      totalOrders: readInt(data, 'totalOrders'),
      totalCustomers: readInt(data, 'totalCustomers'),
      totalRevenue: readDouble(data, 'totalRevenue'),
      createdAt: readDateTime(data, 'createdAt'),
      updatedAt: readDateTime(data, 'updatedAt'),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'slug': slug,
    'ownerName': ownerName,
    'ownerUid': ownerUid,
    'email': email,
    'phone': phone,
    'address': address,
    'logo': logo,
    'currency': currency,
    'currencySymbol': currencySymbol,
    'timezone': timezone,
    'storeType': storeType,
    'isActive': isActive,
    'plan': plan,
    'totalProducts': totalProducts,
    'totalOrders': totalOrders,
    'totalCustomers': totalCustomers,
    'totalRevenue': totalRevenue,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
