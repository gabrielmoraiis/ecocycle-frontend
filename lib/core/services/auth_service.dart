import 'package:dio/dio.dart';

import '../models/auth_result.dart';
import '../models/requests/login_request.dart';
import '../models/requests/register_request.dart';
import '../network/api_exception.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<AuthResult> registrar(RegisterRequest request) {
    return runApiCall(() async {
      final response = await _dio.post('/auth/register', data: request.toJson());
      return AuthResult.fromJson(response.data['data'] as Map<String, dynamic>);
    });
  }

  Future<AuthResult> login(LoginRequest request) {
    return runApiCall(() async {
      final response = await _dio.post('/auth/login', data: request.toJson());
      return AuthResult.fromJson(response.data['data'] as Map<String, dynamic>);
    });
  }
}
