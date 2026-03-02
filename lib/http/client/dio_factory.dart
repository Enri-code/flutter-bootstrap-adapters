// packages/bootstrap/lib/src/infra/http/dio_http_client.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

class DioFactory {
  DioFactory._(this.baseUrl);

  final String baseUrl;

  static Dio build({
    required String baseUrl,
    Dio? dio,
    List<Interceptor>? interceptors,
    Duration timeout = const Duration(seconds: 10),
    bool enableLogging = true,
  }) {
    final options = _createOptions(baseUrl, timeout);
    final d = (dio ?? Dio())..options = options;

    d.interceptors.addAll([
      ...?interceptors,
      RetryInterceptor(dio: d, retries: 2),
      if (enableLogging) LogInterceptor(requestBody: true, responseBody: true),
    ]);

    return d;
  }

  static BaseOptions _createOptions(String baseUrl, Duration timeout) {
    final options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: {HttpHeaders.acceptHeader: 'application/json'},
    );
    return options;
  }
}
