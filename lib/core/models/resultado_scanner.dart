import 'figurinha.dart';

class ResultadoScanner {
  final bool reconhecido;
  final String identificadorComponente;
  final double confianca;
  final bool novaDesbloqueada;
  final Figurinha? figurinha;
  final String mensagem;

  const ResultadoScanner({
    required this.reconhecido,
    required this.identificadorComponente,
    required this.confianca,
    required this.novaDesbloqueada,
    this.figurinha,
    required this.mensagem,
  });

  factory ResultadoScanner.fromJson(Map<String, dynamic> json) {
    final figurinhaJson = json['figurinha'] as Map<String, dynamic>?;
    return ResultadoScanner(
      reconhecido: json['reconhecido'] as bool,
      identificadorComponente: json['identificadorComponente'] as String,
      confianca: (json['confianca'] as num).toDouble(),
      novaDesbloqueada: json['novaDesbloqueada'] as bool,
      figurinha: figurinhaJson == null
          ? null
          : Figurinha.fromJson(figurinhaJson),
      mensagem: json['mensagem'] as String,
    );
  }
}
