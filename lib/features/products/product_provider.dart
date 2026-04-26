import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/api/firestore_service.dart';
import 'package:wafi_ecommerce/core/errors/app_error.dart';
import 'product_model.dart';
import 'product_service.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(firestore: ref.watch(firestoreServiceProvider));
});

class ProductState {
  final List<ProductModel> products;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int totalCount;
  final AppError? error;

  ProductState({
    this.products = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.totalCount = 0,
    this.error,
  });

  ProductState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? totalCount,
    AppError? error,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalCount: totalCount ?? this.totalCount,
      error: error,
    );
  }
}

class ProductNotifier extends FamilyNotifier<ProductState, String> {
  late final ProductService _service;
  int _currentPage = 0;
  static const int _pageSize = 10;

  @override
  ProductState build(String arg) {
    _service = ref.watch(productServiceProvider);
    
    // Fetch data asynchronously when provider is first initialized
    Future.microtask(() => fetchProducts());
    
    return ProductState(isLoading: true);
  }

  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _service.fetchProducts(
        arg,
        skipCount: 0,
        maxResultCount: _pageSize,
      );

      if (result.isSuccess && result.data != null) {
        _currentPage = 1;
        
        state = state.copyWith(
          products: result.data!.items,
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
          message: 'Failed to fetch products: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final result = await _service.fetchProducts(
        arg,
        skipCount: _currentPage * _pageSize,
        maxResultCount: _pageSize,
      );

      if (result.isSuccess && result.data != null) {
        _currentPage++;

        final newProducts = [...state.products, ...result.data!.items];
        
        state = state.copyWith(
          products: newProducts,
          isLoadingMore: false,
          hasReachedMax: newProducts.length >= result.data!.totalCount,
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
          message: 'Failed to load more products: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> refresh() async {
    _currentPage = 0;
    await fetchProducts();
  }

  Future<void> deleteProduct(ProductModel product) async {
    final result = await _service.deleteProduct(arg, product.id);
    
    if (result.isSuccess) {
      final updatedProducts = state.products.where((p) => p.id != product.id).toList();
      state = state.copyWith(
        products: updatedProducts,
        totalCount: state.totalCount - 1,
      );
    } else {
      throw Exception(result.error?.message ?? 'Failed to delete product');
    }
  }

  Future<void> saveProduct(ProductModel product) async {
    final result = await _service.saveProduct(arg, product);
    
    if (result.isSuccess && result.data != null) {
      // Refresh the list to show updated data
      await fetchProducts();
    } else {
      throw Exception(result.error?.message ?? 'Failed to save product');
    }
  }
}

final productListProvider = NotifierProvider.family<ProductNotifier, ProductState, String>(() {
  return ProductNotifier();
});

