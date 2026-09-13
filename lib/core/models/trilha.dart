enum TrilhaEnum {
  osQuatroRs('OS_4RS'),
  lixoEletronico('LIXO_ELETRONICO');

  final String valor;
  const TrilhaEnum(this.valor);

  static TrilhaEnum fromValor(String valor) {
    return TrilhaEnum.values.firstWhere(
      (t) => t.valor == valor,
      orElse: () => TrilhaEnum.osQuatroRs,
    );
  }
}

class ConteudoResumo {
  final int id;
  final String codigo;
  final String titulo;
  final int ordem;
  final bool lido;
  final bool quizConcluido;

  const ConteudoResumo({
    required this.id,
    required this.codigo,
    required this.titulo,
    required this.ordem,
    required this.lido,
    required this.quizConcluido,
  });

  factory ConteudoResumo.fromJson(Map<String, dynamic> json) {
    return ConteudoResumo(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      titulo: json['titulo'] as String,
      ordem: json['ordem'] as int,
      lido: json['lido'] as bool,
      quizConcluido: json['quizConcluido'] as bool,
    );
  }
}

class Trilha {
  final TrilhaEnum trilha;
  final String nomeExibicao;
  final List<ConteudoResumo> conteudos;

  const Trilha({
    required this.trilha,
    required this.nomeExibicao,
    required this.conteudos,
  });

  factory Trilha.fromJson(Map<String, dynamic> json) {
    return Trilha(
      trilha: TrilhaEnum.fromValor(json['trilha'] as String),
      nomeExibicao: json['nomeExibicao'] as String,
      conteudos: (json['conteudos'] as List)
          .map((c) => ConteudoResumo.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  int get totalConteudos => conteudos.length;
  int get concluidos => conteudos.where((c) => c.quizConcluido).length;
  double get progresso => conteudos.isEmpty ? 0 : concluidos / totalConteudos;
}
