import 'package:dio/dio.dart';

import '../models/identificador_componente.dart';
import '../models/requests/scanner_request.dart';
import '../models/resultado_scanner.dart';
import '../network/api_exception.dart';

class ScannerService {
  final Dio _dio;

  ScannerService(this._dio);

  Future<ResultadoScanner> reconhecer(
    IdentificadorComponente identificador,
    double confianca,
  ) {
    return runApiCall(() async {
      final response = await _dio.post(
        '/scanner/reconhecer',
        data: ScannerRequest(
          identificadorComponente: identificador,
          confianca: confianca,
        ).toJson(),
      );
      return ResultadoScanner.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    });
  }

  /// Registra uma foto que o modelo classificou como Outros. Serve só para
  /// acompanhar o modelo em uso real: a resposta não muda nada na tela.
  Future<void> registrarObjetoDesconhecido(double confianca) {
    return runApiCall(() async {
      await _dio.post(
        '/scanner/reconhecer',
        data: {'identificadorComponente': 'OUTROS', 'confianca': confianca},
      );
    });
  }
}
