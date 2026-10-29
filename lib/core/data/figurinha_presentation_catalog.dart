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

  /// Passos curtos para proteger os dados pessoais antes do descarte, para
  /// aparelhos que guardam dados (HD, notebook, celular). Vazio = sem seção.
  final List<String> protecaoDados;

  /// Mostra o botão do guia completo de descarte seguro (apagar o disco).
  final bool temGuiaDescarteSeguro;

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
    this.protecaoDados = const [],
    this.temGuiaDescarteSeguro = false,
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
    icone: Icons.battery_std_outlined,
    raridade: 'RARO',
    corFundo: Color(0xFFFBEFD2),
    corIcone: Colors.orange,
    corBadgeFundo: Color(0xFFFFE0B2),
    corBadgeTexto: Colors.orange,
    substanciasPresentes:
        'Zinco e manganês e, em alguns modelos, mercúrio, cádmio ou chumbo.',
    riscoAmbiental:
        'Ao se romper, vaza metais pesados que contaminam o solo e o lençol freático.',
    descarteCorreto:
        'Guarde em um pote fechado e entregue em um ponto de coleta de pilhas. Nunca no lixo comum.',
    comoDesbloquear: 'Escaneando uma pilha com o Scanner IA.',
  ),
  'FIG-09': FigurinhaApresentacao(
    icone: Icons.mouse_outlined,
    raridade: 'ÉPICO',
    corFundo: Color(0xFFE1F0E2),
    corIcone: AppColors.verdeGradienteInicio,
    corBadgeFundo: Color(0xFFC8E6C9),
    corBadgeTexto: AppColors.verdeEscuroTexto,
    substanciasPresentes:
        'Plástico, fios de cobre e uma pequena placa de circuito com solda de chumbo.',
    riscoAmbiental:
        'A placa interna pode liberar chumbo no solo e na água; o plástico leva séculos para se decompor.',
    descarteCorreto:
        'Retire as pilhas, se houver, e leve o mouse a um ponto de coleta de eletrônicos.',
    comoDesbloquear: 'Escaneando um mouse com o Scanner IA.',
  ),
  'FIG-10': FigurinhaApresentacao(
    icone: Icons.iron_outlined,
    raridade: 'COMUM',
    corFundo: Color(0xFFFAD9E1),
    corIcone: Colors.pink,
    corBadgeFundo: Color(0xFFF8BBD0),
    corBadgeTexto: Colors.pink,
    substanciasPresentes:
        'Aço, alumínio e cobre na base e na resistência, além de plásticos e fios revestidos.',
    riscoAmbiental:
        'No lixo comum, desperdiça metais recicláveis e o plástico e o PVC dos fios poluem por décadas.',
    descarteCorreto:
        'Leve a um ponto de coleta de eletroeletrônicos ou a uma assistência técnica que receba aparelhos.',
    comoDesbloquear: 'Escaneando um ferro de passar com o Scanner IA.',
  ),
  'FIG-11': FigurinhaApresentacao(
    icone: Icons.smartphone_outlined,
    raridade: 'RARO',
    corFundo: Color(0xFFFBEFD2),
    corIcone: Colors.orange,
    corBadgeFundo: Color(0xFFFFE0B2),
    corBadgeTexto: Colors.orange,
    substanciasPresentes:
        'Bateria de íon-lítio, cobre, ouro e prata nos contatos, e solda com chumbo na placa.',
    riscoAmbiental:
        'A bateria pode pegar fogo se for amassada ou furada; no lixo comum, os metais da placa contaminam o solo e a água.',
    descarteCorreto:
        'Proteja seus dados, não tente tirar a bateria à força e leve o aparelho inteiro a um ponto de coleta de eletrônicos.',
    comoDesbloquear: 'Escaneando um celular com o Scanner IA.',
    protecaoDados: [
      'Faça backup de fotos e contatos',
      'Saia das suas contas (Google ou Apple)',
      'Restaure as configurações de fábrica',
      'Retire o chip e o cartão de memória',
    ],
  ),
  'FIG-12': FigurinhaApresentacao(
    icone: Icons.monitor_outlined,
    raridade: 'COMUM',
    corFundo: Color(0xFFE3F2FD),
    corIcone: Color(0xFF1E88E5),
    corBadgeFundo: Color(0xFFBBDEFB),
    corBadgeTexto: Color(0xFF1565C0),
    substanciasPresentes:
        'Monitores antigos de tubo (CRT) têm chumbo no vidro e alguns LCD antigos usam lâmpadas com mercúrio. Os atuais têm vidro, plástico e placas de circuito.',
    riscoAmbiental:
        'Quebrados, o vidro e as lâmpadas liberam chumbo e mercúrio, que contaminam o solo e fazem mal se inalados.',
    descarteCorreto:
        'Não quebre nem desmonte. Leve o monitor inteiro a um ponto de coleta de eletroeletrônicos.',
    comoDesbloquear: 'Escaneando um monitor com o Scanner IA.',
  ),
  'FIG-13': FigurinhaApresentacao(
    icone: Icons.keyboard_outlined,
    raridade: 'COMUM',
    corFundo: Color(0xFFF3E5F5),
    corIcone: Color(0xFF8E24AA),
    corBadgeFundo: Color(0xFFE1BEE7),
    corBadgeTexto: Color(0xFF6A1B9A),
    substanciasPresentes:
        'Plástico ABS, membrana de silicone, fios de cobre e uma placa com solda de chumbo.',
    riscoAmbiental:
        'O plástico leva séculos para se decompor e a placa interna pode liberar chumbo no ambiente.',
    descarteCorreto:
        'Se ainda funciona, doe. Se não, retire as pilhas (nos sem fio) e leve a um ponto de coleta de eletrônicos.',
    comoDesbloquear: 'Escaneando um teclado com o Scanner IA.',
  ),
  'FIG-14': FigurinhaApresentacao(
    icone: Icons.laptop_outlined,
    raridade: 'ÉPICO',
    corFundo: Color(0xFFE0F2F1),
    corIcone: Color(0xFF00897B),
    corBadgeFundo: Color(0xFFB2DFDB),
    corBadgeTexto: Color(0xFF00695C),
    substanciasPresentes:
        'Bateria de íon-lítio, placa-mãe com chumbo e metais preciosos, HD ou SSD, tela de LCD e carcaça de plástico ou alumínio.',
    riscoAmbiental:
        'A bateria pode pegar fogo e os metais da placa contaminam o ambiente. E o disco interno guarda seus dados pessoais.',
    descarteCorreto:
        'Proteja seus dados e leve o notebook inteiro a um ponto de coleta de eletrônicos. Se ainda funciona, considere doar.',
    comoDesbloquear: 'Escaneando um notebook com o Scanner IA.',
    protecaoDados: [
      'Faça backup dos seus arquivos',
      'Saia das suas contas e do "Encontrar meu dispositivo"',
      'Apague o disco com limpeza segura',
      'Leve o notebook inteiro a um ponto de coleta',
    ],
    temGuiaDescarteSeguro: true,
  ),
  'FIG-15': FigurinhaApresentacao(
    icone: Icons.developer_board_outlined,
    raridade: 'RARO',
    corFundo: Color(0xFFF1F8E9),
    corIcone: Color(0xFF558B2F),
    corBadgeFundo: Color(0xFFDCEDC8),
    corBadgeTexto: Color(0xFF33691E),
    substanciasPresentes:
        'Cobre, ouro, prata e paládio nos contatos, solda de chumbo e estanho, e resina de fibra de vidro.',
    riscoAmbiental:
        'É a parte mais valiosa e também a mais tóxica do lixo eletrônico: queimada ou no lixo comum, libera chumbo e outros metais pesados.',
    descarteCorreto:
        'Nunca queime nem jogue no lixo comum. Leve a um ponto de coleta: os metais são recuperados na reciclagem.',
    comoDesbloquear: 'Escaneando uma placa de circuito com o Scanner IA.',
  ),
  'FIG-16': FigurinhaApresentacao(
    icone: Icons.storage_outlined,
    raridade: 'ÉPICO',
    corFundo: Color(0xFFECEFF1),
    corIcone: Color(0xFF455A64),
    corBadgeFundo: Color(0xFFCFD8DC),
    corBadgeTexto: Color(0xFF263238),
    substanciasPresentes:
        'Carcaça de alumínio, discos metálicos, ímãs de neodímio (terras-raras) e uma placa de circuito com solda de chumbo.',
    riscoAmbiental:
        'No lixo comum, o chumbo da placa contamina o solo e os metais se perdem. E um HD descartado sem limpeza expõe seus dados pessoais.',
    descarteCorreto:
        'Depois de proteger os dados, leve o HD a um ponto de coleta de eletrônicos.',
    comoDesbloquear: 'Escaneando um HD com o Scanner IA.',
    protecaoDados: [
      'Faça backup do que quer guardar',
      'Apague os dados com limpeza segura',
      'HD quebrado? Destruição por serviço especializado',
      'Leve a um ponto de coleta de eletrônicos',
    ],
    temGuiaDescarteSeguro: true,
  ),
};

FigurinhaApresentacao apresentacaoDaFigurinha(String codigo) =>
    _catalogo[codigo] ?? _padrao;
