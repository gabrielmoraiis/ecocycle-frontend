import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/quiz.dart';
import '../../core/models/requests/submeter_quiz_request.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/figurinhas_provider.dart';
import '../../core/providers/progresso_provider.dart';
import '../../core/services/quiz_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/async_builder.dart';
import '../../core/widgets/layout_eco.dart';
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
  late final QuizService _quizService;
  bool _enviando = false;

  int _indicePergunta = 0;
  int? _alternativaSelecionada;
  final Map<int, int> _respostas = {}; // perguntaId -> alternativaId

  @override
  void initState() {
    super.initState();
    _quizService = QuizService(context.read());
  }

  bool get _temProgresso =>
      _indicePergunta > 0 || _alternativaSelecionada != null;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_temProgresso,
      onPopInvokedWithResult: (saiu, _) {
        if (!saiu) _confirmarSaida();
      },
      child: Scaffold(
        backgroundColor: AppColors.verdeClaroFundo,
        body: SafeArea(
          child: AsyncBuilder<Quiz>(
            carregar: () => _quizService.buscarPorId(widget.quizId),
            builder: (context, quiz, recarregar) => Column(
              children: [
                _construirTopo(quiz),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: _construirPergunta(quiz),
                  ),
                ),

                // --- BOTÃO FIXO: PRÓXIMA PERGUNTA / CONCLUIR ---
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(
                    color: AppColors.fundoBranco,
                    border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                  ),
                  child: ElevatedButton(
                    onPressed: (_alternativaSelecionada == null || _enviando)
                        ? null
                        : () => _avancar(quiz),
                    style: BotoesEco.principal(),
                    child: _enviando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.fundoBranco,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _indicePergunta == quiz.perguntas.length - 1
                                    ? 'Concluir quiz'
                                    : 'Próxima pergunta',
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right, size: 20),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES PARA NÃO REPETIR CÓDIGO ---

  /// Sair no meio do quiz perde as respostas: pede confirmação antes.
  Future<void> _confirmarSaida() async {
    final sair = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do quiz?'),
        content: const Text(
          'Suas respostas não serão salvas e você terá que começar de novo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuar quiz'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (sair == true && mounted) Navigator.pop(context);
  }

  Widget _construirTopo(Quiz quiz) {
    final int total = quiz.perguntas.length;
    return Container(
      color: AppColors.fundoBranco,
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          Material(
            color: AppColors.verdeClaroFundo,
            shape: const CircleBorder(),
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: AppColors.verdeGradienteInicio,
              ),
              tooltip: 'Sair do quiz',
              onPressed: () =>
                  _temProgresso ? _confirmarSaida() : Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: BarraProgressoEco(
              valor: total == 0 ? 0 : (_indicePergunta + 1) / total,
              altura: 12,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_indicePergunta + 1}/$total',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.verdeEscuro,
            ),
          ),
        ],
      ),
    );
  }

  void _selecionarResposta(int alternativaId) {
    setState(() => _alternativaSelecionada = alternativaId);
  }

  Future<void> _avancar(Quiz quiz) async {
    final pergunta = quiz.perguntas[_indicePergunta];
    _respostas[pergunta.id] = _alternativaSelecionada!;

    if (_indicePergunta == quiz.perguntas.length - 1) {
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
        MaterialPageRoute(
          builder: (context) => TelaConquista(resultado: resultado),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Widget _construirPergunta(Quiz quiz) {
    final Pergunta pergunta = quiz.perguntas[_indicePergunta];
    final String assunto = widget.tituloQuiz.replaceFirst('Quiz: ', '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'QUIZ · ${assunto.toUpperCase()}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: AppColors.textoSecundario,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          pergunta.enunciado,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1.3,
            color: AppColors.textoTitulo,
          ),
        ),
        const SizedBox(height: 20),
        for (final alternativa in pergunta.alternativas) ...[
          _construirOpcao(alternativa),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _construirOpcao(Alternativa alternativa) {
    final bool selecionada = alternativa.id == _alternativaSelecionada;

    return Semantics(
      selected: selecionada,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: selecionada
            ? AppColors.verdeSobreCabecalho
            : AppColors.fundoBranco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selecionada
                ? AppColors.verdeGradienteInicio
                : const Color(0xFFE0E0E0),
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _selecionarResposta(alternativa.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selecionada
                        ? AppColors.verdeGradienteInicio
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    alternativa.letra.toUpperCase(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: selecionada
                          ? AppColors.fundoBranco
                          : AppColors.textoSecundario,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    alternativa.texto,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.35,
                      fontWeight: selecionada
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: selecionada
                          ? AppColors.verdeEscuro
                          : AppColors.textoTitulo,
                    ),
                  ),
                ),
                if (selecionada) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.verdeGradienteInicio,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
