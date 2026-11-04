import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/identificador_componente.dart';
import 'classificador_componente.dart';

const bool classificadorSuportado = true;

const String _caminhoModelo = 'assets/ia/ecocycle_scanner.tflite';

// Ordem das classes de saída do modelo, conforme o metadata.json embutido no
// .tflite pelo export do Ultralytics. Se o modelo for re-treinado, confira essa
// ordem antes de trocar o arquivo. O modelo atual não tem a classe Outros; se
// ela voltar, entra como null na posição dela: a foto não mostra um aparelho
// reconhecido, então a leitura não vai para o back-end.
const List<IdentificadorComponente?> _classes = [
  IdentificadorComponente.celular, // Celular
  IdentificadorComponente.ferroPassar, // Ferro de passar
  IdentificadorComponente.fonte, // Fonte
  IdentificadorComponente.hd, // HDD
  IdentificadorComponente.monitor, // Monitor ou TV
  IdentificadorComponente.mouse, // Mouse
  IdentificadorComponente.notebook, // Notebook
  IdentificadorComponente.placaCircuito, // PCB
  IdentificadorComponente.pendrive, // Pendrive
  IdentificadorComponente.pilha, // Pilha
  IdentificadorComponente.teclado, // Teclado
];

@visibleForTesting
const List<IdentificadorComponente?> classesDoModelo = _classes;

/// O que o modelo instalado reconhece (mostrado no Scanner).
final List<IdentificadorComponente> componentesDoModelo = _classes
    .whereType<IdentificadorComponente>()
    .toList(growable: false);

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
      prepararEntrada,
      PedidoPreparo(bytesImagem, _lado, _canaisPrimeiro),
    );
    // A tela pode ter sido fechada enquanto a foto era preparada.
    if (_fechado) throw StateError('Classificador já foi fechado.');

    _interpreter.getInputTensor(0).data = entrada.buffer.asUint8List();
    _interpreter.invoke();
    return classificacaoDaSaida(
      // Copia os bytes do tensor (memória nativa) antes de reinterpretar.
      Uint8List.fromList(
        _interpreter.getOutputTensor(0).data,
      ).buffer.asFloat32List(),
    );
  }

  @override
  void fechar() {
    if (_fechado) return;
    _fechado = true;
    _interpreter.close();
  }
}

@visibleForTesting
ClassificacaoComponente classificacaoDaSaida(Float32List saida) {
  final List<double> probabilidades = _normalizar(saida);

  int melhor = 0;
  for (int i = 1; i < probabilidades.length; i++) {
    if (probabilidades[i] > probabilidades[melhor]) melhor = i;
  }

  int? segunda;
  for (int i = 0; i < probabilidades.length; i++) {
    if (i == melhor) continue;
    if (segunda == null || probabilidades[i] > probabilidades[segunda]) {
      segunda = i;
    }
  }

  return ClassificacaoComponente(
    identificador: _classes[melhor],
    confianca: _percentual(probabilidades[melhor]),
    segundoIdentificador: segunda == null
        ? null
        : _classes[segunda]?.valor ?? 'OUTROS',
    segundaConfianca: segunda == null
        ? null
        : _percentual(probabilidades[segunda]),
  );
}

double _percentual(double probabilidade) =>
    (probabilidade * 100).clamp(0, 100).toDouble();

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

/// Desfoque leve da foto: alarga o filtro do redimensionamento. Serve para um
/// modelo que perde confiança com o detalhe fino de fotos de alta resolução.
/// 1.0 desliga e fica igual ao notebook. O modelo anterior usava 1.5; a cada
/// novo modelo, calibre com fotos reais e suba aos poucos, porque valores altos
/// fazem fotos mudarem de classe.
const double suavizacaoFoto = 1.0;

class PedidoPreparo {
  final Uint8List bytes;
  final int lado;
  final bool canaisPrimeiro;
  final double suavizacao;

  const PedidoPreparo(
    this.bytes,
    this.lado,
    this.canaisPrimeiro, {
    this.suavizacao = suavizacaoFoto,
  });
}

// Mesmo pré-processamento do Ultralytics, na mesma ordem, para o resultado bater
// com o do notebook: leva o menor lado da foto a `lado` com o filtro triângulo,
// recorta o quadrado central e passa para RGB em [0, 1], no layout que o modelo
// espera (NCHW ou NHWC).
@visibleForTesting
Float32List prepararEntrada(PedidoPreparo pedido) {
  final img.Image? decodificada = img.decodeImage(pedido.bytes);
  if (decodificada == null) {
    throw const FormatException('Não foi possível decodificar a foto.');
  }

  final img.Image orientada = img.bakeOrientation(decodificada);
  final int larguraFoto = orientada.width;
  final int alturaFoto = orientada.height;
  final int lado = pedido.lado;
  final int largura = larguraFoto <= alturaFoto
      ? lado
      : (lado * larguraFoto) ~/ alturaFoto;
  final int altura = larguraFoto <= alturaFoto
      ? (lado * alturaFoto) ~/ larguraFoto
      : lado;

  final Uint8List rgb = redimensionarTriangulo(
    orientada
        .convert(format: img.Format.uint8, numChannels: 3)
        .getBytes(order: img.ChannelOrder.rgb),
    larguraFoto,
    alturaFoto,
    largura,
    altura,
    suavizacao: pedido.suavizacao,
  );

  final int inicioX = _inicioDoCentro(largura - lado);
  final int inicioY = _inicioDoCentro(altura - lado);
  final int pixels = lado * lado;
  final Float32List entrada = Float32List(3 * pixels);
  for (int y = 0; y < lado; y++) {
    for (int x = 0; x < lado; x++) {
      final int p = y * lado + x;
      final int origem = ((y + inicioY) * largura + x + inicioX) * 3;
      for (int canal = 0; canal < 3; canal++) {
        // rgb vem intercalado (R G B R G B ...); NCHW quer um plano por canal.
        final int destino = pedido.canaisPrimeiro
            ? canal * pixels + p
            : p * 3 + canal;
        entrada[destino] = rgb[origem + canal] / 255.0;
      }
    }
  }
  return entrada;
}

// O torchvision arredonda a metade para o par (round do Python). Errar 1 pixel
// aqui já move a resposta do modelo, então segue a mesma regra.
int _inicioDoCentro(int sobra) {
  final int metade = sobra ~/ 2;
  return sobra.isOdd && metade.isOdd ? metade + 1 : metade;
}

/// Redimensiona pixels RGB intercalados como o BILINEAR do Pillow, que é o que
/// o Ultralytics usa: filtro triângulo, primeiro na horizontal e depois na
/// vertical. Ao reduzir, o triângulo se alarga para cobrir todos os pixels que
/// viram um só; o pacote image não tem isso (o linear dele lê apenas 4 pixels).
@visibleForTesting
Uint8List redimensionarTriangulo(
  Uint8List rgb,
  int largura,
  int altura,
  int novaLargura,
  int novaAltura, {
  double suavizacao = 1.0,
}) {
  final _PesosTriangulo pesosX = _PesosTriangulo(
    largura,
    novaLargura,
    suavizacao,
  );
  final Uint8List horizontal = Uint8List(3 * novaLargura * altura);
  for (int y = 0; y < altura; y++) {
    final int linha = y * largura * 3;
    int saida = y * novaLargura * 3;
    for (int x = 0; x < novaLargura; x++) {
      for (int canal = 0; canal < 3; canal++) {
        horizontal[saida++] = pesosX.aplicar(x, rgb, linha + canal, 3);
      }
    }
  }

  final _PesosTriangulo pesosY = _PesosTriangulo(
    altura,
    novaAltura,
    suavizacao,
  );
  final Uint8List resultado = Uint8List(3 * novaLargura * novaAltura);
  final int passoLinha = novaLargura * 3;
  int saida = 0;
  for (int y = 0; y < novaAltura; y++) {
    for (int coluna = 0; coluna < passoLinha; coluna++) {
      resultado[saida++] = pesosY.aplicar(y, horizontal, coluna, passoLinha);
    }
  }
  return resultado;
}

/// Pesos do filtro triângulo em um eixo, normalizados para cada pixel novo.
class _PesosTriangulo {
  final Int32List _inicios;
  final Int32List _quantidades;
  final Float64List _pesos;
  final int _porPixel;

  factory _PesosTriangulo(int tamanho, int novoTamanho, double suavizacao) {
    final double escala = tamanho / novoTamanho;
    // Ao ampliar a escala fica menor que 1, mas o filtro não encolhe.
    final double largura = math.max(escala, 1.0) * suavizacao;
    final int porPixel = largura.ceil() * 2 + 1;

    final Int32List inicios = Int32List(novoTamanho);
    final Int32List quantidades = Int32List(novoTamanho);
    final Float64List pesos = Float64List(novoTamanho * porPixel);
    for (int i = 0; i < novoTamanho; i++) {
      final double centro = (i + 0.5) * escala;
      final int inicio = math.max((centro - largura + 0.5).toInt(), 0);
      final int fim = math.min((centro + largura + 0.5).toInt(), tamanho);
      inicios[i] = inicio;
      quantidades[i] = fim - inicio;

      double soma = 0;
      for (int j = 0; j < fim - inicio; j++) {
        final double distancia = (j + inicio - centro + 0.5).abs() / largura;
        final double peso = distancia < 1 ? 1 - distancia : 0;
        pesos[i * porPixel + j] = peso;
        soma += peso;
      }
      for (int j = 0; j < fim - inicio; j++) {
        pesos[i * porPixel + j] /= soma;
      }
    }
    return _PesosTriangulo._(inicios, quantidades, pesos, porPixel);
  }

  _PesosTriangulo._(
    this._inicios,
    this._quantidades,
    this._pesos,
    this._porPixel,
  );

  /// Valor do pixel novo [indice], lendo a partir de [base] de [passo] em passo.
  int aplicar(int indice, Uint8List dados, int base, int passo) {
    final int inicio = _inicios[indice];
    final int quantidade = _quantidades[indice];
    final int primeiroPeso = indice * _porPixel;
    double valor = 0;
    for (int j = 0; j < quantidade; j++) {
      valor += _pesos[primeiroPeso + j] * dados[base + (inicio + j) * passo];
    }
    return (valor + 0.5).floor().clamp(0, 255);
  }
}
