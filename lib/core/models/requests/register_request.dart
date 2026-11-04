import '../../config/termos_config.dart';

class RegisterRequest {
  final String email;
  final String apelido;
  final String senha;

  /// Aceite dos Termos de Uso e da Política de Privacidade (o backend
  /// registra a data e a versão para comprovar o consentimento).
  final bool aceitouTermos;
  final String versaoTermos;

  const RegisterRequest({
    required this.email,
    required this.apelido,
    required this.senha,
    required this.aceitouTermos,
    this.versaoTermos = TermosConfig.versao,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'apelido': apelido,
    'senha': senha,
    'aceitouTermos': aceitouTermos,
    'versaoTermos': versaoTermos,
  };
}
