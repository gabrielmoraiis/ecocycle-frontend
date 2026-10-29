import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'layout_eco.dart';

/// Topo verde das telas de login e cadastro, com o formulário em um cartão
/// que sobe por cima da faixa ([TelaFormularioEco]).
class TelaFormularioEco extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final bool mostrarLogo;
  final Widget formulario;
  final List<Widget> depoisDoFormulario;

  const TelaFormularioEco({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.formulario,
    this.mostrarLogo = false,
    this.depoisDoFormulario = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verdeClaroFundo,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CabecalhoEco(
              titulo: '',
              espacoInferior: 56,
              conteudo: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    if (mostrarLogo) ...[
                      Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.fundoBranco,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Image.asset('assets/logo/simbolo.png'),
                      ),
                      const SizedBox(width: 14),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titulo,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.fundoBranco,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitulo,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              color: AppColors.verdeSobreCabecalho,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // O formulário sobe para dentro da faixa verde.
            Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                      decoration: BoxDecoration(
                        color: AppColors.fundoBranco,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 24,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: formulario,
                    ),
                    ...depoisDoFormulario,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Campo de formulário com rótulo em maiúsculas e fundo verde-claro.
class CampoEco extends StatelessWidget {
  final String rotulo;
  final String dica;
  final IconData icone;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? sufixo;
  final String? ajuda;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const CampoEco({
    super.key,
    required this.rotulo,
    required this.dica,
    required this.icone,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.sufixo,
    this.ajuda,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder borda(Color cor, [double largura = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cor, width: largura),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          rotulo,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: AppColors.textoSecundario,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: const TextStyle(fontSize: 15, color: AppColors.textoTitulo),
          decoration: InputDecoration(
            hintText: dica,
            hintStyle: const TextStyle(color: AppColors.textoCinzaClaro),
            helperText: ajuda,
            helperMaxLines: 2,
            helperStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.textoSecundario,
            ),
            filled: true,
            fillColor: AppColors.verdeClaroFundo,
            prefixIcon: Icon(icone, color: AppColors.verdeCabecalho),
            suffixIcon: sufixo,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: borda(AppColors.bordaVerdeClara),
            focusedBorder: borda(AppColors.verdeGradienteInicio, 2),
            errorBorder: borda(Colors.red.shade300),
            focusedErrorBorder: borda(Colors.red.shade400, 2),
          ),
        ),
      ],
    );
  }
}

/// Botão de mostrar/ocultar a senha, para o [CampoEco.sufixo].
class BotaoVerSenha extends StatelessWidget {
  final bool oculta;
  final VoidCallback onPressed;

  const BotaoVerSenha({
    super.key,
    required this.oculta,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        oculta ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.textoSecundario,
      ),
      tooltip: oculta ? 'Mostrar senha' : 'Ocultar senha',
      onPressed: onPressed,
    );
  }
}

/// Caixa vermelha com a mensagem de erro geral do formulário.
class AvisoErroEco extends StatelessWidget {
  final String mensagem;

  const AvisoErroEco(this.mensagem, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF5B8C0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 20, color: Colors.red.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensagem,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Colors.red.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rodapé "Pergunta? Ação" das telas de login e cadastro.
class RodapeLinkEco extends StatelessWidget {
  final String pergunta;
  final String acao;
  final VoidCallback onTap;

  const RodapeLinkEco({
    super.key,
    required this.pergunta,
    required this.acao,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            pergunta,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textoSecundario,
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.verdeCabecalho,
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
            child: Text(
              acao,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
