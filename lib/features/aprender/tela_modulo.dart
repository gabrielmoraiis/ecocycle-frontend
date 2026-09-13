import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import '../../core/models/conteudo_educativo.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/trilha_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_indicator.dart';
import '../album/tela_album.dart';
import '../mapa/tela_mapa.dart';
import '../scanner/tela_scanner.dart';
import 'cabecalho_modulo.dart';
import 'tela_aprender.dart';
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
  final int _abaSelecionada = 1; // Aprender selecionado por padrão

  late final TrilhaService _trilhaService;
  bool _carregando = true;
  ApiException? _erro;
  ConteudoEducativo? _conteudo;

  @override
  void initState() {
    super.initState();
    _trilhaService = TrilhaService(context.read());
    _carregarConteudo();
  }

  Future<void> _carregarConteudo() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      var conteudo = await _trilhaService.buscarConteudo(widget.conteudoId);
      if (!conteudo.lido) {
        conteudo = await _trilhaService.marcarLido(widget.conteudoId);
      }
      setState(() => _conteudo = conteudo);
    } on ApiException catch (e) {
      setState(() => _erro = e);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
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
                        icon: const Icon(Icons.chevron_left, color: AppColors.verdeGradienteInicio),
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
              child: _carregando
                  ? const LoadingIndicator()
                  : _erro != null
                      ? ErrorState(message: _erro!.message, onRetry: _carregarConteudo)
                      : SingleChildScrollView(
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
                                child: _construirCartaoConteudo(_conteudo!),
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
                  onPressed: (_conteudo?.quizId == null) ? null : () => _abrirQuiz(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdeGradienteInicio,
                    foregroundColor: AppColors.fundoBranco,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.textoBotao,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

      // --- BARRA DE NAVEGAÇÃO INFERIOR ---
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.fundoBranco,
            border: Border(top: BorderSide(color: AppColors.bordaCinza, width: 1.0)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _construirItemNavegacao(0, Icons.location_on_outlined, 'Mapa'),
              _construirItemNavegacao(1, Icons.menu_book_outlined, 'Aprender'),
              _construirItemNavegacao(2, Icons.home_outlined, 'Início'),
              _construirItemNavegacao(3, Icons.camera_alt_outlined, 'Scanner'),
              _construirItemNavegacao(4, Icons.check_circle_outline, 'Álbum'),
            ],
          ),
        ),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES PARA NÃO REPETIR CÓDIGO ---

  void _abrirQuiz(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaQuizModulo(
          rotuloTrilha: widget.rotuloTrilha,
          tituloQuiz: 'Quiz: ${widget.tituloModulo}',
          quizId: _conteudo!.quizId!,
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
          p: const TextStyle(fontSize: 14, color: AppColors.textoCinzaClaro, height: 1.4),
          h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textoEscuro),
          h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textoEscuro),
          h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textoEscuro),
          strong: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.verdeEscuroTexto),
          listBullet: const TextStyle(fontSize: 14, color: AppColors.textoCinzaClaro),
        ),
      ),
    );
  }

  void _abrirAlbum(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaAlbum()),
    );
  }

  Widget _construirItemNavegacao(int indice, IconData icone, String rotulo) {
    final bool selecionado = _abaSelecionada == indice;
    final Color cor = selecionado ? AppColors.verdeGradienteInicio : AppColors.textoCinzaClaro;

    return GestureDetector(
      onTap: () {
        if (indice == _abaSelecionada) return;
        if (indice == 2) {
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (indice == 4) {
          _abrirAlbum(context);
        } else if (indice == 0) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaMapa()));
        } else if (indice == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaScanner()));
        } else if (indice == 1) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const TelaAprender()),
            (route) => route.isFirst,
          );
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: cor, size: 24),
          const SizedBox(height: 4),
          Text(rotulo, style: TextStyle(fontSize: 11, color: cor, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: selecionado ? AppColors.verdeGradienteInicio : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
