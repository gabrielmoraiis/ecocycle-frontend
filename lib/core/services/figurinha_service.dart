import 'package:dio/dio.dart';

import '../models/figurinha.dart';
import '../network/api_exception.dart';

class FigurinhaService {
  final Dio _dio;

  FigurinhaService(this._dio);

  Future<List<Figurinha>> listar() {
    return runApiCall(() async {
      final response = await _dio.get('/figurinhas');
      return (response.data['data'] as List)
          .map((f) => Figurinha.fromJson(f as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Figurinha> buscarPorId(int id) {
    return runApiCall(() async {
      final response = await _dio.get('/figurinhas/$id');
      return Figurinha.fromJson(response.data['data'] as Map<String, dynamic>);
    });
  }
}
