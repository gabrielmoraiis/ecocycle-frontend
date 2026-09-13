import 'package:dio/dio.dart';

import '../models/requests/atualizar_avatar_request.dart';
import '../models/usuario.dart';
import '../network/api_exception.dart';

class UserService {
  final Dio _dio;

  UserService(this._dio);

  Future<Usuario> me() {
    return runApiCall(() async {
      final response = await _dio.get('/users/me');
      return Usuario.fromJson(response.data['data'] as Map<String, dynamic>);
    });
  }

  Future<Usuario> atualizarAvatar(Avatar avatar) {
    return runApiCall(() async {
      final response = await _dio.patch(
        '/users/me/avatar',
        data: AtualizarAvatarRequest(avatar: avatar).toJson(),
      );
      return Usuario.fromJson(response.data['data'] as Map<String, dynamic>);
    });
  }

  Future<void> excluirConta() {
    return runApiCall(() async {
      await _dio.delete('/users/me');
    });
  }
}
