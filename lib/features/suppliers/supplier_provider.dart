import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/api/firestore_service.dart';
import 'package:wafi_ecommerce/core/errors/app_error.dart';
import 'supplier_model.dart';
import 'supplier_service.dart';

final supplierServiceProvider = Provider<SupplierService>((ref) {
  return SupplierService(firestore: ref.watch(firestoreServiceProvider));
});

class SupplierState {
  final List<SupplierModel> suppliers;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int totalCount;
  final AppError? error;

  SupplierState({
    this.suppliers = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.totalCount = 0,
    this.error,
  });

  SupplierState copyWith({
    List<SupplierModel>? suppliers,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? totalCount,
    AppError? error,
  }) {
    return SupplierState(
      suppliers: suppliers ?? this.suppliers,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalCount: totalCount ?? this.totalCount,
      error: error,
    );
  }
}

class SupplierNotifier extends FamilyNotifier<SupplierState, String> {
  late final SupplierService _service;
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  SupplierState build(String arg) {
    _service = ref.watch(supplierServiceProvider);
    
    // Fetch data asynchronously when provider is first initialized
    Future.microtask(() => fetchSuppliers());
    
    return SupplierState(isLoading: true);
  }

  Future<void> fetchSuppliers() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _service.fetchSuppliers(
        arg,
        skipCount: 0,
        maxResultCount: _pageSize,
      );

      if (result.isSuccess && result.data != null) {
        _currentPage = 1;
        
        state = state.copyWith(
          suppliers: result.data!.items,
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
          message: 'Failed to fetch suppliers: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final result = await _service.fetchSuppliers(
        arg,
        skipCount: _currentPage * _pageSize,
        maxResultCount: _pageSize,
      );

      if (result.isSuccess && result.data != null) {
        _currentPage++;

        final newSuppliers = [...state.suppliers, ...result.data!.items];
        
        state = state.copyWith(
          suppliers: newSuppliers,
          isLoadingMore: false,
          hasReachedMax: newSuppliers.length >= result.data!.totalCount,
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
          message: 'Failed to load more suppliers: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> refresh() async {
    _currentPage = 0;
    await fetchSuppliers();
  }

  Future<void> saveSupplier(SupplierModel supplier) async {
    final result = await _service.saveSupplier(arg, supplier);
    
    if (result.isSuccess) {
      await fetchSuppliers();
    } else {
      throw Exception(result.error?.message ?? 'Failed to save supplier');
    }
  }

  Future<void> deleteSupplier(String supplierId) async {
    final result = await _service.deleteSupplier(arg, supplierId);
    
    if (result.isSuccess) {
      final updatedSuppliers = state.suppliers.where((s) => s.id != supplierId).toList();
      state = state.copyWith(
        suppliers: updatedSuppliers,
        totalCount: state.totalCount - 1,
      );
    } else {
      throw Exception(result.error?.message ?? 'Failed to delete supplier');
    }
  }
}

final supplierListProvider = NotifierProvider.family<SupplierNotifier, SupplierState, String>(() {
  return SupplierNotifier();
});

