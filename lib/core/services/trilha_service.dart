import 'package:dio/dio.dart';

import '../models/conteudo_educativo.dart';
import '../models/trilha.dart';
import '../network/api_exception.dart';

class TrilhaService {
  final Dio _dio;

  TrilhaService(this._dio);

  Future<List<Trilha>> listarTrilhas() {
    return runApiCall(() async {
      final response = await _dio.get('/trilhas');
      return (response.data['data'] as List)
          .map((t) => Trilha.fromJson(t as Map<String, dynamic>))
          .toList();
    });
  }

  Future<ConteudoEducativo> buscarConteudo(int id) {
    return runApiCall(() async {
      final response = await _dio.get('/conteudos/$id');
      return ConteudoEducativo.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    });
  }

  Future<ConteudoEducativo> marcarLido(int id) {
    return runApiCall(() async {
      final response = await _dio.post('/conteudos/$id/marcar-lido');
      return ConteudoEducativo.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    });
  }
}
