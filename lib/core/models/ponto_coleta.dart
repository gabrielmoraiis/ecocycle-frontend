class PontoColeta {
  final int id;
  final String nome;
  final String endereco;
  final double latitude;
  final double longitude;
  final List<String> tiposResiduoAceitos;
  final String horarioFuncionamento;
  final double? distanciaKm;

  const PontoColeta({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.latitude,
    required this.longitude,
    required this.tiposResiduoAceitos,
    required this.horarioFuncionamento,
    this.distanciaKm,
  });

  factory PontoColeta.fromJson(Map<String, dynamic> json) {
    return PontoColeta(
      id: json['id'] as int,
      nome: json['nome'] as String,
      endereco: json['endereco'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      tiposResiduoAceitos: (json['tiposResiduoAceitos'] as List)
          .map((e) => e.toString())
          .toList(),
      horarioFuncionamento: json['horarioFuncionamento'] as String,
      distanciaKm: (json['distanciaKm'] as num?)?.toDouble(),
    );
  }
}
