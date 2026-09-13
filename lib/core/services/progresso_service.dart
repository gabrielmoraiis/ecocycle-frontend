import 'package:dio/dio.dart';

import '../models/progresso.dart';
import '../network/api_exception.dart';

class ProgressoService {
  final Dio _dio;

  ProgressoService(this._dio);

  Future<Progresso> meuProgresso() {
    return runApiCall(() async {
      final response = await _dio.get('/progresso/me');
      return Progresso.fromJson(response.data['data'] as Map<String, dynamic>);
    });
  }
}
