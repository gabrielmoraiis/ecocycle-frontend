import 'package:dio/dio.dart';

import '../models/identificador_componente.dart';
import '../models/requests/scanner_request.dart';
import '../models/resultado_scanner.dart';
import '../network/api_exception.dart';

class ScannerService {
  final Dio _dio;

  ScannerService(this._dio);

  Future<ResultadoScanner> reconhecer(IdentificadorComponente identificador, double confianca) {
    return runApiCall(() async {
      final response = await _dio.post(
        '/scanner/reconhecer',
        data: ScannerRequest(identificadorComponente: identificador, confianca: confianca).toJson(),
      );
      return ResultadoScanner.fromJson(response.data['data'] as Map<String, dynamic>);
    });
  }
}
