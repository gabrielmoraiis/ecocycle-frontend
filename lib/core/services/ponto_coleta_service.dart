import 'package:dio/dio.dart';

import '../models/ponto_coleta.dart';
import '../network/api_exception.dart';

class PontoColetaService {
  final Dio _dio;

  PontoColetaService(this._dio);

  Future<List<PontoColeta>> listar({double? lat, double? lng, double? raioKm}) {
    return runApiCall(() async {
      final response = await _dio.get(
        '/pontos-coleta',
        queryParameters: {'lat': ?lat, 'lng': ?lng, 'raioKm': ?raioKm},
      );
      return (response.data['data'] as List)
          .map((p) => PontoColeta.fromJson(p as Map<String, dynamic>))
          .toList();
    });
  }

  Future<PontoColeta> buscarPorId(int id) {
    return runApiCall(() async {
      final response = await _dio.get('/pontos-coleta/$id');
      return PontoColeta.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    });
  }
}
