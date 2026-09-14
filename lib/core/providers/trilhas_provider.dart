import 'package:flutter/foundation.dart';

import '../models/trilha.dart';
import '../network/api_exception.dart';
import '../services/trilha_service.dart';

/// Cacheia a lista de trilhas em nível de app (assim como Figurinhas e
/// Progresso), evitando rebuscar da API toda vez que a tela Aprender é
/// reaberta. `recarregar()` é chamado explicitamente depois de ações que
/// mudam esse estado (ex.: concluir um conteúdo/quiz).
class TrilhasProvider extends ChangeNotifier {
  final TrilhaService _service;

  TrilhasProvider(this._service);

  List<Trilha> trilhas = [];
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
      trilhas = await _service.listarTrilhas();
      _carregouUmaVez = true;
    } on ApiException catch (e) {
      erro = e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
