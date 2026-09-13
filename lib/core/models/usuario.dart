enum Avatar {
  avatar01('AVATAR_01'),
  avatar02('AVATAR_02'),
  avatar03('AVATAR_03'),
  avatar04('AVATAR_04'),
  avatar05('AVATAR_05'),
  avatar06('AVATAR_06'),
  avatar07('AVATAR_07'),
  avatar08('AVATAR_08'),
  avatar09('AVATAR_09'),
  avatar10('AVATAR_10');

  final String valor;
  const Avatar(this.valor);

  static Avatar fromValor(String valor) {
    return Avatar.values.firstWhere(
      (a) => a.valor == valor,
      orElse: () => Avatar.avatar01,
    );
  }
}

class Usuario {
  final int id;
  final String email;
  final String apelido;
  final Avatar avatar;
  final DateTime criadoEm;

  const Usuario({
    required this.id,
    required this.email,
    required this.apelido,
    required this.avatar,
    required this.criadoEm,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      email: json['email'] as String,
      apelido: json['apelido'] as String,
      avatar: Avatar.fromValor(json['avatar'] as String),
      criadoEm: DateTime.parse(json['criadoEm'] as String),
    );
  }
}
