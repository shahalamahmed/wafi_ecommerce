import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/utils/converters.dart';

class OrderItem {
  final String productId;
  final String? variantId;
  final String name;
  final String? variantName;
  final String thumbnail;
  final String sku;
  final double price;
  final double costPrice;
  final int quantity;
  final double discount;
  final double subtotal;

  OrderItem({
    required this.productId,
    this.variantId,
    required this.name,
    this.variantName,
    required this.thumbnail,
    required this.sku,
    required this.price,
    required this.costPrice,
    required this.quantity,
    required this.discount,
    required this.subtotal,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) => OrderItem(
    productId: readString(data, 'productId'),
    variantId: data['variantId']?.toString(),
    name: readString(data, 'name'),
    variantName: data['variantName']?.toString(),
    thumbnail: readString(data, 'thumbnail'),
    sku: readString(data, 'sku'),
    price: readDouble(data, 'price'),
    costPrice: readDouble(data, 'costPrice'),
    quantity: readInt(data, 'quantity', fallback: 1),
    discount: readDouble(data, 'discount'),
    subtotal: readDouble(data, 'subtotal'),
  );

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'variantId': variantId,
    'name': name,
    'variantName': variantName,
    'thumbnail': thumbnail,
    'sku': sku,
    'price': price,
    'costPrice': costPrice,
    'quantity': quantity,
    'discount': discount,
    'subtotal': subtotal,
  };
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final String? couponCode;
  final double couponDiscount;
  final double deliveryCharge;
  final double tax;
  final double total;
  final double profit;
  final String paymentStatus;
  final String paymentMethod;
  final double amountPaid;
  final double amountDue;
  final String status;
  final String shippingMethod;
  final Map<String, dynamic> shippingAddress;
  final String trackingNumber;
  final String source;
  final String note;
  final String internalNote;
  final String createdByUid;
  final String createdByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.discount,
    this.couponCode,
    required this.couponDiscount,
    required this.deliveryCharge,
    required this.tax,
    required this.total,
    required this.profit,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.amountPaid,
    required this.amountDue,
    required this.status,
    required this.shippingMethod,
    required this.shippingAddress,
    required this.trackingNumber,
    required this.source,
    required this.note,
    required this.internalNote,
    required this.createdByUid,
    required this.createdByName,
    this.createdAt,
    this.updatedAt,
    this.deliveredAt,
    this.cancelledAt,
  });

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    List<OrderItem>? items,
    double? subtotal,
    double? discount,
    String? couponCode,
    double? couponDiscount,
    double? deliveryCharge,
    double? tax,
    double? total,
    double? profit,
    String? paymentStatus,
    String? paymentMethod,
    double? amountPaid,
    double? amountDue,
    String? status,
    String? shippingMethod,
    Map<String, dynamic>? shippingAddress,
    String? trackingNumber,
    String? source,
    String? note,
    String? internalNote,
    String? createdByUid,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      profit: profit ?? this.profit,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountPaid: amountPaid ?? this.amountPaid,
      amountDue: amountDue ?? this.amountDue,
      status: status ?? this.status,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      source: source ?? this.source,
      note: note ?? this.note,
      internalNote: internalNote ?? this.internalNote,
      createdByUid: createdByUid ?? this.createdByUid,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return OrderModel(
      id: doc.id,
      orderNumber: readString(data, 'orderNumber'),
      customerId: readString(data, 'customerId'),
      customerName: readString(data, 'customerName'),
      customerPhone: readString(data, 'customerPhone'),
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      subtotal: readDouble(data, 'subtotal'),
      discount: readDouble(data, 'discount'),
      couponCode: data['couponCode']?.toString(),
      couponDiscount: readDouble(data, 'couponDiscount'),
      deliveryCharge: readDouble(data, 'deliveryCharge'),
      tax: readDouble(data, 'tax'),
      total: readDouble(data, 'total'),
      profit: readDouble(data, 'profit'),
      paymentStatus: readString(data, 'paymentStatus', fallback: 'unpaid'),
      paymentMethod: readString(data, 'paymentMethod', fallback: 'cash'),
      amountPaid: readDouble(data, 'amountPaid'),
      amountDue: readDouble(data, 'amountDue'),
      status: readString(data, 'status', fallback: 'pending'),
      shippingMethod: readString(data, 'shippingMethod', fallback: 'courier'),
      shippingAddress: readMap(data, 'shippingAddress'),
      trackingNumber: readString(data, 'trackingNumber'),
      source: readString(data, 'source', fallback: 'pos'),
      note: readString(data, 'note'),
      internalNote: readString(data, 'internalNote'),
      createdByUid: readString(data, 'createdByUid'),
      createdByName: readString(data, 'createdByName'),
      createdAt: readDateTime(data, 'createdAt'),
      updatedAt: readDateTime(data, 'updatedAt'),
      deliveredAt: readDateTime(data, 'deliveredAt'),
      cancelledAt: readDateTime(data, 'cancelledAt'),
    );
  }

  Map<String, dynamic> toMap() => {
    'orderNumber': orderNumber,
    'customerId': customerId,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'items': items.map((item) => item.toMap()).toList(),
    'subtotal': subtotal,
    'discount': discount,
    'couponCode': couponCode,
    'couponDiscount': couponDiscount,
    'deliveryCharge': deliveryCharge,
    'tax': tax,
    'total': total,
    'profit': profit,
    'paymentStatus': paymentStatus,
    'paymentMethod': paymentMethod,
    'amountPaid': amountPaid,
    'amountDue': amountDue,
    'status': status,
    'shippingMethod': shippingMethod,
    'shippingAddress': shippingAddress,
    'trackingNumber': trackingNumber,
    'source': source,
    'note': note,
    'internalNote': internalNote,
    'createdByUid': createdByUid,
    'createdByName': createdByName,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  bool get isPaid => paymentStatus == 'paid';

  bool get isDelivered => status == 'delivered';

  bool get isCancelled => status == 'cancelled';

  bool get isPending => status == 'pending';

  int get totalItems =>
      items.fold(0, (runningTotal, item) => runningTotal + item.quantity);
}
