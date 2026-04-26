import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/api/firestore_service.dart';
import 'package:wafi_ecommerce/core/errors/app_error.dart';
import 'customer_model.dart';
import 'customer_service.dart';

final customerServiceProvider = Provider<CustomerService>((ref) {
  return CustomerService(firestore: ref.watch(firestoreServiceProvider));
});

class CustomerState {
  final List<CustomerModel> customers;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int totalCount;
  final AppError? error;

  CustomerState({
    this.customers = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.totalCount = 0,
    this.error,
  });

  CustomerState copyWith({
    List<CustomerModel>? customers,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? totalCount,
    AppError? error,
  }) {
    return CustomerState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalCount: totalCount ?? this.totalCount,
      error: error,
    );
  }
}

class CustomerNotifier extends FamilyNotifier<CustomerState, String> {
  late final CustomerService _service;
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  CustomerState build(String arg) {
    _service = ref.watch(customerServiceProvider);
    
    // Fetch data asynchronously when provider is first initialized
    Future.microtask(() => fetchCustomers());
    
    return CustomerState(isLoading: true);
  }

  Future<void> fetchCustomers() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _service.fetchCustomers(
        arg,
        skipCount: 0,
        maxResultCount: _pageSize,
      );

      if (result.isSuccess && result.data != null) {
        _currentPage = 1;
        
        state = state.copyWith(
          customers: result.data!.items,
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
          message: 'Failed to fetch customers: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final result = await _service.fetchCustomers(
        arg,
        skipCount: _currentPage * _pageSize,
        maxResultCount: _pageSize,
      );

      if (result.isSuccess && result.data != null) {
        _currentPage++;

        final newCustomers = [...state.customers, ...result.data!.items];
        
        state = state.copyWith(
          customers: newCustomers,
          isLoadingMore: false,
          hasReachedMax: newCustomers.length >= result.data!.totalCount,
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
          message: 'Failed to load more customers: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> refresh() async {
    _currentPage = 0;
    await fetchCustomers();
  }

  Future<void> saveCustomer(CustomerModel customer) async {
    final result = await _service.saveCustomer(arg, customer);
    
    if (result.isSuccess) {
      await fetchCustomers();
    } else {
      throw Exception(result.error?.message ?? 'Failed to save customer');
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    final result = await _service.deleteCustomer(arg, customerId);
    
    if (result.isSuccess) {
      final updatedCustomers = state.customers.where((c) => c.id != customerId).toList();
      state = state.copyWith(
        customers: updatedCustomers,
        totalCount: state.totalCount - 1,
      );
    } else {
      throw Exception(result.error?.message ?? 'Failed to delete customer');
    }
  }
}

final customerListProvider = NotifierProvider.family<CustomerNotifier, CustomerState, String>(() {
  return CustomerNotifier();
});

