import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Faixa verde do topo das telas: botão de voltar, título e um conteúdo
/// opcional embaixo. [espacoInferior] deixa sobra para um cartão que sobe
/// por cima da faixa (Transform.translate na tela que usa).
class CabecalhoEco extends StatelessWidget {
  final String titulo;
  final Widget? conteudo;
  final double espacoInferior;
  final bool mostrarVoltar;
  final Widget? acao;

  const CabecalhoEco({
    super.key,
    required this.titulo,
    this.conteudo,
    this.espacoInferior = 24,
    this.mostrarVoltar = true,
    this.acao,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        color: AppColors.verdeCabecalho,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, espacoInferior),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (mostrarVoltar) ...[
                      BotaoCircularEco(
                        icone: Icons.chevron_left,
                        tooltip: 'Voltar',
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.fundoBranco,
                        ),
                      ),
                    ),
                    ?acao,
                  ],
                ),
                if (conteudo != null) ...[
                  const SizedBox(height: 16),
                  conteudo!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão redondo translúcido usado sobre fundos verdes ou escuros.
class BotaoCircularEco extends StatelessWidget {
  final IconData icone;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color corFundo;
  final Color corIcone;

  const BotaoCircularEco({
    super.key,
    required this.icone,
    required this.tooltip,
    required this.onPressed,
    this.corFundo = const Color(0x29FFFFFF),
    this.corIcone = AppColors.fundoBranco,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: corFundo,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icone, color: corIcone),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}

/// Rótulo de seção em maiúsculas ("SEU AVATAR", "CONTINUE APRENDENDO").
class TituloSecaoEco extends StatelessWidget {
  final String texto;
  final Widget? acao;

  const TituloSecaoEco(this.texto, {super.key, this.acao});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: AppColors.textoSecundario,
              ),
            ),
          ),
          ?acao,
        ],
      ),
    );
  }
}

/// Cartão branco de borda verde-clara, com toque opcional.
class CartaoEco extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color cor;
  final Color corBorda;

  const CartaoEco({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.cor = AppColors.fundoBranco,
    this.corBorda = AppColors.bordaVerdeClara,
  });

  @override
  Widget build(BuildContext context) {
    final borda = BorderRadius.circular(20);
    return Material(
      color: cor,
      shape: RoundedRectangleBorder(
        borderRadius: borda,
        side: BorderSide(color: corBorda),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Ícone dentro de um quadrado arredondado colorido.
class IconeQuadradoEco extends StatelessWidget {
  final IconData icone;
  final Color cor;
  final Color corFundo;
  final double tamanho;

  const IconeQuadradoEco({
    super.key,
    required this.icone,
    required this.cor,
    required this.corFundo,
    this.tamanho = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(tamanho * 0.32),
      ),
      child: Icon(icone, color: cor, size: tamanho * 0.5),
    );
  }
}

/// Barra de progresso arredondada.
class BarraProgressoEco extends StatelessWidget {
  final double valor;
  final double altura;
  final Color cor;
  final Color corFundo;

  const BarraProgressoEco({
    super.key,
    required this.valor,
    this.altura = 8,
    this.cor = AppColors.verdeGradienteInicio,
    this.corFundo = AppColors.verdeSobreCabecalho,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(altura / 2),
      child: LinearProgressIndicator(
        value: valor.clamp(0, 1),
        minHeight: altura,
        backgroundColor: corFundo,
        valueColor: AlwaysStoppedAnimation<Color>(cor),
      ),
    );
  }
}

/// Estilos de botão do layout novo: principal verde cheio e secundário
/// contornado.
abstract class BotoesEco {
  static ButtonStyle principal({double altura = 54}) =>
      ElevatedButton.styleFrom(
        backgroundColor: AppColors.verdeGradienteInicio,
        foregroundColor: AppColors.fundoBranco,
        disabledBackgroundColor: AppColors.bordaVerdeClara,
        minimumSize: Size.fromHeight(altura),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );

  static ButtonStyle secundario({double altura = 50}) =>
      OutlinedButton.styleFrom(
        foregroundColor: AppColors.verdeEscuro,
        minimumSize: Size.fromHeight(altura),
        side: const BorderSide(color: AppColors.bordaVerdeClara),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );
}
