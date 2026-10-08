import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'classificador_scanner.dart';
import 'modelo_scanner.dart';

Future<ClassificadorScanner> carregarClassificador() async {
  final interpretador = await Interpreter.fromAsset(
    caminhoModeloScanner,
    options: InterpreterOptions()..threads = 2,
  );

  const formatoEsperado = [1, 3, tamanhoEntradaModelo, tamanhoEntradaModelo];
  final formatoEntrada = interpretador.getInputTensor(0).shape;
  final formatoSaida = interpretador.getOutputTensor(0).shape;
  if (!listEquals(formatoEntrada, formatoEsperado) ||
      formatoSaida.last != classesDoModelo.length) {
    interpretador.close();
    throw StateError(
      'Modelo incompatível: entrada $formatoEntrada, saída $formatoSaida.',
    );
  }
  return _ClassificadorTflite(interpretador);
}

class _ClassificadorTflite implements ClassificadorScanner {
  final Interpreter _interpretador;

  _ClassificadorTflite(this._interpretador);

  @override
  Future<ResultadoClassificacao> classificar(Uint8List bytesImagem) async {
    // Decodificar e redimensionar a foto é o passo mais pesado: roda fora da
    // thread da interface para não travar a animação.
    final entrada = await Isolate.run(() => preprocessarImagem(bytesImagem));

    final saida = [List<double>.filled(classesDoModelo.length, 0)];
    _interpretador.run(entrada.buffer, saida);
    return ResultadoClassificacao.daSaida(saida.first);
  }

  @override
  void fechar() => _interpretador.close();
}
