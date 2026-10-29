import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:provider/provider.dart';

import '../../core/data/ilustracao_conteudo_catalog.dart';
import '../../core/models/conteudo_educativo.dart';
import '../../core/services/trilha_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/async_builder.dart';
import '../../core/widgets/imagem_conteudo.dart';
import '../../core/widgets/layout_eco.dart';
import 'cabecalho_modulo.dart';
import 'tela_quiz.dart';

class TelaModulo extends StatefulWidget {
  final String rotuloTrilha;
  final String tituloModulo;
  final int numeroModulo;
  final int totalModulos;
  final int conteudoId;
  final String textoBotao;

  const TelaModulo({
    super.key,
    required this.rotuloTrilha,
    required this.tituloModulo,
    required this.numeroModulo,
    required this.totalModulos,
    required this.conteudoId,
    this.textoBotao = 'Pronto! Jogar o mini-game',
  });

  @override
  State<TelaModulo> createState() => _TelaModuloState();
}

class _TelaModuloState extends State<TelaModulo> {
  late final TrilhaService _trilhaService;

  @override
  void initState() {
    super.initState();
    _trilhaService = TrilhaService(context.read());
  }

  Future<ConteudoEducativo> _carregarConteudo() async {
    var conteudo = await _trilhaService.buscarConteudo(widget.conteudoId);
    if (!conteudo.lido) {
      conteudo = await _trilhaService.marcarLido(widget.conteudoId);
    }
    return conteudo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundoBranco,
      body: SafeArea(
        child: Column(
          children: [
            // --- TOPO: VOLTAR + TRILHA + PROGRESSO ---
            CabecalhoModulo(
              rotuloTrilha: widget.rotuloTrilha,
              numeroAtual: widget.numeroModulo,
              total: widget.totalModulos,
            ),

            Expanded(
              child: AsyncBuilder<ConteudoEducativo>(
                carregar: _carregarConteudo,
                builder: (context, conteudo, recarregar) => Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ImagemConteudo(
                              imagemSugerida: ilustracaoDoConteudo(conteudo),
                              raio: 0,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                22,
                                22,
                                22,
                                24,
                              ),
                              child: _construirArtigo(conteudo),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- BOTÃO FIXO: PRONTO! JOGAR O MINI-GAME ---
                    _construirRodape(conteudo),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES PARA NÃO REPETIR CÓDIGO ---

  void _abrirQuiz(BuildContext context, ConteudoEducativo conteudo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaQuizModulo(
          rotuloTrilha: widget.rotuloTrilha,
          tituloQuiz: 'Quiz: ${widget.tituloModulo}',
          quizId: conteudo.quizId!,
        ),
      ),
    );
  }

  /// Minutos de leitura estimados a ~200 palavras por minuto.
  int _minutosDeLeitura(String texto) {
    final palavras = texto.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return (palavras.length / 200).ceil().clamp(1, 60);
  }

  Widget _construirArtigo(ConteudoEducativo conteudo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _construirEtiqueta(
              'Leitura · ~${_minutosDeLeitura(conteudo.corpo)} min',
              AppColors.verdeSobreCabecalho,
              AppColors.verdeEscuro,
            ),
            if (conteudo.quizId != null)
              _construirEtiqueta(
                conteudo.quizConcluido
                    ? 'Figurinha já ganha'
                    : 'Vale 1 figurinha',
                AppColors.laranjaFundo,
                AppColors.laranjaTexto,
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          widget.tituloModulo,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1.15,
            color: AppColors.textoTitulo,
          ),
        ),
        const SizedBox(height: 14),
        _construirMarkdown(conteudo),
      ],
    );
  }

  Widget _construirEtiqueta(String texto, Color fundo, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cor),
      ),
    );
  }

  Widget _construirMarkdown(ConteudoEducativo conteudo) {
    const corpo = TextStyle(
      fontSize: 17,
      color: Color(0xFF424242),
      height: 1.6,
    );
    return MarkdownBody(
      data: conteudo.corpo,
      imageBuilder: (uri, _, _) => ImagemConteudo(
        imagemSugerida: uri.toString(),
        margem: const EdgeInsets.symmetric(vertical: 8),
      ),
      styleSheet: MarkdownStyleSheet(
        p: corpo,
        pPadding: const EdgeInsets.only(bottom: 6),
        h1: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: AppColors.textoTitulo,
        ),
        h2: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: AppColors.textoTitulo,
        ),
        h2Padding: const EdgeInsets.only(top: 10),
        h3: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textoTitulo,
        ),
        h3Padding: const EdgeInsets.only(top: 8),
        strong: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.verdeEscuro,
        ),
        listBullet: corpo,
        blockquote: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Color(0xFF2E5E30),
        ),
        blockquoteDecoration: BoxDecoration(
          color: AppColors.verdeClaroFundo,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.bordaVerdeClara),
        ),
        blockquotePadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _construirRodape(ConteudoEducativo conteudo) {
    final bool temQuiz = conteudo.quizId != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.fundoBranco,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: temQuiz ? () => _abrirQuiz(context, conteudo) : null,
            icon: const Icon(Icons.sports_esports_outlined, size: 20),
            label: Text(widget.textoBotao),
            style: BotoesEco.principal(),
          ),
          if (temQuiz) ...[
            const SizedBox(height: 8),
            Text(
              conteudo.quizConcluido
                  ? 'Já concluído: acerte mais que da última vez para ganhar XP'
                  : 'Cada pergunta certa vale XP · concluir libera a figurinha',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textoSecundario,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
