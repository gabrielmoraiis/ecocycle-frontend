class RegisterRequest {
  final String email;
  final String apelido;
  final String senha;

  const RegisterRequest({
    required this.email,
    required this.apelido,
    required this.senha,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'apelido': apelido,
    'senha': senha,
  };
}
