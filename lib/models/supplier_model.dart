import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/utils/firestore_converters.dart';

class SupplierModel {
  final String id;
  final String name;
  final String contactPerson;
  final String email;
  final String phone;
  final String address;
  final String tradeTerms;
  final String currency;
  final bool isActive;
  final int totalOrders;
  final double totalSpent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SupplierModel({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.address,
    required this.tradeTerms,
    required this.currency,
    required this.isActive,
    required this.totalOrders,
    required this.totalSpent,
    this.createdAt,
    this.updatedAt,
  });

  factory SupplierModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return SupplierModel(
      id: doc.id,
      name: readString(data, 'name'),
      contactPerson: readString(data, 'contactPerson'),
      email: readString(data, 'email'),
      phone: readString(data, 'phone'),
      address: readString(data, 'address'),
      tradeTerms: readString(data, 'tradeTerms'),
      currency: readString(data, 'currency', fallback: 'BDT'),
      isActive: readBool(data, 'isActive', fallback: true),
      totalOrders: readInt(data, 'totalOrders'),
      totalSpent: readDouble(data, 'totalSpent'),
      createdAt: readDateTime(data, 'createdAt'),
      updatedAt: readDateTime(data, 'updatedAt'),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'contactPerson': contactPerson,
    'email': email,
    'phone': phone,
    'address': address,
    'tradeTerms': tradeTerms,
    'currency': currency,
    'isActive': isActive,
    'totalOrders': totalOrders,
    'totalSpent': totalSpent,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
