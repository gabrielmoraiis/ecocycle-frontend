import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../models/trilha.dart';

class TrilhaApresentacao {
  final String tituloSecao;
  final IconData icone;
  final Color corTema;
  final Color corFundoIcone;
  final String subtitulo;

  const TrilhaApresentacao({
    required this.tituloSecao,
    required this.icone,
    required this.corTema,
    required this.corFundoIcone,
    required this.subtitulo,
  });
}

const Map<TrilhaEnum, TrilhaApresentacao> trilhaPresentationCatalog = {
  TrilhaEnum.osQuatroRs: TrilhaApresentacao(
    tituloSecao: "TRILHA 1 - OS 4 R'S",
    icone: Icons.refresh,
    corTema: AppColors.verdeGradienteInicio,
    corFundoIcone: AppColors.verdeClaroFundo,
    subtitulo: 'Reduzir, Reutilizar, Reciclar e Reparar',
  ),
  TrilhaEnum.lixoEletronico: TrilhaApresentacao(
    tituloSecao: 'TRILHA 2 - LIXO ELETRÔNICO',
    icone: Icons.desktop_windows_outlined,
    corTema: Colors.orange,
    corFundoIcone: Color(0xFFFFF3E0),
    subtitulo: 'O problema, componentes, substâncias',
  ),
};
