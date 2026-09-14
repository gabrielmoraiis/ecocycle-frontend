import 'figurinha.dart';

class ResultadoSubmissao {
  final int acertos;
  final int totalPerguntas;
  final bool primeiraConclusao;
  final int xpGanho;
  final int xpTotalAtual;
  final Figurinha? figurinhaDesbloqueada;

  const ResultadoSubmissao({
    required this.acertos,
    required this.totalPerguntas,
    required this.primeiraConclusao,
    required this.xpGanho,
    required this.xpTotalAtual,
    this.figurinhaDesbloqueada,
  });

  factory ResultadoSubmissao.fromJson(Map<String, dynamic> json) {
    final figurinhaJson =
        json['figurinhaDesbloqueada'] as Map<String, dynamic>?;
    return ResultadoSubmissao(
      acertos: json['acertos'] as int,
      totalPerguntas: json['totalPerguntas'] as int,
      primeiraConclusao: json['primeiraConclusao'] as bool,
      xpGanho: json['xpGanho'] as int,
      xpTotalAtual: json['xpTotalAtual'] as int,
      figurinhaDesbloqueada: figurinhaJson == null
          ? null
          : Figurinha.fromJson(figurinhaJson),
    );
  }
}
