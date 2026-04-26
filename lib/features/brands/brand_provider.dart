import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/api/firestore_service.dart';
import 'package:wafi_ecommerce/core/errors/app_error.dart';
import 'brand_model.dart';
import 'brand_service.dart';

final brandServiceProvider = Provider<BrandService>((ref) {
  return BrandService(firestore: ref.watch(firestoreServiceProvider));
});

class BrandState {
  final List<BrandModel> brands;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int totalCount;
  final AppError? error;

  BrandState({
    this.brands = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.totalCount = 0,
    this.error,
  });

  BrandState copyWith({
    List<BrandModel>? brands,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? totalCount,
    AppError? error,
  }) {
    return BrandState(
      brands: brands ?? this.brands,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalCount: totalCount ?? this.totalCount,
      error: error,
    );
  }
}

class BrandNotifier extends FamilyNotifier<BrandState, String> {
  late final BrandService _service;
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  BrandState build(String arg) {
    _service = ref.watch(brandServiceProvider);
    
    // Fetch data asynchronously when provider is first initialized
    Future.microtask(() => fetchBrands());
    
    return BrandState(isLoading: true);
  }

  Future<void> fetchBrands() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _service.fetchBrands(
        arg,
        skipCount: 0,
        maxResultCount: _pageSize,
      );

      if (result.isSuccess && result.data != null) {
        _currentPage = 1;
        
        state = state.copyWith(
          brands: result.data!.items,
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
          message: 'Failed to fetch brands: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final result = await _service.fetchBrands(
        arg,
        skipCount: _currentPage * _pageSize,
        maxResultCount: _pageSize,
      );

      if (result.isSuccess && result.data != null) {
        _currentPage++;

        final newBrands = [...state.brands, ...result.data!.items];
        
        state = state.copyWith(
          brands: newBrands,
          isLoadingMore: false,
          hasReachedMax: newBrands.length >= result.data!.totalCount,
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
          message: 'Failed to load more brands: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> refresh() async {
    _currentPage = 0;
    await fetchBrands();
  }

  Future<void> saveBrand(BrandModel brand) async {
    final result = await _service.saveBrand(arg, brand);
    
    if (result.isSuccess) {
      await fetchBrands();
    } else {
      throw Exception(result.error?.message ?? 'Failed to save brand');
    }
  }

  Future<void> deleteBrand(String brandId) async {
    final result = await _service.deleteBrand(arg, brandId);
    
    if (result.isSuccess) {
      final updatedBrands = state.brands.where((b) => b.id != brandId).toList();
      state = state.copyWith(
        brands: updatedBrands,
        totalCount: state.totalCount - 1,
      );
    } else {
      throw Exception(result.error?.message ?? 'Failed to delete brand');
    }
  }
}

final brandListProvider = NotifierProvider.family<BrandNotifier, BrandState, String>(() {
  return BrandNotifier();
});

