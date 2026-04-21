import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._();
  factory DioClient() => _instance;
  DioClient._() {
    _init();
  }

  late final Dio dio;

  void _init() {
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(),
      _LoggerInterceptor(),
    ]);
  }
}

// Auth Interceptor
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await SecureStorage().getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    if (err.response?.statusCode == 401) {
      await SecureStorage().clearAll();
    }
    handler.next(err);
  }
}

// Logger Interceptor
class _LoggerInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) {
    // ignore: avoid_print
    print('REQUEST → ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(
      Response response,
      ResponseInterceptorHandler handler,
      ) {
    // ignore: avoid_print
    print('RESPONSE → ${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) {
    // ignore: avoid_print
    print('ERROR → ${err.message}');
    handler.next(err);
  }
}