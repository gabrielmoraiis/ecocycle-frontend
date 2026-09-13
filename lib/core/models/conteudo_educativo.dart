import 'trilha.dart';

class ConteudoEducativo {
  final int id;
  final String codigo;
  final TrilhaEnum trilha;
  final String titulo;
  final String corpo;
  final int ordem;
  final String? imagemSugerida;
  final bool lido;
  final bool quizConcluido;
  final int? quizId;

  const ConteudoEducativo({
    required this.id,
    required this.codigo,
    required this.trilha,
    required this.titulo,
    required this.corpo,
    required this.ordem,
    this.imagemSugerida,
    required this.lido,
    required this.quizConcluido,
    this.quizId,
  });

  factory ConteudoEducativo.fromJson(Map<String, dynamic> json) {
    return ConteudoEducativo(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      trilha: TrilhaEnum.fromValor(json['trilha'] as String),
      titulo: json['titulo'] as String,
      corpo: json['corpo'] as String,
      ordem: json['ordem'] as int,
      imagemSugerida: json['imagemSugerida'] as String?,
      lido: json['lido'] as bool,
      quizConcluido: json['quizConcluido'] as bool,
      quizId: json['quizId'] as int?,
    );
  }
}
