import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/providers.dart';
import 'package:wafi_ecommerce/models/category_model.dart';

final categoryListProvider = StreamProvider.family
    .autoDispose<List<CategoryModel>, String>((ref, tenantId) {
      return ref.watch(categoryServiceProvider).watchCategories(tenantId);
    });
