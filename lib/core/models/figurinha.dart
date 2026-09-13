enum TipoFigurinha {
  quiz('QUIZ'),
  scan('SCAN');

  final String valor;
  const TipoFigurinha(this.valor);

  static TipoFigurinha fromValor(String valor) {
    return TipoFigurinha.values.firstWhere(
      (t) => t.valor == valor,
      orElse: () => TipoFigurinha.quiz,
    );
  }
}

class Figurinha {
  final int id;
  final String codigo;
  final TipoFigurinha tipo;
  final int ordem;
  final bool desbloqueada;
  final String? nome;
  final String? descricao;

  const Figurinha({
    required this.id,
    required this.codigo,
    required this.tipo,
    required this.ordem,
    required this.desbloqueada,
    this.nome,
    this.descricao,
  });

  factory Figurinha.fromJson(Map<String, dynamic> json) {
    return Figurinha(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      tipo: TipoFigurinha.fromValor(json['tipo'] as String),
      ordem: json['ordem'] as int,
      desbloqueada: json['desbloqueada'] as bool,
      nome: json['nome'] as String?,
      descricao: json['descricao'] as String?,
    );
  }
}
