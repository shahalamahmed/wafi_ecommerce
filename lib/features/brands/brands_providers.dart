import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/providers.dart';
import 'package:wafi_ecommerce/models/brand_model.dart';

final brandListProvider = StreamProvider.family
    .autoDispose<List<BrandModel>, String>((ref, tenantId) {
      return ref.watch(brandServiceProvider).watchBrands(tenantId);
    });
