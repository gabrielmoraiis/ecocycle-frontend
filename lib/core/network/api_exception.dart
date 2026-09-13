import 'package:dio/dio.dart';

Future<T> runApiCall<T>(Future<T> Function() chamada) async {
  try {
    return await chamada();
  } on DioException catch (e) {
    if (e.error is ApiException) throw e.error as ApiException;
    throw const ApiException(status: 0, message: 'Ocorreu um erro inesperado.');
  }
}

class ApiException implements Exception {
  final int status;
  final String message;
  final List<String>? errors;

  const ApiException({
    required this.status,
    required this.message,
    this.errors,
  });

  bool get isValidacao => status == 400;
  bool get isNaoAutorizado => status == 401;
  bool get isNaoEncontrado => status == 404;
  bool get isConflito => status == 409;
  bool get isRateLimit => status == 429;
  bool get isSemConexao => status == 0;

  @override
  String toString() => message;
}
