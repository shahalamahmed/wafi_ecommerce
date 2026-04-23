import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/providers.dart';
import 'package:wafi_ecommerce/models/customer_model.dart';

final customerListProvider = StreamProvider.family
    .autoDispose<List<CustomerModel>, String>((ref, tenantId) {
      return ref.watch(customerServiceProvider).watchCustomers(tenantId);
    });
