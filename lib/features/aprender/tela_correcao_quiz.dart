import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/correcao_quiz.dart';
import '../../core/models/quiz.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/quiz_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/async_builder.dart';
import '../../core/widgets/layout_eco.dart';
import 'tela_quiz.dart';

const Color _vermelho = Color(0xFFC62828);
const Color _vermelhoFundo = Color(0xFFFFEBEE);

/// Correção do quiz: cada pergunta com a alternativa que a pessoa marcou e a
/// correta. Recebe a correção pronta (logo após enviar o quiz) ou busca a da
/// última tentativa na API (quando a pessoa volta depois).
class TelaCorrecaoQuiz extends StatelessWidget {
  final int quizId;
  final String tituloQuiz;
  final List<CorrecaoPergunta>? correcao;
  final String rotuloTrilha;

  const TelaCorrecaoQuiz({
    super.key,
    required this.quizId,
    required this.tituloQuiz,
    this.correcao,
    this.rotuloTrilha = '',
  });

  Future<(Quiz, List<CorrecaoPergunta>?)> _carregar(QuizService service) async {
    final quiz = await service.buscarPorId(quizId);
    final pronta = correcao;
    if (pronta != null && pronta.isNotEmpty) return (quiz, pronta);
    try {
      final ultima = await service.buscarCorrecao(quizId);
      return (quiz, ultima.perguntas.isEmpty ? null : ultima.perguntas);
    } on ApiException catch (e) {
      // 404: ainda não respondeu, ou respondeu antes de as respostas serem
      // guardadas. Mostra um aviso em vez de erro.
      if (e.isNaoEncontrado) return (quiz, null);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = QuizService(context.read());
    return Scaffold(
      backgroundColor: AppColors.verdeClaroFundo,
      appBar: AppBar(
        title: const Text('Correção do quiz'),
        backgroundColor: AppColors.fundoBranco,
        foregroundColor: AppColors.textoTitulo,
        elevation: 0,
      ),
      body: SafeArea(
        child: AsyncBuilder<(Quiz, List<CorrecaoPergunta>?)>(
          carregar: () => _carregar(service),
          builder: (context, dado, _) {
            final (quiz, correcao) = dado;
            if (correcao == null) return _construirSemCorrecao(context);
            return _construirLista(context, quiz, correcao);
          },
        ),
      ),
    );
  }

  Widget _construirSemCorrecao(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history_edu_outlined,
              size: 56,
              color: AppColors.verdeGradienteInicio,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ainda não temos suas respostas deste quiz',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textoTitulo,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Responda o quiz de novo para ver quais perguntas você acertou '
              'e quais eram as respostas certas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.textoSecundario),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              // Substitui esta tela pelo quiz: ao terminar, o resultado já
              // traz a correção.
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TelaQuizModulo(
                    rotuloTrilha: rotuloTrilha,
                    tituloQuiz: tituloQuiz,
                    quizId: quizId,
                  ),
                ),
              ),
              icon: const Icon(Icons.replay, size: 20),
              label: const Text('Refazer o quiz'),
              style: BotoesEco.principal(),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.verdeEscuro,
              ),
              child: const Text('Agora não'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirLista(
    BuildContext context,
    Quiz quiz,
    List<CorrecaoPergunta> correcao,
  ) {
    final porPergunta = {for (final c in correcao) c.perguntaId: c};
    final perguntas = [...quiz.perguntas]
      ..sort((a, b) => a.ordem.compareTo(b.ordem));
    final acertos = correcao.where((c) => c.acertou).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _construirResumo(acertos, correcao.length),
        const SizedBox(height: 16),
        for (var i = 0; i < perguntas.length; i++)
          if (porPergunta[perguntas[i].id] case final c?) ...[
            _construirPergunta(i + 1, perguntas[i], c),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 4),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: BotoesEco.secundario(),
          child: const Text('Voltar'),
        ),
      ],
    );
  }

  Widget _construirResumo(int acertos, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fundoBranco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.bordaVerdeClara),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tituloQuiz.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: AppColors.textoSecundario,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Você acertou $acertos de $total',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.verdeEscuro,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sua última tentativa. Veja onde errou e qual era a resposta certa.',
            style: TextStyle(fontSize: 14, color: AppColors.textoSecundario),
          ),
        ],
      ),
    );
  }

  Widget _construirPergunta(int numero, Pergunta pergunta, CorrecaoPergunta c) {
    return Semantics(
      label: 'Pergunta $numero: ${c.acertou ? 'você acertou' : 'você errou'}',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.fundoBranco,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: c.acertou
                ? AppColors.bordaVerdeClara
                : const Color(0xFFFFCDD2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'PERGUNTA $numero',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: AppColors.textoSecundario,
                  ),
                ),
                const Spacer(),
                _construirSelo(c.acertou),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              pergunta.enunciado,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                height: 1.3,
                color: AppColors.textoTitulo,
              ),
            ),
            const SizedBox(height: 12),
            for (final alternativa in pergunta.alternativas) ...[
              _construirAlternativa(alternativa, c),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _construirSelo(bool acertou) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: acertou ? AppColors.verdeSobreCabecalho : _vermelhoFundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            acertou ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: acertou ? AppColors.verdeGradienteInicio : _vermelho,
          ),
          const SizedBox(width: 4),
          Text(
            acertou ? 'Acertou' : 'Errou',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: acertou ? AppColors.verdeEscuro : _vermelho,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirAlternativa(Alternativa alternativa, CorrecaoPergunta c) {
    final bool correta = alternativa.id == c.alternativaCorretaId;
    final bool escolhida = alternativa.id == c.alternativaEscolhidaId;

    final Color fundo;
    final Color borda;
    final Color texto;
    final String? legenda;
    final IconData? icone;
    if (correta) {
      fundo = AppColors.verdeSobreCabecalho;
      borda = AppColors.verdeGradienteInicio;
      texto = AppColors.verdeEscuro;
      legenda = escolhida ? 'Sua resposta · correta' : 'Resposta correta';
      icone = Icons.check_circle;
    } else if (escolhida) {
      fundo = _vermelhoFundo;
      borda = _vermelho;
      texto = _vermelho;
      legenda = 'Sua resposta';
      icone = Icons.cancel;
    } else {
      fundo = AppColors.fundoBranco;
      borda = const Color(0xFFE0E0E0);
      texto = AppColors.textoSecundario;
      legenda = null;
      icone = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borda, width: correta || escolhida ? 2 : 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${alternativa.letra.toUpperCase()})',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: texto,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alternativa.texto,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.35,
                    fontWeight: correta || escolhida
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: correta || escolhida ? texto : AppColors.textoTitulo,
                  ),
                ),
                if (legenda != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    legenda,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: texto,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (icone != null) ...[
            const SizedBox(width: 8),
            Icon(icone, size: 20, color: borda),
          ],
        ],
      ),
    );
  }
}
