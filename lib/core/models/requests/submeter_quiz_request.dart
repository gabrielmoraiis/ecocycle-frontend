class RespostaQuiz {
  final int perguntaId;
  final int alternativaId;

  const RespostaQuiz({required this.perguntaId, required this.alternativaId});

  Map<String, dynamic> toJson() => {
        'perguntaId': perguntaId,
        'alternativaId': alternativaId,
      };
}

class SubmeterQuizRequest {
  final List<RespostaQuiz> respostas;

  const SubmeterQuizRequest({required this.respostas});

  Map<String, dynamic> toJson() => {
        'respostas': respostas.map((r) => r.toJson()).toList(),
      };
}
