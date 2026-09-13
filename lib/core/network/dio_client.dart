import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

Dio buildDioClient({
  required TokenProvider getToken,
  OnUnauthorized? onUnauthorized,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.apiBaseUrl,
      // O backend gratuito do Render "dorme" quando ocioso e pode levar
      // dezenas de segundos para responder à primeira requisição.
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      contentType: 'application/json',
    ),
  );

  dio.interceptors.add(AuthInterceptor(getToken: getToken));
  dio.interceptors.add(ErrorInterceptor(onUnauthorized: onUnauthorized));

  return dio;
}
