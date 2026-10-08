import 'dart:typed_data';

import '../models/identificador_componente.dart';
import 'classificador_componente_web.dart'
    if (dart.library.ffi) 'classificador_componente_tflite.dart'
    as impl;

class ClassificacaoComponente {
  final IdentificadorComponente identificador;

  /// Probabilidade da classe vencedora, de 0 a 100.
  final double confianca;

  const ClassificacaoComponente({
    required this.identificador,
    required this.confianca,
  });
}

/// Classifica a foto de um componente com o modelo embarcado no app
/// (assets/ia/ecocycle_scanner.tflite). Não existe no navegador: lá
/// [suportado] é falso e [carregar] falha.
abstract class ClassificadorComponente {
  static bool get suportado => impl.classificadorSuportado;

  static Future<ClassificadorComponente> carregar() =>
      impl.carregarClassificador();

  Future<ClassificacaoComponente> classificar(Uint8List bytesImagem);

  void fechar();
}
