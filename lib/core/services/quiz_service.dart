import 'package:dio/dio.dart';

import '../models/quiz.dart';
import '../models/requests/submeter_quiz_request.dart';
import '../models/resultado_submissao.dart';
import '../network/api_exception.dart';

class QuizService {
  final Dio _dio;

  QuizService(this._dio);

  Future<Quiz> buscarPorConteudo(int conteudoId) {
    return runApiCall(() async {
      final response = await _dio.get('/quizzes/por-conteudo/$conteudoId');
      return Quiz.fromJson(response.data['data'] as Map<String, dynamic>);
    });
  }

  Future<Quiz> buscarPorId(int id) {
    return runApiCall(() async {
      final response = await _dio.get('/quizzes/$id');
      return Quiz.fromJson(response.data['data'] as Map<String, dynamic>);
    });
  }

  Future<ResultadoSubmissao> submeter(int id, List<RespostaQuiz> respostas) {
    return runApiCall(() async {
      final response = await _dio.post(
        '/quizzes/$id/submeter',
        data: SubmeterQuizRequest(respostas: respostas).toJson(),
      );
      return ResultadoSubmissao.fromJson(response.data['data'] as Map<String, dynamic>);
    });
  }
}
