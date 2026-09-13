class Progresso {
  final int xpTotal;
  final int conteudosLidos;
  final int quizzesConcluidos;
  final int figurinhasDesbloqueadas;
  final int totalFigurinhas;

  const Progresso({
    required this.xpTotal,
    required this.conteudosLidos,
    required this.quizzesConcluidos,
    required this.figurinhasDesbloqueadas,
    required this.totalFigurinhas,
  });

  factory Progresso.fromJson(Map<String, dynamic> json) {
    return Progresso(
      xpTotal: json['xpTotal'] as int,
      conteudosLidos: json['conteudosLidos'] as int,
      quizzesConcluidos: json['quizzesConcluidos'] as int,
      figurinhasDesbloqueadas: json['figurinhasDesbloqueadas'] as int,
      totalFigurinhas: json['totalFigurinhas'] as int,
    );
  }
}
