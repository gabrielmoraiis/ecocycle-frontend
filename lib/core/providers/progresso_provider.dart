import 'package:flutter/foundation.dart';

import '../models/progresso.dart';
import '../network/api_exception.dart';
import '../services/progresso_service.dart';

class ProgressoProvider extends ChangeNotifier {
  final ProgressoService _service;

  ProgressoProvider(this._service);

  Progresso? progresso;
  bool isLoading = false;
  ApiException? erro;
  bool _carregouUmaVez = false;

  Future<void> carregar({bool forcar = false}) async {
    if (_carregouUmaVez && !forcar) return;
    await recarregar();
  }

  Future<void> recarregar() async {
    isLoading = true;
    erro = null;
    notifyListeners();
    try {
      progresso = await _service.meuProgresso();
      _carregouUmaVez = true;
    } on ApiException catch (e) {
      erro = e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
