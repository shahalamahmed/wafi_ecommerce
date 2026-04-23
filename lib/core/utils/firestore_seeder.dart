import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
///  FIRESTORE SEEDER â€” Multi-Tenant SaaS eCommerce
///  Run seedAll() once to create all collections automatically
/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class FirestoreSeeder {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// â”€â”€ MAIN ENTRY POINT â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  /// Call this function â€” everything else runs automatically
  static Future<void> seedAll() async {
    try {
      debugPrint('ðŸš€ Firestore Seeding started...\n');

      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        debugPrint('âŒ Error: Please login first, then run the seeder!');
        return;
      }

      var tenantId = 'wafi_electronics_$uid';
      try {
        final userSnap = await _db.collection('users').doc(uid).get();
        final existingTenantId = (userSnap.data()?['tenantId'] as String?)
            ?.trim();
        if (existingTenantId != null && existingTenantId.isNotEmpty) {
          tenantId = existingTenantId;
        }
      } catch (_) {
        // If user doc read is blocked by rules, fall back to default tenantId.
      }

      // Step 1: Create Tenant
      await _seedTenant(tenantId, uid);
      debugPrint('');

      // Step 2: Create/Update User
      await _seedUser(uid, tenantId);
      debugPrint('');

      // Step 3: Create Settings
      await _seedSettings(tenantId);
      debugPrint('');

      // Step 4: Create Categories
      final categoryIds = await _seedCategories(tenantId);
      debugPrint('');

      // Step 5: Create Brands
      final brandIds = await _seedBrands(tenantId);
      debugPrint('');

      // Step 6: Create Products
      await _seedProducts(tenantId, categoryIds, brandIds);
      debugPrint('');

      // Step 7: Create Customers
      final customerIds = await _seedCustomers(tenantId);
      debugPrint('');

      // Step 8: Create Orders
      await _seedOrders(tenantId, customerIds);
      debugPrint('');

      // Step 9: Create Suppliers
      await _seedSuppliers(tenantId);
      debugPrint('');

      // Step 10: Create Coupons
      await _seedCoupons(tenantId);
      debugPrint('');

      debugPrint(
        'â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•',
      );
      debugPrint('ðŸŽ‰ All collections created successfully!');
      debugPrint('ðŸ“Œ Tenant ID: $tenantId');
      debugPrint('ðŸ“Œ User UID:  $uid');
      debugPrint(
        'â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•',
      );
    } catch (e) {
      debugPrint('âŒ Seeding Error: $e');
    }
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  1. TENANT
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  static Future<void> _seedTenant(String tenantId, String uid) async {
    debugPrint('ðŸ“¦ Creating Tenant...');

    final docRef = _db.collection('tenants').doc(tenantId);

    await docRef.set({
      'name': 'Wafi Electronics',
      'slug': 'wafi-electronics',
      'ownerName': 'Shah Alam',
      'ownerUid': uid,
      'email': 'shah@wafi.com',
      'phone': '01711000000',
      'address': 'Dhaka, Bangladesh',
      'logo': '',
      'favicon': '',
      'primaryColor': '#1A73E8',
      'currency': 'BDT',
      'currencySymbol': 'à§³',
      'timezone': 'Asia/Dhaka',
      'language': 'bn',
      'storeType': 'electronics',
      'businessType': 'retail',
      'isActive': true,
      'plan': 'free',
      'planExpiry': null,
      'totalProducts': 0,
      'totalOrders': 0,
      'totalCustomers': 0,
      'totalRevenue': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    debugPrint('   âœ… Tenant created â†’ ID: ${docRef.id}');
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  2. USER + TENANT ROLE
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  static Future<void> _seedUser(String uid, String tenantId) async {
    debugPrint('ðŸ‘¤ Creating User...');

    // Global user document
    await _db.collection('users').doc(uid).set({
      'email': _auth.currentUser?.email ?? 'test@gmail.com',
      'tenantId': tenantId,
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Tenant role subcollection
    await _db
        .collection('users')
        .doc(uid)
        .collection('tenants')
        .doc(tenantId)
        .set({
          'role': 'admin',
          'permissions': {
            'products': 'write',
            'orders': 'write',
            'customers': 'write',
            'reports': 'read',
            'settings': 'write',
          },
          'isActive': true,
          'invitedBy': null,
          'joinedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    debugPrint('   âœ… users/$uid â†’ created');
    debugPrint('   âœ… users/$uid/tenants/$tenantId â†’ role: admin');
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  3. SETTINGS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  static Future<void> _seedSettings(String tenantId) async {
    debugPrint('âš™ï¸  Creating Settings...');

    await _db
        .collection('tenants')
        .doc(tenantId)
        .collection('settings')
        .doc('general') // â† Fixed document ID
        .set({
          'storeName': 'Wafi Electronics',
          'logo': '',
          'favicon': '',
          'phone': '01711000000',
          'email': 'info@wafi.com',
          'address': 'Dhaka, Bangladesh',
          'currency': 'BDT',
          'currencySymbol': 'à§³',
          'timezone': 'Asia/Dhaka',
          'language': 'bn',
          'defaultDeliveryCharge': 100,
          'freeDeliveryAbove': 5000,
          'deliveryMethods': ['courier', 'self-pickup'],
          'acceptedPayments': ['cash', 'bkash', 'nagad', 'card'],
          'bkashNumber': '01711000000',
          'nagadNumber': '01811000000',
          'lowStockAlertAt': 5,
          'trackInventory': true,
          'allowNegativeStock': false,
          'autoConfirmOrders': false,
          'orderPrefix': 'WF',
          'orderStartNumber': 1,
          'showCostOnInvoice': false,
          'invoiceFooterNote': 'Thank you for shopping with us!',
          'updatedAt': FieldValue.serverTimestamp(),
        });

    debugPrint('   âœ… settings/general â†’ created');
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  4. CATEGORIES
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  static Future<Map<String, String>> _seedCategories(String tenantId) async {
    debugPrint('ðŸ“‚ Creating Categories...');

    final categoriesRef = _db
        .collection('tenants')
        .doc(tenantId)
        .collection('categories');

    final categoryIds = <String, String>{};

    final categories = [
      {
        'name': 'Smartphones',
        'slug': 'smartphones',
        'description': 'All smartphones',
        'parentId': null,
        'level': 0,
        'sortOrder': 1,
      },
      {
        'name': 'Laptops',
        'slug': 'laptops',
        'description': 'All laptops and notebooks',
        'parentId': null,
        'level': 0,
        'sortOrder': 2,
      },
      {
        'name': 'Accessories',
        'slug': 'accessories',
        'description': 'Phone and laptop accessories',
        'parentId': null,
        'level': 0,
        'sortOrder': 3,
      },
      {
        'name': 'Earbuds',
        'slug': 'earbuds',
        'description': 'Wireless earbuds',
        'parentId': null,
        'level': 1,
        'sortOrder': 1,
      },
    ];

    for (final cat in categories) {
      final doc = await categoriesRef.add({
        ...cat,
        'image': '',
        'isActive': true,
        'productCount': 0,
        'metaTitle': '',
        'metaDescription': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      categoryIds[cat['name'] as String] = doc.id;
      debugPrint('   âœ… Category: ${cat['name']} â†’ ${doc.id}');
    }

    return categoryIds;
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  5. BRANDS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  static Future<Map<String, String>> _seedBrands(String tenantId) async {
    debugPrint('ðŸ·ï¸  Creating Brands...');

    final brandsRef = _db
        .collection('tenants')
        .doc(tenantId)
        .collection('brands');

    final brandIds = <String, String>{};

    final brands = [
      {'name': 'Apple', 'slug': 'apple', 'website': 'https://apple.com'},
      {'name': 'Samsung', 'slug': 'samsung', 'website': 'https://samsung.com'},
      {'name': 'Xiaomi', 'slug': 'xiaomi', 'website': 'https://mi.com'},
      {'name': 'Sony', 'slug': 'sony', 'website': 'https://sony.com'},
    ];

    for (final brand in brands) {
      final doc = await brandsRef.add({
        ...brand,
        'logo': '',
        'description': '',
        'isActive': true,
        'productCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      brandIds[brand['name'] as String] = doc.id;
      debugPrint('   âœ… Brand: ${brand['name']} â†’ ${doc.id}');
    }

    return brandIds;
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  6. PRODUCTS + VARIANTS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  static Future<void> _seedProducts(
    String tenantId,
    Map<String, String> categoryIds,
    Map<String, String> brandIds,
  ) async {
    debugPrint('ðŸ“± Creating Products...');

    final productsRef = _db
        .collection('tenants')
        .doc(tenantId)
        .collection('products');

    // Product 1: iPhone 15 Pro (with variants)
    final iphone = await productsRef.add({
      'name': 'iPhone 15 Pro',
      'slug': 'iphone-15-pro',
      'description': 'Apple iPhone 15 Pro with A17 Pro chip, titanium design',
      'shortDescription': '6.1-inch Super Retina XDR display',
      'sku': 'IPH-15-PRO',
      'barcode': '',
      'categoryId': categoryIds['Smartphones'] ?? '',
      'categoryName': 'Smartphones',
      'brandId': brandIds['Apple'] ?? '',
      'brandName': 'Apple',
      'tags': ['iphone', 'apple', '5g', 'ios', 'smartphone'],
      'images': [],
      'thumbnail': '',
      'price': 150000,
      'comparePrice': 165000,
      'costPrice': 120000,
      'discount': 0,
      'discountPercent': 0,
      'currency': 'BDT',
      'trackInventory': true,
      'stock': 30,
      'lowStockAlert': 5,
      'isInStock': true,
      'hasVariants': true,
      'variantOptions': ['storage', 'color'],
      'weight': 0.187,
      'unit': 'piece',
      'requiresShipping': true,
      'isActive': true,
      'isFeatured': true,
      'isDigital': false,
      'totalSold': 0,
      'totalReviews': 0,
      'avgRating': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('   âœ… Product: iPhone 15 Pro â†’ ${iphone.id}');

    // iPhone Variants
    final iphoneVariants = [
      {
        'name': '128GB â€” Black',
        'storage': '128GB',
        'color': 'Black',
        'price': 140000,
        'stock': 10,
      },
      {
        'name': '256GB â€” Black',
        'storage': '256GB',
        'color': 'Black',
        'price': 150000,
        'stock': 8,
      },
      {
        'name': '256GB â€” White',
        'storage': '256GB',
        'color': 'White Titanium',
        'price': 150000,
        'stock': 7,
      },
      {
        'name': '512GB â€” Black',
        'storage': '512GB',
        'color': 'Black',
        'price': 170000,
        'stock': 5,
      },
    ];

    for (final v in iphoneVariants) {
      await iphone.collection('variants').add({
        'name': v['name'],
        'sku': 'IPH-15-PRO-${v['storage']}-${v['color']}'
            .replaceAll(' ', '-')
            .toUpperCase(),
        'barcode': '',
        'attributes': {'storage': v['storage'], 'color': v['color']},
        'attributeLabel': '${v['storage']} / ${v['color']}',
        'price': v['price'],
        'comparePrice': 165000,
        'costPrice': 120000,
        'stock': v['stock'],
        'lowStockAlert': 3,
        'image': '',
        'isActive': true,
        'isDefault': v['name'] == '256GB â€” Black',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    debugPrint('   âœ… iPhone Variants (4 items) â†’ created');

    // Product 2: Samsung Galaxy S24
    final samsung = await productsRef.add({
      'name': 'Samsung Galaxy S24',
      'slug': 'samsung-galaxy-s24',
      'description': 'Samsung Galaxy S24 with Snapdragon 8 Gen 3',
      'shortDescription': '6.2-inch Dynamic AMOLED display',
      'sku': 'SAM-S24',
      'barcode': '',
      'categoryId': categoryIds['Smartphones'] ?? '',
      'categoryName': 'Smartphones',
      'brandId': brandIds['Samsung'] ?? '',
      'brandName': 'Samsung',
      'tags': ['samsung', 'android', '5g', 'galaxy'],
      'images': [],
      'thumbnail': '',
      'price': 95000,
      'comparePrice': 105000,
      'costPrice': 75000,
      'discount': 0,
      'discountPercent': 0,
      'currency': 'BDT',
      'trackInventory': true,
      'stock': 25,
      'lowStockAlert': 5,
      'isInStock': true,
      'hasVariants': false,
      'variantOptions': [],
      'weight': 0.167,
      'unit': 'piece',
      'requiresShipping': true,
      'isActive': true,
      'isFeatured': false,
      'isDigital': false,
      'totalSold': 0,
      'totalReviews': 0,
      'avgRating': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('   âœ… Product: Samsung Galaxy S24 â†’ ${samsung.id}');

    // Product 3: Sony WH-1000XM5
    await productsRef.add({
      'name': 'Sony WH-1000XM5',
      'slug': 'sony-wh-1000xm5',
      'description': 'Industry-leading noise canceling wireless headphones',
      'shortDescription': '30hr battery, ANC headphones',
      'sku': 'SONY-WH1000XM5',
      'barcode': '',
      'categoryId': categoryIds['Accessories'] ?? '',
      'categoryName': 'Accessories',
      'brandId': brandIds['Sony'] ?? '',
      'brandName': 'Sony',
      'tags': ['headphone', 'sony', 'anc', 'wireless'],
      'images': [],
      'thumbnail': '',
      'price': 35000,
      'comparePrice': 40000,
      'costPrice': 25000,
      'discount': 0,
      'discountPercent': 0,
      'currency': 'BDT',
      'trackInventory': true,
      'stock': 15,
      'lowStockAlert': 3,
      'isInStock': true,
      'hasVariants': false,
      'variantOptions': [],
      'weight': 0.250,
      'unit': 'piece',
      'requiresShipping': true,
      'isActive': true,
      'isFeatured': true,
      'isDigital': false,
      'totalSold': 0,
      'totalReviews': 0,
      'avgRating': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('   âœ… Product: Sony WH-1000XM5 â†’ created');
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  7. CUSTOMERS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  static Future<List<String>> _seedCustomers(String tenantId) async {
    debugPrint('ðŸ‘¥ Creating Customers...');

    final customersRef = _db
        .collection('tenants')
        .doc(tenantId)
        .collection('customers');

    final customerIds = <String>[];

    final customers = [
      {
        'name': 'Rahim Uddin',
        'email': 'rahim@gmail.com',
        'phone': '01811000000',
        'city': 'Dhaka',
        'district': 'Dhaka',
        'customerGroup': 'vip',
        'totalOrders': 5,
        'totalSpent': 75000,
      },
      {
        'name': 'Karim Hossain',
        'email': 'karim@gmail.com',
        'phone': '01911000000',
        'city': 'Chittagong',
        'district': 'Chittagong',
        'customerGroup': 'regular',
        'totalOrders': 2,
        'totalSpent': 30000,
      },
      {
        'name': 'Nasrin Akter',
        'email': 'nasrin@gmail.com',
        'phone': '01611000000',
        'city': 'Sylhet',
        'district': 'Sylhet',
        'customerGroup': 'regular',
        'totalOrders': 1,
        'totalSpent': 15000,
      },
    ];

    for (final c in customers) {
      final doc = await customersRef.add({
        'name': c['name'],
        'email': c['email'],
        'phone': c['phone'],
        'avatar': '',
        'defaultAddress': {
          'label': 'Home',
          'street': '',
          'area': '',
          'city': c['city'],
          'district': c['district'],
          'postalCode': '',
          'country': 'Bangladesh',
        },
        'addresses': [],
        'customerGroup': c['customerGroup'],
        'loyaltyPoints': 0,
        'totalOrders': c['totalOrders'],
        'totalSpent': c['totalSpent'],
        'averageOrderValue':
            (c['totalSpent'] as int) ~/ (c['totalOrders'] as int),
        'lastOrderAt': FieldValue.serverTimestamp(),
        'source': 'walk-in',
        'isActive': true,
        'isBlocked': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      customerIds.add(doc.id);
      debugPrint('   âœ… Customer: ${c['name']} â†’ ${doc.id}');
    }

    return customerIds;
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  8. ORDERS + STATUS HISTORY
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  static Future<void> _seedOrders(
    String tenantId,
    List<String> customerIds,
  ) async {
    debugPrint('ðŸ›’ Creating Orders...');

    final ordersRef = _db
        .collection('tenants')
        .doc(tenantId)
        .collection('orders');

    // Order 1
    final order1 = await ordersRef.add({
      'orderNumber': 'WF-2024-0001',
      'orderType': 'sale',
      'customerId': customerIds.isNotEmpty ? customerIds[0] : '',
      'customerName': 'Rahim Uddin',
      'customerPhone': '01811000000',
      'customerEmail': 'rahim@gmail.com',
      'items': [
        {
          'productId': '',
          'variantId': null,
          'name': 'iPhone 15 Pro',
          'variantName': '256GB â€” Black',
          'thumbnail': '',
          'sku': 'IPH-15-PRO-256-BLK',
          'price': 150000,
          'costPrice': 120000,
          'quantity': 1,
          'discount': 0,
          'subtotal': 150000,
        },
      ],
      'subtotal': 150000,
      'itemDiscount': 0,
      'couponCode': null,
      'couponDiscount': 0,
      'deliveryCharge': 100,
      'tax': 0,
      'total': 150100,
      'profit': 30000,
      'paymentStatus': 'paid',
      'paymentMethod': 'bkash',
      'amountPaid': 150100,
      'amountDue': 0,
      'shippingMethod': 'courier',
      'shippingAddress': {
        'name': 'Rahim Uddin',
        'phone': '01811000000',
        'street': 'House 12, Road 5',
        'area': 'Mirpur',
        'city': 'Dhaka',
        'district': 'Dhaka',
        'postalCode': '1216',
        'country': 'Bangladesh',
      },
      'trackingNumber': '',
      'courierName': 'Pathao',
      'status': 'delivered',
      'note': '',
      'internalNote': '',
      'source': 'pos',
      'assignedTo': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'confirmedAt': FieldValue.serverTimestamp(),
      'shippedAt': FieldValue.serverTimestamp(),
      'deliveredAt': FieldValue.serverTimestamp(),
      'cancelledAt': null,
    });
    debugPrint('   âœ… Order: WF-2024-0001 â†’ ${order1.id}');

    // Status History for Order 1
    final statusHistory = [
      {'from': 'pending', 'to': 'confirmed', 'note': 'Order confirmed'},
      {'from': 'confirmed', 'to': 'processing', 'note': 'Started packing'},
      {'from': 'processing', 'to': 'shipped', 'note': 'Handed to Pathao'},
      {'from': 'shipped', 'to': 'delivered', 'note': 'Customer received'},
    ];

    for (final s in statusHistory) {
      await order1.collection('statusHistory').add({
        'fromStatus': s['from'],
        'toStatus': s['to'],
        'note': s['note'],
        'changedBy': _auth.currentUser?.uid ?? '',
        'changedByName': 'Shah Alam',
        'changedAt': FieldValue.serverTimestamp(),
      });
    }
    debugPrint('   âœ… Status History (4 logs) â†’ created');

    // Order 2
    final order2 = await ordersRef.add({
      'orderNumber': 'WF-2024-0002',
      'orderType': 'sale',
      'customerId': customerIds.length > 1 ? customerIds[1] : '',
      'customerName': 'Karim Hossain',
      'customerPhone': '01911000000',
      'customerEmail': 'karim@gmail.com',
      'items': [
        {
          'productId': '',
          'variantId': null,
          'name': 'Samsung Galaxy S24',
          'variantName': null,
          'thumbnail': '',
          'sku': 'SAM-S24',
          'price': 95000,
          'costPrice': 75000,
          'quantity': 1,
          'discount': 0,
          'subtotal': 95000,
        },
      ],
      'subtotal': 95000,
      'itemDiscount': 0,
      'couponCode': null,
      'couponDiscount': 0,
      'deliveryCharge': 100,
      'tax': 0,
      'total': 95100,
      'profit': 20000,
      'paymentStatus': 'unpaid',
      'paymentMethod': 'cash',
      'amountPaid': 0,
      'amountDue': 95100,
      'shippingMethod': 'courier',
      'shippingAddress': {
        'name': 'Karim Hossain',
        'phone': '01911000000',
        'street': '',
        'area': 'Agrabad',
        'city': 'Chittagong',
        'district': 'Chittagong',
        'postalCode': '',
        'country': 'Bangladesh',
      },
      'trackingNumber': '',
      'courierName': '',
      'status': 'pending',
      'note': 'Call before delivery',
      'internalNote': '',
      'source': 'phone',
      'assignedTo': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'confirmedAt': null,
      'shippedAt': null,
      'deliveredAt': null,
      'cancelledAt': null,
    });
    debugPrint('   âœ… Order: WF-2024-0002 â†’ ${order2.id}');
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  9. SUPPLIERS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  static Future<void> _seedSuppliers(String tenantId) async {
    debugPrint('ðŸ­ Creating Suppliers...');

    final suppliersRef = _db
        .collection('tenants')
        .doc(tenantId)
        .collection('suppliers');

    await suppliersRef.add({
      'name': 'Global Tech Imports',
      'contactPerson': 'Jakir Hossain',
      'email': 'jakir@globaltech.com',
      'phone': '01900000001',
      'address': 'Motijheel, Dhaka',
      'tradeTerms': 'NET30',
      'currency': 'BDT',
      'isActive': true,
      'totalOrders': 0,
      'totalSpent': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    debugPrint('   âœ… Supplier: Global Tech Imports â†’ created');
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  10. COUPONS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  static Future<void> _seedCoupons(String tenantId) async {
    debugPrint('ðŸŽŸï¸  Creating Coupons...');

    final couponsRef = _db
        .collection('tenants')
        .doc(tenantId)
        .collection('coupons');

    final coupons = [
      {
        'code': 'SAVE10',
        'description': '10% discount on all products',
        'type': 'percentage',
        'value': 10,
        'minOrderAmount': 1000,
        'maxDiscountAmount': 500,
        'usageLimit': 100,
        'perCustomerLimit': 1,
      },
      {
        'code': 'FLAT200',
        'description': '200 BDT flat discount',
        'type': 'flat',
        'value': 200,
        'minOrderAmount': 2000,
        'maxDiscountAmount': 200,
        'usageLimit': 50,
        'perCustomerLimit': 1,
      },
    ];

    for (final c in coupons) {
      await couponsRef.add({
        ...c,
        'usedCount': 0,
        'applicableTo': 'all',
        'categoryIds': [],
        'productIds': [],
        'isActive': true,
        'startsAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 30)),
        ),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('   âœ… Coupon: ${c['code']} â†’ created');
    }
  }
}
