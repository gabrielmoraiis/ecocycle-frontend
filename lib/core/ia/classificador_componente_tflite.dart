import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/identificador_componente.dart';
import 'classificador_componente.dart';

const bool classificadorSuportado = true;

const String _caminhoModelo = 'assets/ia/ecocycle_scanner.tflite';

// Ordem das classes de saída do modelo, conforme o metadata.json embutido no
// .tflite pelo export do Ultralytics: {0: ferro_passar, 1: mouse, 2: pilha}.
// Se o modelo for re-treinado, confira essa ordem antes de trocar o arquivo.
const List<IdentificadorComponente> _classes = [
  IdentificadorComponente.ferroPassar,
  IdentificadorComponente.mouse,
  IdentificadorComponente.pilha,
];

Future<ClassificadorComponente> carregarClassificador() async {
  final Interpreter interpreter = await Interpreter.fromAsset(_caminhoModelo);
  try {
    final Tensor entrada = interpreter.getInputTensor(0);
    final Tensor saida = interpreter.getOutputTensor(0);
    final List<int> forma = entrada.shape;

    // YOLO11-cls exportado para TFLite: entrada float32 [1, 3, lado, lado]
    // (canais primeiro, como o modelo atual) ou [1, lado, lado, 3], e saída
    // [1, nº de classes].
    final bool canaisPrimeiro =
        forma.length == 4 && forma[1] == 3 && forma[2] == forma[3];
    final bool canaisPorUltimo =
        forma.length == 4 && forma[3] == 3 && forma[1] == forma[2];
    if (!(canaisPrimeiro || canaisPorUltimo) ||
        entrada.type != TensorType.float32 ||
        saida.type != TensorType.float32 ||
        saida.shape.last != _classes.length) {
      throw StateError(
        'Modelo incompatível: entrada $forma ${entrada.type}, '
        'saída ${saida.shape} ${saida.type}.',
      );
    }
    return _ClassificadorTflite(
      interpreter,
      canaisPrimeiro ? forma[2] : forma[1],
      canaisPrimeiro,
    );
  } catch (_) {
    interpreter.close();
    rethrow;
  }
}

class _ClassificadorTflite implements ClassificadorComponente {
  final Interpreter _interpreter;
  final int _lado;
  final bool _canaisPrimeiro;
  bool _fechado = false;

  _ClassificadorTflite(this._interpreter, this._lado, this._canaisPrimeiro);

  @override
  Future<ClassificacaoComponente> classificar(Uint8List bytesImagem) async {
    // Decodificar e redimensionar a foto é o trabalho pesado: roda em outro
    // isolate para não travar a interface.
    final Float32List entrada = await compute(
      _prepararEntrada,
      _PedidoPreparo(bytesImagem, _lado, _canaisPrimeiro),
    );
    // A tela pode ter sido fechada enquanto a foto era preparada.
    if (_fechado) throw StateError('Classificador já foi fechado.');

    _interpreter.getInputTensor(0).data = entrada.buffer.asUint8List();
    _interpreter.invoke();
    final List<double> probabilidades = _normalizar(
      // Copia os bytes do tensor (memória nativa) antes de reinterpretar.
      Uint8List.fromList(
        _interpreter.getOutputTensor(0).data,
      ).buffer.asFloat32List(),
    );

    int melhor = 0;
    for (int i = 1; i < probabilidades.length; i++) {
      if (probabilidades[i] > probabilidades[melhor]) melhor = i;
    }

    return ClassificacaoComponente(
      identificador: _classes[melhor],
      confianca: (probabilidades[melhor] * 100).clamp(0, 100).toDouble(),
    );
  }

  @override
  void fechar() {
    if (_fechado) return;
    _fechado = true;
    _interpreter.close();
  }
}

// O head Classify do Ultralytics já aplica softmax no export; se a saída não
// parecer uma distribuição de probabilidades (logits), aplica aqui.
List<double> _normalizar(Float32List saida) {
  final double soma = saida.fold(0, (a, b) => a + b);
  final bool jaEhProbabilidade =
      saida.every((v) => v >= 0 && v <= 1) && (soma - 1).abs() < 0.01;
  if (jaEhProbabilidade) return saida;

  final double maximo = saida.reduce(math.max);
  final List<double> exps = [for (final v in saida) math.exp(v - maximo)];
  final double total = exps.fold(0, (a, b) => a + b);
  return [for (final e in exps) e / total];
}

class _PedidoPreparo {
  final Uint8List bytes;
  final int lado;
  final bool canaisPrimeiro;

  const _PedidoPreparo(this.bytes, this.lado, this.canaisPrimeiro);
}

// Mesmo pré-processamento do treino de classificação do Ultralytics: recorte
// quadrado central, redimensiona para lado x lado, RGB em [0, 1], no layout
// que o modelo espera (NCHW ou NHWC).
Float32List _prepararEntrada(_PedidoPreparo pedido) {
  final img.Image? decodificada = img.decodeImage(pedido.bytes);
  if (decodificada == null) {
    throw const FormatException('Não foi possível decodificar a foto.');
  }

  final img.Image orientada = img.bakeOrientation(decodificada);
  final int menorLado = math.min(orientada.width, orientada.height);
  final img.Image quadrada = img.copyCrop(
    orientada,
    x: (orientada.width - menorLado) ~/ 2,
    y: (orientada.height - menorLado) ~/ 2,
    width: menorLado,
    height: menorLado,
  );
  final img.Image redimensionada = img.copyResize(
    quadrada,
    width: pedido.lado,
    height: pedido.lado,
    interpolation: img.Interpolation.linear,
  );

  final Uint8List rgb = redimensionada
      .convert(format: img.Format.uint8, numChannels: 3)
      .getBytes(order: img.ChannelOrder.rgb);
  final Float32List entrada = Float32List(rgb.length);
  if (!pedido.canaisPrimeiro) {
    for (int i = 0; i < rgb.length; i++) {
      entrada[i] = rgb[i] / 255.0;
    }
    return entrada;
  }

  // rgb vem intercalado (R G B R G B ...); NCHW quer um plano por canal.
  final int pixels = pedido.lado * pedido.lado;
  for (int p = 0; p < pixels; p++) {
    entrada[p] = rgb[p * 3] / 255.0;
    entrada[pixels + p] = rgb[p * 3 + 1] / 255.0;
    entrada[2 * pixels + p] = rgb[p * 3 + 2] / 255.0;
  }
  return entrada;
}
