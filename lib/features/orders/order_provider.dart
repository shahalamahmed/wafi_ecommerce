import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/api/firestore_service.dart';
import 'package:wafi_ecommerce/core/errors/app_error.dart';
import 'order_model.dart';
import 'order_service.dart';
import 'package:wafi_ecommerce/features/auth/auth_provider.dart';
import 'package:wafi_ecommerce/core/constants/user_role.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(firestore: ref.watch(firestoreServiceProvider));
});

class OrderState {
  final List<OrderModel> orders;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int totalCount;
  final AppError? error;

  OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.totalCount = 0,
    this.error,
  });

  OrderState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? totalCount,
    AppError? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalCount: totalCount ?? this.totalCount,
      error: error,
    );
  }
}

class OrderNotifier extends FamilyNotifier<OrderState, String> {
  late final OrderService _service;
  int _currentPage = 0;
  static const int _pageSize = 10;
  String? _filterUid;

  @override
  OrderState build(String arg) {
    _service = ref.watch(orderServiceProvider);
    
    final role = ref.watch(typedRoleProvider);
    final auth = ref.watch(authControllerProvider);
    
    _filterUid = (role == UserRole.viewer) ? auth.uid : null;

    // Fetch data asynchronously when provider is first initialized
    Future.microtask(() => fetchOrders());
    
    return OrderState(isLoading: true);
  }

  Future<void> fetchOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _service.fetchOrders(
        arg,
        uid: _filterUid,
        skipCount: 0,
        maxResultCount: _pageSize,
      );

      if (result.isSuccess && result.data != null) {
        _currentPage = 1;
        
        state = state.copyWith(
          orders: result.data!.items,
          totalCount: result.data!.totalCount,
          isLoading: false,
          hasReachedMax: result.data!.items.length >= result.data!.totalCount,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppError(
          type: ErrorType.unknown,
          message: 'Failed to fetch orders: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final result = await _service.fetchOrders(
        arg,
        uid: _filterUid,
        skipCount: _currentPage * _pageSize,
        maxResultCount: _pageSize,
      );

      if (result.isSuccess && result.data != null) {
        _currentPage++;

        final newOrders = [...state.orders, ...result.data!.items];
        
        state = state.copyWith(
          orders: newOrders,
          isLoadingMore: false,
          hasReachedMax: newOrders.length >= result.data!.totalCount,
        );
      } else {
        state = state.copyWith(
          isLoadingMore: false,
          error: result.error,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: AppError(
          type: ErrorType.unknown,
          message: 'Failed to load more orders: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> refresh() async {
    _currentPage = 0;
    await fetchOrders();
  }

  Future<void> createOrder(CreateOrderRequest request) async {
    final result = await _service.createOrder(arg, request);
    
    if (result.isSuccess) {
      await fetchOrders();
    } else {
      throw Exception(result.error?.message ?? 'Failed to create order');
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    String note = '',
    String changedByUid = '',
    String changedByName = '',
  }) async {
    final result = await _service.updateOrderStatus(
      tenantId: arg,
      orderId: orderId,
      status: status,
      note: note,
      changedByUid: changedByUid,
      changedByName: changedByName,
    );
    
    if (result.isSuccess) {
      // Update local state if item exists
      final updatedOrders = state.orders.map((o) {
        if (o.id == orderId) {
          return o.copyWith(status: status);
        }
        return o;
      }).toList();
      state = state.copyWith(orders: updatedOrders);
    } else {
      throw Exception(result.error?.message ?? 'Failed to update order status');
    }
  }
}

final orderListProvider = NotifierProvider.family<OrderNotifier, OrderState, String>(() {
  return OrderNotifier();
});

