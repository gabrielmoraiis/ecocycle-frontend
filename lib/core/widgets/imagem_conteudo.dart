import 'package:flutter/material.dart';

/// Ilustração de um conteúdo educativo a partir do `imagemSugerida` do
/// backend: URL (http/https) → rede; nome de arquivo/slug → asset em
/// `assets/conteudos/`. Valor ausente, ou imagem que não carregue, não ocupa
/// espaço nenhum (nem a [margem]).
class ImagemConteudo extends StatelessWidget {
  final String? imagemSugerida;
  final EdgeInsets margem;

  const ImagemConteudo({
    super.key,
    required this.imagemSugerida,
    this.margem = EdgeInsets.zero,
  });

  static String? _caminhoAsset(String valor) {
    if (valor.isEmpty || valor.contains(' ')) return null;
    final temExtensao = RegExp(r'\.(png|jpe?g|webp)$').hasMatch(valor);
    return 'assets/conteudos/${temExtensao ? valor : '$valor.png'}';
  }

  @override
  Widget build(BuildContext context) {
    final valor = imagemSugerida?.trim() ?? '';

    final ImageProvider? provider;
    if (valor.startsWith('http://') || valor.startsWith('https://')) {
      provider = NetworkImage(valor);
    } else if (_caminhoAsset(valor) case final caminho?) {
      provider = AssetImage(caminho);
    } else {
      provider = null;
    }
    if (provider == null) return const SizedBox.shrink();

    // Em caso de erro o Image devolve direto o errorBuilder, sem passar pelo
    // frameBuilder: por isso a margem e o recorte ficam no frameBuilder.
    return Image(
      image: provider,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
      frameBuilder: (context, child, frame, sincrono) => Padding(
        padding: margem,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          // Mesma proporção das ilustrações (16:9): aparece inteira em
          // qualquer largura de tela, sem cortar as laterais.
          child: AspectRatio(aspectRatio: 16 / 9, child: child),
        ),
      ),
    );
  }
}
