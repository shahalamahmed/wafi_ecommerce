import 'app_error.dart';

class Result<T> {
  final T? data;
  final AppError? error;

  const Result._({this.data, this.error});

  factory Result.success(T? data) {
    return Result._(data: data);
  }

  factory Result.failure(AppError error) {
    return Result._(error: error);
  }

  bool get isSuccess => error == null;
}
