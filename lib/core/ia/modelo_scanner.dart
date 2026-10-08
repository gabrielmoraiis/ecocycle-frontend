import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../models/identificador_componente.dart';

// Dados do modelo treinado (YOLO11n-cls exportado para TFLite). Se o modelo for
// retreinado, confira o metadata.json embutido no .tflite e atualize aqui.
const String caminhoModeloScanner = 'assets/ia/ecocycle_scanner.tflite';
const int tamanhoEntradaModelo = 224;

// Mesma ordem das classes na saída do modelo:
// {"0": "ferro_passar", "1": "mouse", "2": "pilha"}.
const List<IdentificadorComponente> classesDoModelo = [
  IdentificadorComponente.ferroPassar,
  IdentificadorComponente.mouse,
  IdentificadorComponente.pilha,
];

class ResultadoClassificacao {
  final IdentificadorComponente identificador;

  // Probabilidade da classe escolhida, de 0 a 100 (mesma escala da API).
  final double confianca;

  const ResultadoClassificacao({
    required this.identificador,
    required this.confianca,
  });

  factory ResultadoClassificacao.daSaida(List<double> probabilidades) {
    var melhor = 0;
    for (var i = 1; i < probabilidades.length; i++) {
      if (probabilidades[i] > probabilidades[melhor]) melhor = i;
    }
    return ResultadoClassificacao(
      identificador: classesDoModelo[melhor],
      confianca: probabilidades[melhor] * 100,
    );
  }
}

// Replica o pré-processamento de classificação do Ultralytics: corrige a
// rotação da foto, recorta o quadrado central, redimensiona para 224x224 e
// entrega os pixels RGB de 0 a 1 em formato NCHW ([1, 3, 224, 224]).
Float32List preprocessarImagem(Uint8List bytes) {
  img.Image? decodificada;
  try {
    decodificada = img.decodeImage(bytes);
  } catch (_) {
    // Alguns decodificadores lançam RangeError com bytes inválidos.
    decodificada = null;
  }
  if (decodificada == null) {
    throw const FormatException('Não foi possível ler a imagem capturada.');
  }
  final orientada = img.bakeOrientation(decodificada);

  final lado = min(orientada.width, orientada.height);
  final quadrada = img.copyCrop(
    orientada,
    x: (orientada.width - lado) ~/ 2,
    y: (orientada.height - lado) ~/ 2,
    width: lado,
    height: lado,
  );
  final reduzida = img.copyResize(
    quadrada,
    width: tamanhoEntradaModelo,
    height: tamanhoEntradaModelo,
    interpolation: img.Interpolation.linear,
  );

  const area = tamanhoEntradaModelo * tamanhoEntradaModelo;
  final entrada = Float32List(3 * area);
  for (final pixel in reduzida) {
    final i = pixel.y * tamanhoEntradaModelo + pixel.x;
    entrada[i] = pixel.rNormalized.toDouble();
    entrada[area + i] = pixel.gNormalized.toDouble();
    entrada[2 * area + i] = pixel.bNormalized.toDouble();
  }
  return entrada;
}
