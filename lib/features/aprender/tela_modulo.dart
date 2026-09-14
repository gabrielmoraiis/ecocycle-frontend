import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:provider/provider.dart';

import '../../core/models/conteudo_educativo.dart';
import '../../core/services/trilha_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/async_builder.dart';
import '../../core/widgets/eco_bottom_nav_bar.dart';
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
      backgroundColor: AppColors.verdeClaroFundo,
      body: SafeArea(
        child: Column(
          children: [
            // --- TOPO: VOLTAR + TÍTULO ---
            Container(
              color: AppColors.fundoBranco,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.verdeClaroFundo,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: AppColors.verdeGradienteInicio,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  const Text(
                    'Aprender',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.verdeGradienteInicio,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: AsyncBuilder<ConteudoEducativo>(
                carregar: _carregarConteudo,
                builder: (context, conteudo, recarregar) => Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- CABEÇALHO DO MÓDULO (HERO) ---
                            CabecalhoModulo(
                              rotuloTrilha: widget.rotuloTrilha,
                              titulo: widget.tituloModulo,
                              numeroAtual: widget.numeroModulo,
                              total: widget.totalModulos,
                            ),

                            // --- CONTEÚDO (MARKDOWN) ---
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                              child: _construirCartaoConteudo(conteudo),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- BOTÃO FIXO: PRONTO! JOGAR O MINI-GAME ---
                    Container(
                      width: double.infinity,
                      color: AppColors.fundoBranco,
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (conteudo.quizId == null)
                              ? null
                              : () => _abrirQuiz(context, conteudo),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.verdeGradienteInicio,
                            foregroundColor: AppColors.fundoBranco,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.textoBotao,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // --- BARRA DE NAVEGAÇÃO INFERIOR ---
      bottomNavigationBar: const EcoBottomNavBar(tabAtual: EcoTab.aprender),
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

  Widget _construirCartaoConteudo(ConteudoEducativo conteudo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.fundoBranco,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bordaVerdeClara),
      ),
      child: MarkdownBody(
        data: conteudo.corpo,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(
            fontSize: 14,
            color: AppColors.textoCinzaClaro,
            height: 1.4,
          ),
          h1: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textoEscuro,
          ),
          h2: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textoEscuro,
          ),
          h3: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textoEscuro,
          ),
          strong: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.verdeEscuroTexto,
          ),
          listBullet: const TextStyle(
            fontSize: 14,
            color: AppColors.textoCinzaClaro,
          ),
        ),
      ),
    );
  }
}
