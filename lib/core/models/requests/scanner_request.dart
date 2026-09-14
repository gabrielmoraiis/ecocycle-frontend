import '../identificador_componente.dart';

class ScannerRequest {
  final IdentificadorComponente identificadorComponente;
  final double confianca;

  const ScannerRequest({
    required this.identificadorComponente,
    required this.confianca,
  });

  Map<String, dynamic> toJson() => {
    'identificadorComponente': identificadorComponente.valor,
    'confianca': confianca,
  };
}
