import 'package:dio/dio.dart';

import 'api_exception.dart';

typedef OnUnauthorized = void Function();

class ErrorInterceptor extends Interceptor {
  final OnUnauthorized? onUnauthorized;

  ErrorInterceptor({this.onUnauthorized});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = _mapear(err);

    final path = err.requestOptions.path;
    final isRotaDeAuth = path.contains('/auth/login') || path.contains('/auth/register');
    if (apiException.isNaoAutorizado && !isRotaDeAuth) {
      onUnauthorized?.call();
    }

    handler.next(err.copyWith(error: apiException));
  }

  ApiException _mapear(DioException err) {
    final response = err.response;
    if (response == null) {
      final isTimeout = err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.receiveTimeout ||
          err.type == DioExceptionType.sendTimeout;
      return ApiException(
        status: 0,
        message: isTimeout
            ? 'O servidor demorou para responder. Se ele estiver "dormindo" (plano gratuito), aguarde um instante e tente novamente.'
            : 'Não foi possível conectar ao servidor. Verifique sua conexão.',
      );
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final errorsRaw = data['errors'];
      return ApiException(
        status: (data['status'] as num?)?.toInt() ?? response.statusCode ?? 500,
        message: (data['message'] as String?) ?? 'Ocorreu um erro inesperado.',
        errors: errorsRaw is List ? errorsRaw.map((e) => e.toString()).toList() : null,
      );
    }

    return ApiException(
      status: response.statusCode ?? 500,
      message: 'Ocorreu um erro inesperado.',
    );
  }
}
