import 'package:flutter/material.dart';

import '../models/usuario.dart';

/// Foto de perfil do usuário: a ilustração do avatar recortada em círculo.
class AvatarUsuario extends StatelessWidget {
  final Avatar avatar;
  final double tamanho;

  const AvatarUsuario({super.key, required this.avatar, required this.tamanho});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        avatar.caminhoImagem,
        width: tamanho,
        height: tamanho,
        fit: BoxFit.cover,
        cacheWidth: (tamanho * MediaQuery.devicePixelRatioOf(context)).round(),
      ),
    );
  }
}
