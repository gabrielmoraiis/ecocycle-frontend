import 'package:flutter/material.dart';

import '../data/figurinha_presentation_catalog.dart';
import '../models/figurinha.dart';
import '../theme/app_colors.dart';

/// Tom escuro da cor da figurinha, usado na etiqueta de raridade e no texto
/// das etiquetas claras (contraste suficiente em qualquer cor do catálogo).
Color corEscuraDaFigurinha(FigurinhaApresentacao apresentacao) =>
    Color.lerp(apresentacao.corIcone, Colors.black, 0.45)!;

/// A figurinha como um card inclinado, "colado no álbum": ícone sobre a cor
/// da figurinha e o nome embaixo. Usado no detalhe e na tela de conquista.
class CartaoFigurinha extends StatelessWidget {
  final Figurinha figurinha;
  final double largura;
  final double sombra;

  const CartaoFigurinha({
    super.key,
    required this.figurinha,
    this.largura = 196,
    this.sombra = 0.18,
  });

  @override
  Widget build(BuildContext context) {
    final apresentacao = apresentacaoDaFigurinha(figurinha.codigo);
    final Color corMoldura = Color.lerp(
      apresentacao.corBadgeFundo,
      apresentacao.corIcone,
      0.35,
    )!;

    return Transform.rotate(
      angle: -0.05,
      child: Container(
        width: largura,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
        decoration: BoxDecoration(
          color: AppColors.fundoBranco,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: corMoldura, width: 2),
          boxShadow: [
            BoxShadow(
              color: corEscuraDaFigurinha(
                apresentacao,
              ).withValues(alpha: sombra),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: largura * 0.77,
              decoration: BoxDecoration(
                color: apresentacao.corFundo,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  apresentacao.icone,
                  color: apresentacao.corIcone,
                  size: largura * 0.39,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              figurinha.nome ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF212121),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Etiquetas de raridade e de origem (Scanner IA ou Quiz) da figurinha.
class EtiquetasFigurinha extends StatelessWidget {
  final Figurinha figurinha;

  const EtiquetasFigurinha({super.key, required this.figurinha});

  @override
  Widget build(BuildContext context) {
    final apresentacao = apresentacaoDaFigurinha(figurinha.codigo);
    final Color corEscura = corEscuraDaFigurinha(apresentacao);
    final bool doScanner = figurinha.tipo == TipoFigurinha.scan;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _Etiqueta(
          texto: apresentacao.raridade,
          corFundo: corEscura,
          corTexto: AppColors.fundoBranco,
        ),
        _Etiqueta(
          texto: doScanner ? 'Scanner IA' : 'Quiz',
          icone: doScanner
              ? Icons.center_focus_strong_outlined
              : Icons.quiz_outlined,
          corFundo: AppColors.fundoBranco,
          corTexto: corEscura,
        ),
      ],
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  final Color corFundo;
  final Color corTexto;
  final IconData? icone;

  const _Etiqueta({
    required this.texto,
    required this.corFundo,
    required this.corTexto,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 14, color: corTexto),
            const SizedBox(width: 6),
          ],
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: icone == null ? 1 : 0,
              color: corTexto,
            ),
          ),
        ],
      ),
    );
  }
}
