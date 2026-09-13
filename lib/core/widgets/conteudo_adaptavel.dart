import 'package:flutter/material.dart';

/// Ajusta o conteúdo para caber inteiro na tela sem precisar de rolagem,
/// encolhendo proporcionalmente quando necessário (nunca aumenta além do
/// tamanho natural). Quando o teclado está aberto, libera a rolagem normal
/// para o campo em edição permanecer visível no tamanho correto.
///
/// Importante: dentro do body de um Scaffold com resizeToAvoidBottomInset
/// (padrão), o Flutter já consome o viewInsets.bottom ao redimensionar o
/// body — MediaQuery.of(context) chamado de dentro deste widget sempre
/// reportaria 0. Por isso [tecladoAberto] deve ser calculado pela tela que
/// usa este widget, ANTES de construir o Scaffold (nesse ponto a árvore
/// ainda não teve o inset consumido, e o MediaQuery.of ali é reativo de
/// verdade a abrir/fechar teclado).
class ConteudoAdaptavel extends StatelessWidget {
  final WidgetBuilder builder;
  final Alignment alignment;
  final bool tecladoAberto;

  const ConteudoAdaptavel({
    super.key,
    required this.builder,
    required this.tecladoAberto,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (tecladoAberto) {
      return SingleChildScrollView(child: builder(context));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: alignment,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignment,
            child: SizedBox(
              width: constraints.maxWidth,
              child: builder(context),
            ),
          ),
        );
      },
    );
  }
}
