import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wafi_ecommerce/core/api/firestore_service.dart';
import 'package:wafi_ecommerce/core/errors/app_error.dart';
import 'category_model.dart';
import 'category_service.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(firestore: ref.watch(firestoreServiceProvider));
});

class CategoryState {
  final List<CategoryModel> categories;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int totalCount;
  final AppError? error;

  CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.totalCount = 0,
    this.error,
  });

  CategoryState copyWith({
    List<CategoryModel>? categories,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? totalCount,
    AppError? error,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalCount: totalCount ?? this.totalCount,
      error: error,
    );
  }
}

class CategoryNotifier extends FamilyNotifier<CategoryState, String> {
  late final CategoryService _service;
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  CategoryState build(String arg) {
    _service = ref.watch(categoryServiceProvider);
    
    // Fetch data asynchronously when provider is first initialized
    Future.microtask(() => fetchCategories());
    
    return CategoryState(isLoading: true);
  }

  Future<void> fetchCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _service.fetchCategories(
        arg,
        skipCount: 0,
        maxResultCount: _pageSize,
      );

      if (result.isSuccess && result.data != null) {
        _currentPage = 1;
        
        state = state.copyWith(
          categories: result.data!.items,
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
          message: 'Failed to fetch categories: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final result = await _service.fetchCategories(
        arg,
        skipCount: _currentPage * _pageSize,
        maxResultCount: _pageSize,
      );

      if (result.isSuccess && result.data != null) {
        _currentPage++;

        final newCategories = [...state.categories, ...result.data!.items];
        
        state = state.copyWith(
          categories: newCategories,
          isLoadingMore: false,
          hasReachedMax: newCategories.length >= result.data!.totalCount,
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
          message: 'Failed to load more categories: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> refresh() async {
    _currentPage = 0;
    await fetchCategories();
  }

  Future<void> saveCategory(CategoryModel category) async {
    final result = await _service.saveCategory(arg, category);
    
    if (result.isSuccess) {
      await fetchCategories();
    } else {
      throw Exception(result.error?.message ?? 'Failed to save category');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    final result = await _service.deleteCategory(arg, categoryId);
    
    if (result.isSuccess) {
      final updatedCategories = state.categories.where((c) => c.id != categoryId).toList();
      state = state.copyWith(
        categories: updatedCategories,
        totalCount: state.totalCount - 1,
      );
    } else {
      throw Exception(result.error?.message ?? 'Failed to delete category');
    }
  }
}

final categoryListProvider = NotifierProvider.family<CategoryNotifier, CategoryState, String>(() {
  return CategoryNotifier();
});

