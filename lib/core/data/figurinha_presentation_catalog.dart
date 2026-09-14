import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class FigurinhaApresentacao {
  final IconData icone;
  final String raridade;
  final Color corFundo;
  final Color corIcone;
  final Color corBadgeFundo;
  final Color corBadgeTexto;
  final String substanciasPresentes;
  final String riscoAmbiental;
  final String descarteCorreto;
  final String comoDesbloquear;

  const FigurinhaApresentacao({
    required this.icone,
    required this.raridade,
    required this.corFundo,
    required this.corIcone,
    required this.corBadgeFundo,
    required this.corBadgeTexto,
    required this.substanciasPresentes,
    required this.riscoAmbiental,
    required this.descarteCorreto,
    required this.comoDesbloquear,
  });
}

const FigurinhaApresentacao _padrao = FigurinhaApresentacao(
  icone: Icons.eco_outlined,
  raridade: 'COMUM',
  corFundo: AppColors.verdeClaroFundo,
  corIcone: AppColors.verdeGradienteInicio,
  corBadgeFundo: AppColors.bordaVerdeClara,
  corBadgeTexto: AppColors.verdeEscuroTexto,
  substanciasPresentes: 'Informação não disponível.',
  riscoAmbiental: 'Informação não disponível.',
  descarteCorreto: 'Consulte um ponto de coleta de eletrônicos.',
  comoDesbloquear: 'Concluindo o conteúdo educativo relacionado.',
);

const Map<String, FigurinhaApresentacao> _catalogo = {
  'FIG-01': FigurinhaApresentacao(
    icone: Icons.refresh,
    raridade: 'COMUM',
    corFundo: Color(0xFFE1F0E2),
    corIcone: AppColors.verdeGradienteInicio,
    corBadgeFundo: Color(0xFFC8E6C9),
    corBadgeTexto: AppColors.verdeEscuroTexto,
    substanciasPresentes:
        'Materiais recicláveis do cotidiano: plástico, alumínio e vidro.',
    riscoAmbiental:
        'Descartados incorretamente, levam décadas para se decompor em aterros.',
    descarteCorreto:
        'Separe e leve à coleta seletiva ou cooperativa de reciclagem.',
    comoDesbloquear: 'Concluindo o quiz de Reciclar.',
  ),
  'FIG-02': FigurinhaApresentacao(
    icone: Icons.autorenew,
    raridade: 'COMUM',
    corFundo: Color(0xFFE1F0E2),
    corIcone: AppColors.verdeGradienteInicio,
    corBadgeFundo: Color(0xFFC8E6C9),
    corBadgeTexto: AppColors.verdeEscuroTexto,
    substanciasPresentes: 'Materiais reaproveitáveis antes de virarem resíduo.',
    riscoAmbiental:
        'Descartar sem reutilizar aumenta o volume de lixo desnecessariamente.',
    descarteCorreto: 'Reutilize sempre que possível antes de descartar.',
    comoDesbloquear: 'Concluindo o quiz de Reutilizar.',
  ),
  'FIG-03': FigurinhaApresentacao(
    icone: Icons.replay,
    raridade: 'COMUM',
    corFundo: Color(0xFFE1F0E2),
    corIcone: AppColors.verdeGradienteInicio,
    corBadgeFundo: Color(0xFFC8E6C9),
    corBadgeTexto: AppColors.verdeEscuroTexto,
    substanciasPresentes:
        'Bens de consumo evitáveis com hábitos mais conscientes.',
    riscoAmbiental:
        'O consumo excessivo aumenta a extração de recursos naturais.',
    descarteCorreto: 'Reduza o consumo antes de precisar descartar.',
    comoDesbloquear: 'Concluindo o quiz de Reduzir.',
  ),
  'FIG-04': FigurinhaApresentacao(
    icone: Icons.build_outlined,
    raridade: 'RARO',
    corFundo: Color(0xFFEBDFF3),
    corIcone: Colors.purple,
    corBadgeFundo: Color(0xFFE1BEE7),
    corBadgeTexto: Colors.purple,
    substanciasPresentes:
        'Componentes que podem ser consertados em vez de descartados.',
    riscoAmbiental: 'Trocar em vez de reparar gera lixo eletrônico evitável.',
    descarteCorreto:
        'Procure assistência técnica antes de descartar aparelhos com defeito.',
    comoDesbloquear: 'Concluindo o quiz de Reparar.',
  ),
  'FIG-05': FigurinhaApresentacao(
    icone: Icons.desktop_windows_outlined,
    raridade: 'COMUM',
    corFundo: Color(0xFFDDEBFB),
    corIcone: Colors.blue,
    corBadgeFundo: Color(0xFFBBDEFB),
    corBadgeTexto: Colors.blue,
    substanciasPresentes: 'Lixo eletrônico em geral: aparelhos fora de uso.',
    riscoAmbiental:
        'É um dos resíduos que mais cresce no mundo e um dos menos reciclados.',
    descarteCorreto: 'Leve a pontos de coleta especializados em eletrônicos.',
    comoDesbloquear: 'Concluindo o quiz sobre o problema do lixo eletrônico.',
  ),
  'FIG-06': FigurinhaApresentacao(
    icone: Icons.memory,
    raridade: 'ÉPICO',
    corFundo: Color(0xFFE1F0E2),
    corIcone: AppColors.verdeGradienteInicio,
    corBadgeFundo: Color(0xFFC8E6C9),
    corBadgeTexto: AppColors.verdeEscuroTexto,
    substanciasPresentes:
        'Chumbo, ouro e paládio presentes nos circuitos eletrônicos.',
    riscoAmbiental:
        'Contamina solo e água; o chumbo é neurotóxico e persiste por décadas.',
    descarteCorreto:
        'Leve a um ponto de coleta de eletrônicos ou cooperativa especializada.',
    comoDesbloquear: 'Concluindo o quiz sobre componentes eletrônicos.',
  ),
  'FIG-07': FigurinhaApresentacao(
    icone: Icons.recycling_outlined,
    raridade: 'RARO',
    corFundo: Color(0xFFFBEFD2),
    corIcone: Colors.orange,
    corBadgeFundo: Color(0xFFFFE0B2),
    corBadgeTexto: Colors.orange,
    substanciasPresentes:
        'Diversas substâncias tóxicas presentes em aparelhos descartados incorretamente.',
    riscoAmbiental:
        'O descarte fora de pontos especializados contamina solo e água.',
    descarteCorreto:
        'Use a aba Mapa para encontrar o ponto de coleta mais próximo.',
    comoDesbloquear: 'Concluindo o quiz sobre onde e como descartar.',
  ),
  'FIG-08': FigurinhaApresentacao(
    icone: Icons.battery_full_outlined,
    raridade: 'RARO',
    corFundo: Color(0xFFFBEFD2),
    corIcone: Colors.orange,
    corBadgeFundo: Color(0xFFFFE0B2),
    corBadgeTexto: Colors.orange,
    substanciasPresentes:
        'Lítio, cobalto e manganês - metais tóxicos se descartados incorretamente.',
    riscoAmbiental:
        'Contamina solo e lençol freático; pode causar incêndios em aterros sanitários.',
    descarteCorreto:
        'Leve ao ponto de coleta mais próximo. Nunca no lixo comum.',
    comoDesbloquear: 'Escaneando uma bateria de lítio com o Scanner IA.',
  ),
  'FIG-09': FigurinhaApresentacao(
    icone: Icons.developer_board,
    raridade: 'ÉPICO',
    corFundo: Color(0xFFE1F0E2),
    corIcone: AppColors.verdeGradienteInicio,
    corBadgeFundo: Color(0xFFC8E6C9),
    corBadgeTexto: AppColors.verdeEscuroTexto,
    substanciasPresentes:
        'Chumbo, ouro e paládio - metais preciosos e tóxicos presentes nos circuitos.',
    riscoAmbiental:
        'Contamina solo e água. O chumbo é neurotóxico e persiste no ambiente por décadas.',
    descarteCorreto:
        'Leve a um ponto de coleta de eletrônicos ou cooperativa de reciclagem especializada.',
    comoDesbloquear: 'Escaneando uma placa-mãe com o Scanner IA.',
  ),
  'FIG-10': FigurinhaApresentacao(
    icone: Icons.cable,
    raridade: 'COMUM',
    corFundo: Color(0xFFFAD9E1),
    corIcone: Colors.pink,
    corBadgeFundo: Color(0xFFF8BBD0),
    corBadgeTexto: Colors.pink,
    substanciasPresentes:
        'Cobre e PVC - metal reciclável envolto em plástico não biodegradável.',
    riscoAmbiental:
        'O PVC libera dioxinas tóxicas quando queimado incorretamente.',
    descarteCorreto:
        'Separe o cobre do plástico em cooperativas de reciclagem, se possível.',
    comoDesbloquear: 'Escaneando um cabo USB com o Scanner IA.',
  ),
};

FigurinhaApresentacao apresentacaoDaFigurinha(String codigo) =>
    _catalogo[codigo] ?? _padrao;
