import 'dart:typed_data';

import 'package:ecocycle/core/ia/modelo_scanner.dart';
import 'package:ecocycle/core/models/identificador_componente.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

const _area = tamanhoEntradaModelo * tamanhoEntradaModelo;

Uint8List _png(img.Image imagem) => img.encodePng(imagem);

void main() {
  group('preprocessarImagem', () {
    test('gera tensor NCHW 3x224x224 com valores de 0 a 1', () {
      final imagem = img.Image(width: 640, height: 480)
        ..clear(img.ColorRgb8(255, 128, 0));

      final entrada = preprocessarImagem(_png(imagem));

      expect(entrada.length, 3 * _area);
      // Canal R inteiro antes do G, e o G antes do B (formato NCHW).
      expect(entrada[0], closeTo(1.0, 1e-6));
      expect(entrada[_area - 1], closeTo(1.0, 1e-6));
      expect(entrada[_area], closeTo(128 / 255, 1e-6));
      expect(entrada[2 * _area], closeTo(0.0, 1e-6));
      expect(entrada.every((v) => v >= 0 && v <= 1), isTrue);
    });

    test('recorta o quadrado central antes de redimensionar', () {
      // 300x200: as faixas de 50 px nas laterais ficam fora do recorte.
      final imagem = img.Image(width: 300, height: 200)
        ..clear(img.ColorRgb8(255, 0, 0));
      img.fillRect(
        imagem,
        x1: 0,
        y1: 0,
        x2: 49,
        y2: 199,
        color: img.ColorRgb8(0, 0, 255),
      );
      img.fillRect(
        imagem,
        x1: 250,
        y1: 0,
        x2: 299,
        y2: 199,
        color: img.ColorRgb8(0, 0, 255),
      );

      final entrada = preprocessarImagem(_png(imagem));

      final azul = entrada.sublist(2 * _area);
      final vermelho = entrada.sublist(0, _area);
      expect(azul.every((v) => v < 0.01), isTrue);
      expect(vermelho.every((v) => v > 0.99), isTrue);
    });

    test('recusa bytes que não são imagem', () {
      expect(
        () => preprocessarImagem(Uint8List.fromList([1, 2, 3])),
        throwsFormatException,
      );
    });
  });

  group('ResultadoClassificacao.daSaida', () {
    test('escolhe a classe mais provável na ordem do modelo', () {
      final resultado = ResultadoClassificacao.daSaida([0.1, 0.2, 0.7]);

      expect(resultado.identificador, IdentificadorComponente.pilha);
      expect(resultado.confianca, closeTo(70, 1e-9));
    });

    test('ordem das classes segue o metadata do modelo', () {
      expect(classesDoModelo.map((c) => c.valor), [
        'FERRO_PASSAR',
        'MOUSE',
        'PILHA',
      ]);
    });
  });
}
