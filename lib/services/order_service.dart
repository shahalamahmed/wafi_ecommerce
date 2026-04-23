import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wafi_ecommerce/core/data/firestore/firestore_service.dart';
import 'package:wafi_ecommerce/models/order_model.dart';
import 'package:wafi_ecommerce/models/product_model.dart';

class OrderLineRequest {
  final String productId;
  final String? variantId;
  final int quantity;
  final double discount;

  const OrderLineRequest({
    required this.productId,
    this.variantId,
    required this.quantity,
    this.discount = 0,
  });
}

class CreateOrderRequest {
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final List<OrderLineRequest> items;
  final double discount;
  final String? couponCode;
  final double couponDiscount;
  final double deliveryCharge;
  final double tax;
  final String paymentStatus;
  final String paymentMethod;
  final double amountPaid;
  final String status;
  final String shippingMethod;
  final Map<String, dynamic> shippingAddress;
  final String trackingNumber;
  final String source;
  final String note;
  final String internalNote;
  final String createdByUid;
  final String createdByName;

  const CreateOrderRequest({
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.items,
    required this.discount,
    this.couponCode,
    required this.couponDiscount,
    required this.deliveryCharge,
    required this.tax,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.amountPaid,
    required this.status,
    required this.shippingMethod,
    required this.shippingAddress,
    required this.trackingNumber,
    required this.source,
    required this.note,
    required this.internalNote,
    required this.createdByUid,
    required this.createdByName,
  });
}

class CreatedOrderResult {
  final String orderId;
  final String orderNumber;
  final double total;

  const CreatedOrderResult({
    required this.orderId,
    required this.orderNumber,
    required this.total,
  });
}

class OrderService {
  OrderService({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService.instance;

  final FirestoreService _firestore;

  Stream<List<OrderModel>> watchOrders(String tenantId) {
    if (tenantId.isEmpty) {
      return Stream.value(const <OrderModel>[]);
    }

    return _firestore
        .orders(tenantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(OrderModel.fromFirestore).toList(),
        );
  }

  Future<List<OrderModel>> fetchOrders(String tenantId) async {
    if (tenantId.isEmpty) return const [];
    final snapshot = await _firestore
        .orders(tenantId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(OrderModel.fromFirestore).toList();
  }

  Future<OrderModel?> fetchOrder(String tenantId, String orderId) async {
    if (tenantId.isEmpty || orderId.isEmpty) return null;
    final doc = await _firestore.orderDoc(tenantId, orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromFirestore(doc);
  }

  Future<CreatedOrderResult> createOrder(
    String tenantId,
    CreateOrderRequest request,
  ) async {
    if (tenantId.isEmpty) {
      throw StateError('Tenant id is required.');
    }
    if (request.items.isEmpty) {
      throw StateError('At least one item is required.');
    }

    final result = await FirebaseFirestore.instance.runTransaction((tx) async {
      final settingsRef = _firestore.generalSettings(tenantId);
      final tenantRef = _firestore.tenantDoc(tenantId);
      final orderRef = _firestore.orders(tenantId).doc();

      final settingsSnap = await tx.get(settingsRef);
      final settingsData = settingsSnap.data() ?? <String, dynamic>{};
      final prefix =
          (settingsData['orderPrefix'] as String?)?.trim().isNotEmpty == true
          ? (settingsData['orderPrefix'] as String).trim()
          : 'WF';
      final nextNumber =
          (((settingsData['orderStartNumber'] as num?)?.toInt() ?? 1).clamp(
            1,
            999999999,
          )).toInt();
      final year = DateTime.now().year;
      final orderNumber =
          '$prefix-$year-${nextNumber.toString().padLeft(4, '0')}';

      double subtotal = 0;
      double profit = 0;
      final orderItems = <OrderItem>[];

      for (final item in request.items) {
        final productRef = _firestore.productDoc(tenantId, item.productId);
        final productSnap = await tx.get(productRef);
        if (!productSnap.exists) {
          throw StateError('Product not found: ${item.productId}');
        }

        final product = ProductModel.fromFirestore(productSnap);
        final qty = max(item.quantity, 1);

        double price = product.price;
        double costPrice = product.costPrice;
        int availableStock = product.stock;
        String? variantName;

        if (item.variantId != null && item.variantId!.isNotEmpty) {
          final variantRef = _firestore.productVariantDoc(
            tenantId,
            item.productId,
            item.variantId!,
          );
          final variantSnap = await tx.get(variantRef);
          if (variantSnap.exists) {
            final variantData = variantSnap.data() ?? <String, dynamic>{};
            price = (variantData['price'] as num?)?.toDouble() ?? price;
            costPrice =
                (variantData['costPrice'] as num?)?.toDouble() ?? costPrice;
            availableStock =
                (variantData['stock'] as num?)?.toInt() ?? availableStock;
            variantName = variantData['name']?.toString();
            final nextVariantStock = availableStock - qty;
            if (product.trackInventory && nextVariantStock < 0) {
              throw StateError('Not enough stock for ${product.name}.');
            }
            tx.update(variantRef, {
              'stock': nextVariantStock,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }

        if (product.trackInventory && item.variantId == null) {
          final nextStock = availableStock - qty;
          if (nextStock < 0) {
            throw StateError('Not enough stock for ${product.name}.');
          }
          tx.update(productRef, {
            'stock': nextStock,
            'isInStock': nextStock > 0,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else if (product.trackInventory && item.variantId != null) {
          tx.update(productRef, {
            'stock': max(product.stock - qty, 0),
            'isInStock': max(product.stock - qty, 0) > 0,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        final lineDiscount = max(item.discount, 0).toDouble();
        final lineSubtotal = max((price * qty) - lineDiscount, 0).toDouble();
        subtotal += lineSubtotal;
        profit += ((price - costPrice) * qty);

        orderItems.add(
          OrderItem(
            productId: product.id,
            variantId: item.variantId,
            name: product.name,
            variantName: variantName,
            thumbnail: product.thumbnail,
            sku: product.sku,
            price: price,
            costPrice: costPrice,
            quantity: qty,
            discount: lineDiscount,
            subtotal: lineSubtotal,
          ),
        );
      }

      final orderLevelDiscount = max(request.discount, 0).toDouble();
      final couponDiscount = max(request.couponDiscount, 0).toDouble();
      final deliveryCharge = max(request.deliveryCharge, 0).toDouble();
      final tax = max(request.tax, 0).toDouble();
      final total = max(
        subtotal - orderLevelDiscount - couponDiscount + deliveryCharge + tax,
        0,
      ).toDouble();
      final amountPaid =
          request.paymentStatus == 'paid' && request.amountPaid == 0
          ? total
          : max(request.amountPaid, 0).toDouble();
      final amountDue = max(total - amountPaid, 0).toDouble();

      String customerId = request.customerId;
      if (customerId.trim().isEmpty && request.customerName.trim().isNotEmpty) {
        final customerRef = _firestore.customers(tenantId).doc();
        tx.set(customerRef, {
          'name': request.customerName.trim(),
          'email': request.customerEmail.trim(),
          'phone': request.customerPhone.trim(),
          'avatar': '',
          'defaultAddress': {
            'label': 'Primary',
            'street': request.shippingAddress['street'] ?? '',
            'area': request.shippingAddress['area'] ?? '',
            'city': request.shippingAddress['city'] ?? '',
            'district': request.shippingAddress['district'] ?? '',
            'postalCode': request.shippingAddress['postalCode'] ?? '',
            'country': request.shippingAddress['country'] ?? 'Bangladesh',
          },
          'customerGroup': 'regular',
          'loyaltyPoints': 0,
          'totalOrders': 0,
          'totalSpent': 0,
          'averageOrderValue': 0,
          'source': request.source,
          'isActive': true,
          'isBlocked': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        customerId = customerRef.id;
      }

      if (customerId.trim().isNotEmpty) {
        final customerRef = _firestore.customerDoc(tenantId, customerId);
        final customerSnap = await tx.get(customerRef);
        if (customerSnap.exists) {
          final customerData = customerSnap.data() ?? <String, dynamic>{};
          final totalOrders =
              ((customerData['totalOrders'] as num?)?.toInt() ?? 0) + 1;
          final totalSpent =
              ((customerData['totalSpent'] as num?)?.toDouble() ?? 0) + total;
          tx.update(customerRef, {
            'totalOrders': totalOrders,
            'totalSpent': totalSpent,
            'averageOrderValue': totalSpent / totalOrders,
            'lastOrderAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      final tenantSnap = await tx.get(tenantRef);
      if (tenantSnap.exists) {
        final tenantData = tenantSnap.data() ?? <String, dynamic>{};
        tx.update(tenantRef, {
          'totalOrders':
              ((tenantData['totalOrders'] as num?)?.toInt() ?? 0) + 1,
          'totalRevenue':
              ((tenantData['totalRevenue'] as num?)?.toDouble() ?? 0) + total,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      tx.set(orderRef, {
        'orderNumber': orderNumber,
        'customerId': customerId,
        'customerName': request.customerName.trim(),
        'customerPhone': request.customerPhone.trim(),
        'items': orderItems.map((item) => item.toMap()).toList(),
        'subtotal': subtotal,
        'discount': orderLevelDiscount,
        'couponCode': request.couponCode,
        'couponDiscount': couponDiscount,
        'deliveryCharge': deliveryCharge,
        'tax': tax,
        'total': total,
        'profit': profit,
        'paymentStatus': request.paymentStatus,
        'paymentMethod': request.paymentMethod,
        'amountPaid': amountPaid,
        'amountDue': amountDue,
        'status': request.status,
        'shippingMethod': request.shippingMethod,
        'shippingAddress': request.shippingAddress,
        'trackingNumber': request.trackingNumber,
        'source': request.source,
        'note': request.note,
        'internalNote': request.internalNote,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'deliveredAt': request.status == 'delivered'
            ? FieldValue.serverTimestamp()
            : null,
        'cancelledAt': request.status == 'cancelled'
            ? FieldValue.serverTimestamp()
            : null,
      });

      tx.set(orderRef.collection('statusHistory').doc(), {
        'fromStatus': null,
        'toStatus': request.status,
        'note': request.note.trim().isEmpty
            ? 'Order created'
            : request.note.trim(),
        'changedBy': request.createdByUid,
        'changedByName': request.createdByName,
        'changedAt': FieldValue.serverTimestamp(),
      });

      tx.set(settingsRef, {
        'orderStartNumber': nextNumber + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return CreatedOrderResult(
        orderId: orderRef.id,
        orderNumber: orderNumber,
        total: total,
      );
    });

    return result;
  }

  Future<void> updateOrderStatus({
    required String tenantId,
    required String orderId,
    required String status,
    String note = '',
    String changedByUid = '',
    String changedByName = '',
  }) async {
    if (tenantId.isEmpty || orderId.isEmpty) return;

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final orderRef = _firestore.orderDoc(tenantId, orderId);
      final orderSnap = await tx.get(orderRef);
      if (!orderSnap.exists) {
        throw StateError('Order not found.');
      }

      final order = OrderModel.fromFirestore(orderSnap);
      if (order.status == status) return;

      if (status == 'cancelled' && order.status != 'cancelled') {
        await _restockOrderItems(tx, tenantId, order.items);
      }

      final update = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        if (status == 'delivered') 'deliveredAt': FieldValue.serverTimestamp(),
        if (status == 'cancelled') 'cancelledAt': FieldValue.serverTimestamp(),
      };

      tx.update(orderRef, update);
      tx.set(orderRef.collection('statusHistory').doc(), {
        'fromStatus': order.status,
        'toStatus': status,
        'note': note.trim().isEmpty ? 'Status updated' : note.trim(),
        'changedBy': changedByUid,
        'changedByName': changedByName,
        'changedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> updatePaymentStatus({
    required String tenantId,
    required String orderId,
    required String paymentStatus,
    double? amountPaid,
  }) async {
    if (tenantId.isEmpty || orderId.isEmpty) return;

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final orderRef = _firestore.orderDoc(tenantId, orderId);
      final orderSnap = await tx.get(orderRef);
      if (!orderSnap.exists) {
        throw StateError('Order not found.');
      }

      final order = OrderModel.fromFirestore(orderSnap);
      final paidAmount = amountPaid ?? order.amountPaid;
      final dueAmount = max(order.total - paidAmount, 0).toDouble();

      tx.update(orderRef, {
        'paymentStatus': paymentStatus,
        'amountPaid': paidAmount,
        'amountDue': dueAmount,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      tx.set(orderRef.collection('statusHistory').doc(), {
        'fromStatus': order.paymentStatus,
        'toStatus': paymentStatus,
        'note': 'Payment updated',
        'changedBy': '',
        'changedByName': '',
        'changedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> _restockOrderItems(
    Transaction tx,
    String tenantId,
    List<OrderItem> items,
  ) async {
    for (final item in items) {
      final productRef = _firestore.productDoc(tenantId, item.productId);
      final productSnap = await tx.get(productRef);
      if (!productSnap.exists) continue;

      final product = ProductModel.fromFirestore(productSnap);
      final nextProductStock = product.stock + item.quantity;

      tx.update(productRef, {
        'stock': nextProductStock,
        'isInStock': nextProductStock > 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (item.variantId != null && item.variantId!.isNotEmpty) {
        final variantRef = _firestore.productVariantDoc(
          tenantId,
          item.productId,
          item.variantId!,
        );
        final variantSnap = await tx.get(variantRef);
        if (!variantSnap.exists) continue;
        final variantData = variantSnap.data() ?? <String, dynamic>{};
        final currentVariantStock =
            ((variantData['stock'] as num?)?.toInt() ?? 0) + item.quantity;
        tx.update(variantRef, {
          'stock': currentVariantStock,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }
}
