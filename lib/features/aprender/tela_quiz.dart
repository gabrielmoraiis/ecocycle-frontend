import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/quiz.dart';
import '../../core/models/requests/submeter_quiz_request.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/figurinhas_provider.dart';
import '../../core/providers/progresso_provider.dart';
import '../../core/services/quiz_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_indicator.dart';
import '../album/tela_album.dart';
import '../mapa/tela_mapa.dart';
import '../scanner/tela_scanner.dart';
import 'cabecalho_modulo.dart';
import 'tela_aprender.dart';
import 'tela_conquista.dart';

class TelaQuizModulo extends StatefulWidget {
  final String rotuloTrilha;
  final String tituloQuiz;
  final int quizId;

  const TelaQuizModulo({
    super.key,
    required this.rotuloTrilha,
    required this.tituloQuiz,
    required this.quizId,
  });

  @override
  State<TelaQuizModulo> createState() => _TelaQuizModuloState();
}

class _TelaQuizModuloState extends State<TelaQuizModulo> {
  final int _abaSelecionada = 1; // Aprender selecionado por padrão

  late final QuizService _quizService;
  bool _carregando = true;
  bool _enviando = false;
  ApiException? _erro;
  Quiz? _quiz;

  int _indicePergunta = 0;
  int? _alternativaSelecionada;
  final Map<int, int> _respostas = {}; // perguntaId -> alternativaId

  @override
  void initState() {
    super.initState();
    _quizService = QuizService(context.read());
    _carregarQuiz();
  }

  Future<void> _carregarQuiz() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final quiz = await _quizService.buscarPorId(widget.quizId);
      setState(() => _quiz = quiz);
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
                      ? ErrorState(message: _erro!.message, onRetry: _carregarQuiz)
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CabecalhoModulo(
                                rotuloTrilha: widget.rotuloTrilha,
                                titulo: widget.tituloQuiz,
                                numeroAtual: _indicePergunta + 1,
                                total: _quiz!.perguntas.length,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                                child: _construirPergunta(),
                              ),
                            ],
                          ),
                        ),
            ),

            // --- BOTÃO FIXO: PRÓXIMA PERGUNTA / CONCLUIR ---
            if (_quiz != null)
              Container(
                width: double.infinity,
                color: AppColors.fundoBranco,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_alternativaSelecionada == null || _enviando) ? null : _avancar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verdeGradienteInicio,
                      foregroundColor: AppColors.fundoBranco,
                      disabledBackgroundColor: AppColors.bordaVerdeClara,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _enviando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.fundoBranco),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _indicePergunta == _quiz!.perguntas.length - 1
                                    ? 'Concluir quiz'
                                    : 'Próxima pergunta',
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

  void _selecionarResposta(int alternativaId) {
    setState(() => _alternativaSelecionada = alternativaId);
  }

  Future<void> _avancar() async {
    final pergunta = _quiz!.perguntas[_indicePergunta];
    _respostas[pergunta.id] = _alternativaSelecionada!;

    if (_indicePergunta == _quiz!.perguntas.length - 1) {
      await _submeter();
    } else {
      setState(() {
        _indicePergunta++;
        _alternativaSelecionada = null;
      });
    }
  }

  Future<void> _submeter() async {
    setState(() => _enviando = true);
    try {
      final respostas = _respostas.entries
          .map((e) => RespostaQuiz(perguntaId: e.key, alternativaId: e.value))
          .toList();
      final resultado = await _quizService.submeter(widget.quizId, respostas);

      if (!mounted) return;
      context.read<FigurinhasProvider>().recarregar();
      context.read<ProgressoProvider>().recarregar();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TelaConquista(resultado: resultado)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Widget _construirPergunta() {
    final Pergunta pergunta = _quiz!.perguntas[_indicePergunta];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pergunta.enunciado,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textoEscuro,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 20),
        for (int i = 0; i < pergunta.alternativas.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _construirOpcao(pergunta.alternativas[i])),
                  const SizedBox(width: 12),
                  Expanded(
                    child: i + 1 < pergunta.alternativas.length
                        ? _construirOpcao(pergunta.alternativas[i + 1])
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _construirOpcao(Alternativa alternativa) {
    final bool ehSelecionada = alternativa.id == _alternativaSelecionada;

    final Color corFundo = ehSelecionada ? AppColors.verdeClaroFundo : AppColors.fundoBranco;
    final Color corBorda = ehSelecionada ? AppColors.verdeGradienteInicio : AppColors.bordaVerdeClara;
    final Color corTexto = ehSelecionada ? AppColors.verdeEscuroTexto : AppColors.textoEscuro;

    return GestureDetector(
      onTap: () => _selecionarResposta(alternativa.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: corFundo,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: corBorda, width: ehSelecionada ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (ehSelecionada) ...[
              Icon(Icons.check_circle, color: corTexto, size: 18),
              const SizedBox(height: 6),
            ],
            Text(
              alternativa.texto,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: corTexto),
            ),
          ],
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
