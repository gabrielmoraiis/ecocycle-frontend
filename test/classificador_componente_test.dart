import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ecocycle/core/data/figurinha_presentation_catalog.dart';
import 'package:ecocycle/core/ia/classificador_componente_tflite.dart';
import 'package:ecocycle/core/models/identificador_componente.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

// Nome de cada classe no treino -> componente do app. É o que amarra o modelo
// ao código: se um novo treino mudar nomes ou ordem, o teste abaixo falha.
const Map<String, IdentificadorComponente?> _componentePorClasse = {
  'Ferro de passar': IdentificadorComponente.ferroPassar,
  'Fonte': IdentificadorComponente.fonte,
  'HDD': IdentificadorComponente.hd,
  'Mouse': IdentificadorComponente.mouse,
  'Notebook': IdentificadorComponente.notebook,
  'Outros': null,
  'PCB': IdentificadorComponente.placaCircuito,
  'Pendrive': IdentificadorComponente.pendrive,
  'Pilha': IdentificadorComponente.pilha,
};

// O metadata.json é o único arquivo do zip anexado ao fim do .tflite.
Map<String, dynamic> _metadataDoModelo() {
  final Uint8List bytes = File(
    'assets/ia/ecocycle_scanner.tflite',
  ).readAsBytesSync();
  int inicio = bytes.length - 4;
  while (bytes[inicio] != 0x50 ||
      bytes[inicio + 1] != 0x4B ||
      bytes[inicio + 2] != 0x03 ||
      bytes[inicio + 3] != 0x04) {
    inicio--;
  }
  final ByteData cabecalho = ByteData.sublistView(bytes, inicio);
  final int metodo = cabecalho.getUint16(8, Endian.little);
  final int tamanho = cabecalho.getUint32(18, Endian.little);
  final int dados =
      inicio +
      30 +
      cabecalho.getUint16(26, Endian.little) +
      cabecalho.getUint16(28, Endian.little);
  final Uint8List conteudo = bytes.sublist(dados, dados + tamanho);
  final List<int> json = metodo == 0
      ? conteudo
      : ZLibDecoder(raw: true).convert(conteudo);
  return jsonDecode(utf8.decode(json)) as Map<String, dynamic>;
}

Float32List _saida(String classe, {double valor = 0.92}) {
  final List<String> nomes = _componentePorClasse.keys.toList();
  final double resto = (1 - valor) / (nomes.length - 1);
  return Float32List.fromList([
    for (final nome in nomes) nome == classe ? valor : resto,
  ]);
}

void main() {
  group('modelo instalado', () {
    test('tem as classes na ordem que o app espera', () {
      final Map<String, dynamic> nomes =
          _metadataDoModelo()['names'] as Map<String, dynamic>;

      expect(nomes.length, classesDoModelo.length);
      for (int i = 0; i < classesDoModelo.length; i++) {
        final String nome = nomes['$i'] as String;
        expect(_componentePorClasse.containsKey(nome), isTrue, reason: nome);
        expect(classesDoModelo[i], _componentePorClasse[nome], reason: nome);
      }
    });

    test('é uma classificação com entrada quadrada de 3 canais', () {
      final Map<String, dynamic> metadata = _metadataDoModelo();

      expect(metadata['task'], 'classify');
      expect(metadata['channels'], 3);
      expect(metadata['imgsz'], [640, 640]);
    });
  });

  group('componentes reconhecidos', () {
    test('são os 8 aparelhos do modelo, sem Outros', () {
      expect(componentesDoModelo, hasLength(8));
      expect(componentesDoModelo, isNot(contains(null)));
    });

    test('celular, monitor e teclado seguem no app, fora do Scanner', () {
      for (final componente in [
        IdentificadorComponente.celular,
        IdentificadorComponente.monitor,
        IdentificadorComponente.teclado,
      ]) {
        expect(IdentificadorComponente.values, contains(componente));
        expect(componentesDoModelo, isNot(contains(componente)));
        expect(
          apresentacaoDaFigurinha(componente.codigoFigurinha).comoDesbloquear,
          'Em breve no Scanner IA.',
        );
      }
    });

    test('valores e códigos de figurinha não se repetem', () {
      const valores = IdentificadorComponente.values;
      expect(valores.map((c) => c.valor).toSet(), hasLength(valores.length));
      expect(
        valores.map((c) => c.codigoFigurinha).toSet(),
        hasLength(valores.length),
      );
    });

    test('toda figurinha tem ficha própria no catálogo', () {
      final padrao = apresentacaoDaFigurinha('FIG-INEXISTENTE');
      for (final componente in IdentificadorComponente.values) {
        final ficha = apresentacaoDaFigurinha(componente.codigoFigurinha);
        expect(ficha, isNot(same(padrao)), reason: componente.valor);
      }
    });

    test('pendrive orienta a proteger os dados antes do descarte', () {
      final ficha = apresentacaoDaFigurinha(
        IdentificadorComponente.pendrive.codigoFigurinha,
      );
      expect(ficha.protecaoDados, isNotEmpty);
    });

    test('daFigurinha acha as figurinhas novas', () {
      expect(
        IdentificadorComponente.daFigurinha('FIG-17'),
        IdentificadorComponente.fonte,
      );
      expect(
        IdentificadorComponente.daFigurinha('FIG-18'),
        IdentificadorComponente.pendrive,
      );
    });
  });

  group('classificacaoDaSaida', () {
    for (final MapEntry(key: classe, value: componente)
        in _componentePorClasse.entries) {
      test('classe vencedora $classe', () {
        final resultado = classificacaoDaSaida(_saida(classe));

        expect(resultado.identificador, componente);
        expect(resultado.confianca, closeTo(92, 0.01));
      });
    }

    test('Outros vence mesmo com um aparelho perto', () {
      final saida = _saida('Outros', valor: 0.51);
      saida[3] = 0.49 - 7 * (0.49 / 8); // Mouse

      expect(classificacaoDaSaida(saida).identificador, isNull);
    });

    test('logits viram probabilidades', () {
      final saida = Float32List(9)..[8] = 10; // Pilha

      final resultado = classificacaoDaSaida(saida);

      expect(resultado.identificador, IdentificadorComponente.pilha);
      expect(resultado.confianca, greaterThan(99));
      expect(resultado.confianca, lessThanOrEqualTo(100));
    });
  });

  group('prepararEntrada', () {
    Uint8List jpeg(int largura, int altura, img.Color Function(int x) cor) {
      final imagem = img.Image(width: largura, height: altura);
      for (final pixel in imagem) {
        pixel.set(cor(pixel.x));
      }
      return Uint8List.fromList(img.encodePng(imagem));
    }

    test('NCHW separa um plano por canal, em [0, 1]', () {
      final bytes = jpeg(8, 8, (_) => img.ColorRgb8(255, 0, 51));

      final entrada = prepararEntrada(PedidoPreparo(bytes, 4, true));

      expect(entrada, hasLength(3 * 4 * 4));
      expect(entrada.sublist(0, 16), everyElement(closeTo(1, 0.001)));
      expect(entrada.sublist(16, 32), everyElement(closeTo(0, 0.001)));
      expect(entrada.sublist(32, 48), everyElement(closeTo(0.2, 0.001)));
    });

    test('foto retangular é cortada no centro', () {
      // Faixas laterais vermelhas e centro verde: só o centro deve sobrar.
      final bytes = jpeg(
        30,
        10,
        (x) => x >= 10 && x < 20
            ? img.ColorRgb8(0, 255, 0)
            : img.ColorRgb8(255, 0, 0),
      );

      final entrada = prepararEntrada(PedidoPreparo(bytes, 4, true));

      expect(entrada.sublist(0, 16), everyElement(closeTo(0, 0.001)));
      expect(entrada.sublist(16, 32), everyElement(closeTo(1, 0.001)));
    });

    test('rejeita bytes que não são imagem', () {
      expect(
        () => prepararEntrada(
          PedidoPreparo(Uint8List(64), 4, true),
        ),
        throwsFormatException,
      );
    });
  });
}
