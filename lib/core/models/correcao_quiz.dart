/// Correção de uma pergunta: o que a pessoa marcou e qual era a correta.
class CorrecaoPergunta {
  final int perguntaId;
  final int alternativaEscolhidaId;
  final int alternativaCorretaId;
  final bool acertou;

  const CorrecaoPergunta({
    required this.perguntaId,
    required this.alternativaEscolhidaId,
    required this.alternativaCorretaId,
    required this.acertou,
  });

  factory CorrecaoPergunta.fromJson(Map<String, dynamic> json) {
    return CorrecaoPergunta(
      perguntaId: json['perguntaId'] as int,
      alternativaEscolhidaId: json['alternativaEscolhidaId'] as int,
      alternativaCorretaId: json['alternativaCorretaId'] as int,
      acertou: json['acertou'] as bool,
    );
  }

  /// Lê a lista `correcao` da API; ausente (backend antigo) vira lista vazia.
  static List<CorrecaoPergunta> listaDoJson(Object? json) {
    if (json is! List) return const [];
    return json
        .map((c) => CorrecaoPergunta.fromJson(c as Map<String, dynamic>))
        .toList();
  }
}

/// Correção da última tentativa (GET /quizzes/{id}/correcao).
class CorrecaoQuiz {
  final int acertos;
  final int totalPerguntas;
  final List<CorrecaoPergunta> perguntas;

  const CorrecaoQuiz({
    required this.acertos,
    required this.totalPerguntas,
    required this.perguntas,
  });

  factory CorrecaoQuiz.fromJson(Map<String, dynamic> json) {
    return CorrecaoQuiz(
      acertos: json['acertos'] as int,
      totalPerguntas: json['totalPerguntas'] as int,
      perguntas: CorrecaoPergunta.listaDoJson(json['correcao']),
    );
  }
}
