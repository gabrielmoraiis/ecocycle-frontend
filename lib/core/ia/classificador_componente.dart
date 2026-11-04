import 'dart:typed_data';

import '../models/identificador_componente.dart';
import 'classificador_componente_web.dart'
    if (dart.library.ffi) 'classificador_componente_tflite.dart'
    as impl;

class ClassificacaoComponente {
  /// Null quando o modelo escolheu a classe Outros: a foto não mostra nenhum
  /// dos aparelhos reconhecidos.
  final IdentificadorComponente? identificador;

  /// Probabilidade da classe vencedora, de 0 a 100.
  final double confianca;

  /// Segunda classe mais provável, como o back-end a conhece: o valor do
  /// identificador ou OUTROS. Serve só para os logs.
  final String? segundoIdentificador;

  /// Probabilidade da segunda classe, de 0 a 100.
  final double? segundaConfianca;

  const ClassificacaoComponente({
    required this.identificador,
    required this.confianca,
    this.segundoIdentificador,
    this.segundaConfianca,
  });

  /// Ex.: "MOUSE 65.0% PENDRIVE 21.0%".
  String get resumo {
    final String primeira =
        '${identificador?.valor ?? 'OUTROS'} ${confianca.toStringAsFixed(1)}%';
    final double? segunda = segundaConfianca;
    if (segundoIdentificador == null || segunda == null) return primeira;
    return '$primeira $segundoIdentificador ${segunda.toStringAsFixed(1)}%';
  }
}

/// Classifica a foto de um componente com o modelo embarcado no app
/// (assets/ia/ecocycle_scanner.tflite). Não existe no navegador: lá
/// [suportado] é falso e [carregar] falha.
abstract class ClassificadorComponente {
  static bool get suportado => impl.classificadorSuportado;

  /// Componentes que o modelo instalado consegue reconhecer, na ordem das
  /// classes de saída. Vazio onde não há modelo (web).
  static List<IdentificadorComponente> get componentesReconhecidos =>
      impl.componentesDoModelo;

  static Future<ClassificadorComponente> carregar() =>
      impl.carregarClassificador();

  Future<ClassificacaoComponente> classificar(Uint8List bytesImagem);

  void fechar();
}
