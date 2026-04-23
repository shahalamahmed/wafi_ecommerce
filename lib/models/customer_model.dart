import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/utils/firestore_converters.dart';

class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatar;
  final Map<String, dynamic> defaultAddress;
  final String customerGroup;
  final int loyaltyPoints;
  final int totalOrders;
  final double totalSpent;
  final double averageOrderValue;
  final String source;
  final bool isActive;
  final bool isBlocked;
  final DateTime? lastOrderAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.defaultAddress,
    required this.customerGroup,
    required this.loyaltyPoints,
    required this.totalOrders,
    required this.totalSpent,
    required this.averageOrderValue,
    required this.source,
    required this.isActive,
    required this.isBlocked,
    this.lastOrderAt,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return CustomerModel(
      id: doc.id,
      name: readString(data, 'name'),
      email: readString(data, 'email'),
      phone: readString(data, 'phone'),
      avatar: readString(data, 'avatar'),
      defaultAddress: readMap(data, 'defaultAddress'),
      customerGroup: readString(data, 'customerGroup', fallback: 'regular'),
      loyaltyPoints: readInt(data, 'loyaltyPoints'),
      totalOrders: readInt(data, 'totalOrders'),
      totalSpent: readDouble(data, 'totalSpent'),
      averageOrderValue: readDouble(data, 'averageOrderValue'),
      source: readString(data, 'source', fallback: 'walk-in'),
      isActive: readBool(data, 'isActive', fallback: true),
      isBlocked: readBool(data, 'isBlocked'),
      lastOrderAt: readDateTime(data, 'lastOrderAt'),
      createdAt: readDateTime(data, 'createdAt'),
      updatedAt: readDateTime(data, 'updatedAt'),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
    'avatar': avatar,
    'defaultAddress': defaultAddress,
    'customerGroup': customerGroup,
    'loyaltyPoints': loyaltyPoints,
    'totalOrders': totalOrders,
    'totalSpent': totalSpent,
    'averageOrderValue': averageOrderValue,
    'source': source,
    'isActive': isActive,
    'isBlocked': isBlocked,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  String get city => defaultAddress['city']?.toString() ?? '';
}
