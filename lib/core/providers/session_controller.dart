import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/requests/login_request.dart';
import '../models/requests/register_request.dart';
import '../models/usuario.dart';
import '../network/api_exception.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

const _chaveToken = 'ecocycle_token';

class SessionController extends ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;
  final FlutterSecureStorage _storage;

  SessionController({
    required AuthService authService,
    required UserService userService,
    FlutterSecureStorage? storage,
  }) : _authService = authService,
       _userService = userService,
       _storage = storage ?? const FlutterSecureStorage();

  AuthStatus status = AuthStatus.unknown;
  Usuario? usuario;
  String? token;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  Future<void> tentarRestaurarSessao() async {
    final tokenSalvo = await _storage.read(key: _chaveToken);
    if (tokenSalvo == null || tokenSalvo.isEmpty) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    token = tokenSalvo;
    try {
      usuario = await _userService.me();
      status = AuthStatus.authenticated;
    } on ApiException {
      await _storage.delete(key: _chaveToken);
      token = null;
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login({required String email, required String senha}) async {
    final resultado = await _authService.login(
      LoginRequest(email: email, senha: senha),
    );
    await _aplicarAutenticacao(resultado.token, resultado.usuario);
  }

  Future<void> registrar({
    required String email,
    required String apelido,
    required String senha,
  }) async {
    final resultado = await _authService.registrar(
      RegisterRequest(email: email, apelido: apelido, senha: senha),
    );
    await _aplicarAutenticacao(resultado.token, resultado.usuario);
  }

  Future<void> _aplicarAutenticacao(
    String novoToken,
    Usuario novoUsuario,
  ) async {
    token = novoToken;
    usuario = novoUsuario;
    status = AuthStatus.authenticated;
    await _storage.write(key: _chaveToken, value: novoToken);
    notifyListeners();
  }

  Future<void> atualizarAvatar(Avatar avatar) async {
    usuario = await _userService.atualizarAvatar(avatar);
    notifyListeners();
  }

  Future<void> excluirConta() async {
    await _userService.excluirConta();
    await logout();
  }

  Future<void> logout() async {
    await _storage.delete(key: _chaveToken);
    token = null;
    usuario = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void forceLogout() {
    _storage.delete(key: _chaveToken);
    token = null;
    usuario = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
