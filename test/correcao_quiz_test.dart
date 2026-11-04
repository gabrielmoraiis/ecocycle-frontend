import 'package:ecocycle/core/models/correcao_quiz.dart';
import 'package:ecocycle/core/models/resultado_submissao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final Map<String, dynamic> base = {
    'acertos': 1,
    'totalPerguntas': 2,
    'primeiraConclusao': true,
    'xpGanho': 10,
    'xpTotalAtual': 10,
  };

  test('lê a correção enviada junto com o resultado do quiz', () {
    final resultado = ResultadoSubmissao.fromJson({
      ...base,
      'correcao': [
        {
          'perguntaId': 1,
          'ordem': 1,
          'alternativaEscolhidaId': 11,
          'alternativaCorretaId': 11,
          'acertou': true,
        },
        {
          'perguntaId': 2,
          'ordem': 2,
          'alternativaEscolhidaId': 21,
          'alternativaCorretaId': 23,
          'acertou': false,
        },
      ],
    });

    expect(resultado.correcao, hasLength(2));
    expect(resultado.correcao[1].alternativaEscolhidaId, 21);
    expect(resultado.correcao[1].alternativaCorretaId, 23);
    expect(resultado.correcao[1].acertou, isFalse);
  });

  test('backend sem correção vira lista vazia (botão não aparece)', () {
    expect(ResultadoSubmissao.fromJson(base).correcao, isEmpty);
  });

  test('lê a correção da última tentativa', () {
    final correcao = CorrecaoQuiz.fromJson({
      'quizId': 3,
      'acertos': 0,
      'totalPerguntas': 1,
      'respondidoEm': '2026-11-04T12:00:00',
      'correcao': [
        {
          'perguntaId': 9,
          'ordem': 1,
          'alternativaEscolhidaId': 90,
          'alternativaCorretaId': 91,
          'acertou': false,
        },
      ],
    });
    expect(correcao.acertos, 0);
    expect(correcao.perguntas.single.alternativaCorretaId, 91);
  });
}
