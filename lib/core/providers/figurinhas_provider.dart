import 'package:flutter/foundation.dart';

import '../models/figurinha.dart';
import '../network/api_exception.dart';
import '../services/figurinha_service.dart';

class FigurinhasProvider extends ChangeNotifier {
  final FigurinhaService _service;

  FigurinhasProvider(this._service);

  List<Figurinha> figurinhas = [];
  bool isLoading = false;
  ApiException? erro;
  bool _carregouUmaVez = false;

  List<Figurinha> get desbloqueadas => figurinhas.where((f) => f.desbloqueada).toList();
  List<Figurinha> get bloqueadas => figurinhas.where((f) => !f.desbloqueada).toList();

  Future<void> carregar({bool forcar = false}) async {
    if (_carregouUmaVez && !forcar) return;
    await recarregar();
  }

  Future<void> recarregar() async {
    isLoading = true;
    erro = null;
    notifyListeners();
    try {
      figurinhas = await _service.listar();
      _carregouUmaVez = true;
    } on ApiException catch (e) {
      erro = e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
