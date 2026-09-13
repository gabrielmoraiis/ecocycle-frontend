import 'usuario.dart';

class AuthResult {
  final String token;
  final String tokenType;
  final int expiresInMs;
  final Usuario usuario;

  const AuthResult({
    required this.token,
    required this.tokenType,
    required this.expiresInMs,
    required this.usuario,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token'] as String,
      tokenType: json['tokenType'] as String,
      expiresInMs: (json['expiresInMs'] as num).toInt(),
      usuario: Usuario.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
