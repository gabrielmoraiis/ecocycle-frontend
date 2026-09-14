class Alternativa {
  final int id;
  final String letra;
  final String texto;

  const Alternativa({
    required this.id,
    required this.letra,
    required this.texto,
  });

  factory Alternativa.fromJson(Map<String, dynamic> json) {
    return Alternativa(
      id: json['id'] as int,
      letra: json['letra'] as String,
      texto: json['texto'] as String,
    );
  }
}

class Pergunta {
  final int id;
  final String enunciado;
  final int ordem;
  final List<Alternativa> alternativas;

  const Pergunta({
    required this.id,
    required this.enunciado,
    required this.ordem,
    required this.alternativas,
  });

  factory Pergunta.fromJson(Map<String, dynamic> json) {
    return Pergunta(
      id: json['id'] as int,
      enunciado: json['enunciado'] as String,
      ordem: json['ordem'] as int,
      alternativas: (json['alternativas'] as List)
          .map((a) => Alternativa.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Quiz {
  final int id;
  final int conteudoEducativoId;
  final String conteudoTitulo;
  final List<Pergunta> perguntas;

  const Quiz({
    required this.id,
    required this.conteudoEducativoId,
    required this.conteudoTitulo,
    required this.perguntas,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as int,
      conteudoEducativoId: json['conteudoEducativoId'] as int,
      conteudoTitulo: json['conteudoTitulo'] as String,
      perguntas: (json['perguntas'] as List)
          .map((p) => Pergunta.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}
