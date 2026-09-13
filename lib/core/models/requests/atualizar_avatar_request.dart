import '../usuario.dart';

class AtualizarAvatarRequest {
  final Avatar avatar;

  const AtualizarAvatarRequest({required this.avatar});

  Map<String, dynamic> toJson() => {'avatar': avatar.valor};
}
