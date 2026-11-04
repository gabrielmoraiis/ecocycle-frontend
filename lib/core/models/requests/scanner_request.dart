import '../identificador_componente.dart';

class ScannerRequest {
  final IdentificadorComponente identificadorComponente;
  final double confianca;
  final String? segundoIdentificador;
  final double? segundaConfianca;

  const ScannerRequest({
    required this.identificadorComponente,
    required this.confianca,
    this.segundoIdentificador,
    this.segundaConfianca,
  });

  Map<String, dynamic> toJson() => {
    'identificadorComponente': identificadorComponente.valor,
    'confianca': confianca,
    if (segundoIdentificador != null)
      'segundoIdentificador': segundoIdentificador,
    if (segundaConfianca != null) 'segundaConfianca': segundaConfianca,
  };
}
