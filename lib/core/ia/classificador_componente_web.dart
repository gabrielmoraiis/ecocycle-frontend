import 'classificador_componente.dart';

// O TFLite depende de dart:ffi, que não existe no navegador.
const bool classificadorSuportado = false;

Future<ClassificadorComponente> carregarClassificador() async =>
    throw UnsupportedError('Scanner IA indisponível na versão web.');
