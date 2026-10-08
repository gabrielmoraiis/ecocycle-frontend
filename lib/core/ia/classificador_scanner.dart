import 'dart:typed_data';

import 'classificador_scanner_stub.dart'
    if (dart.library.ffi) 'classificador_scanner_tflite.dart'
    as implementacao;
import 'modelo_scanner.dart';

// Classifica a foto do scanner no próprio aparelho. A implementação com
// TensorFlow Lite só existe onde há dart:ffi (Android/iOS); na web o
// carregamento falha e a tela oferece apenas a busca manual.
abstract class ClassificadorScanner {
  Future<ResultadoClassificacao> classificar(Uint8List bytesImagem);

  void fechar();
}

Future<ClassificadorScanner> carregarClassificadorScanner() =>
    implementacao.carregarClassificador();
