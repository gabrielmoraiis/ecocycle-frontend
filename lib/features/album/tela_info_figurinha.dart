import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/figurinha_presentation_catalog.dart';
import '../../core/models/figurinha.dart';
import '../../core/providers/progresso_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/cartao_figurinha.dart';
import '../../core/widgets/eco_bottom_nav_bar.dart';
import '../mapa/tela_mapa.dart';
import 'tela_guia_descarte_seguro.dart';

// Cores das seções da ficha: cada informação tem a sua, para não virar uma
// sequência de caixas iguais.
const Color _azulFundo = Color(0xFFE3F2FD);
const Color _azulIcone = Color(0xFF1565C0);
const Color _laranjaFundo = Color(0xFFFFF6E5);
const Color _laranjaBorda = Color(0xFFFFD8A8);
const Color _laranjaIconeFundo = Color(0xFFFFE0B2);
const Color _laranjaIcone = Color(0xFF9A4A00);
const Color _laranjaTitulo = Color(0xFF7A3A00);
const Color _laranjaTexto = Color(0xFF5D3A12);
const Color _textoTitulo = Color(0xFF212121);
const Color _textoCorpo = Color(0xFF555555);
const Color _textoSecundario = Color(0xFF616161);
const Color _ardosia = Color(0xFF263238);

class TelaInfoFigurinha extends StatelessWidget {
  final Figurinha figurinha;

  const TelaInfoFigurinha({super.key, required this.figurinha});

  @override
  Widget build(BuildContext context) {
    final apresentacao = apresentacaoDaFigurinha(figurinha.codigo);
    final int? total = context
        .watch<ProgressoProvider>()
        .progresso
        ?.totalFigurinhas;
    final String numero = figurinha.ordem.toString().padLeft(2, '0');
    final bool temDescricao =
        figurinha.descricao != null && figurinha.descricao!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.verdeClaroFundo,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- TOPO: VOLTAR + TÍTULO + NÚMERO ---
            Container(
              color: AppColors.fundoBranco,
              padding: const EdgeInsets.fromLTRB(8, 8, 24, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: AppColors.verdeGradienteInicio,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Álbum',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.verdeGradienteInicio,
                      ),
                    ),
                  ),
                  Text(
                    total == null || total == 0
                        ? 'Nº $numero'
                        : 'Nº $numero / ${total.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: _textoSecundario,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _construirDestaque(apresentacao, temDescricao),

                    // Com descrição, o cartão "Sobre" sobe para dentro da
                    // faixa colorida; sem ela, a ficha começa logo abaixo.
                    Transform.translate(
                      offset: Offset(0, temDescricao ? -32 : 0),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (temDescricao) ...[
                              _construirSobre(figurinha.descricao!),
                              const SizedBox(height: 20),
                            ] else
                              const SizedBox(height: 20),
                            if (apresentacao.protecaoDados.isNotEmpty) ...[
                              _construirProtecaoDados(context, apresentacao),
                              const SizedBox(height: 22),
                            ],
                            const Padding(
                              padding: EdgeInsets.only(left: 4, bottom: 12),
                              child: Text(
                                'FICHA DO COMPONENTE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: _textoSecundario,
                                ),
                              ),
                            ),
                            _construirItemFicha(
                              icone: Icons.science_outlined,
                              corIcone: _azulIcone,
                              corIconeFundo: _azulFundo,
                              titulo: 'O que tem dentro',
                              texto: apresentacao.substanciasPresentes,
                              corFundo: AppColors.fundoBranco,
                              corBorda: const Color(0xFFE0E0E0),
                              corTitulo: _textoTitulo,
                              corTexto: _textoCorpo,
                            ),
                            const SizedBox(height: 12),
                            _construirItemFicha(
                              icone: Icons.warning_amber_rounded,
                              corIcone: _laranjaIcone,
                              corIconeFundo: _laranjaIconeFundo,
                              titulo: 'Risco ambiental',
                              texto: apresentacao.riscoAmbiental,
                              corFundo: _laranjaFundo,
                              corBorda: _laranjaBorda,
                              corTitulo: _laranjaTitulo,
                              corTexto: _laranjaTexto,
                            ),
                            const SizedBox(height: 12),
                            _construirDescarte(
                              context,
                              apresentacao.descarteCorreto,
                            ),
                            const SizedBox(height: 16),
                            _construirComoDesbloquear(
                              apresentacao.comoDesbloquear,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // --- BARRA DE NAVEGAÇÃO INFERIOR ---
      bottomNavigationBar: const EcoBottomNavBar(tabAtual: EcoTab.album),
    );
  }

  // --- MÉTODOS AUXILIARES PARA NÃO REPETIR CÓDIGO ---

  /// Faixa na cor da figurinha com o card inclinado e as etiquetas de
  /// raridade e origem.
  Widget _construirDestaque(
    FigurinhaApresentacao apresentacao,
    bool temDescricao,
  ) {
    return Container(
      color: apresentacao.corBadgeFundo,
      padding: EdgeInsets.fromLTRB(24, 28, 24, temDescricao ? 56 : 28),
      child: Column(
        children: [
          CartaoFigurinha(figurinha: figurinha),
          const SizedBox(height: 18),
          EtiquetasFigurinha(figurinha: figurinha),
        ],
      ),
    );
  }

  /// "Antes de descartar: proteja seus dados", para aparelhos que guardam
  /// dados pessoais. HD e notebook levam ao guia completo de limpeza.
  Widget _construirProtecaoDados(
    BuildContext context,
    FigurinhaApresentacao apresentacao,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _ardosia,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40263238),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _construirIconeFicha(
                Icons.shield_outlined,
                AppColors.fundoBranco,
                const Color(0x1FFFFFFF),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ANTES DE DESCARTAR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Color(0xFFB0BEC5),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Proteja seus dados',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.fundoBranco,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Color(0xFFECEFF1),
              ),
              children: [
                TextSpan(
                  text:
                      'Este aparelho guarda fotos, senhas e documentos. Apagar arquivos ou formatar ',
                ),
                TextSpan(
                  text: 'não remove',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      ' os dados de verdade: eles ainda podem ser recuperados.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < apresentacao.protecaoDados.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFA5D6A7),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      apresentacao.protecaoDados[i],
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.fundoBranco,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (apresentacao.temGuiaDescarteSeguro) ...[
            const SizedBox(height: 6),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TelaGuiaDescarteSeguro(aparelho: figurinha.nome ?? 'HD'),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.fundoBranco,
                foregroundColor: _ardosia,
                minimumSize: const Size.fromHeight(48),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ver passo a passo',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _construirSobre(String descricao) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.fundoBranco,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bordaVerdeClara),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SOBRE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: _textoSecundario,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            descricao,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textoEscuro,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirItemFicha({
    required IconData icone,
    required Color corIcone,
    required Color corIconeFundo,
    required String titulo,
    required String texto,
    required Color corFundo,
    required Color corBorda,
    required Color corTitulo,
    required Color corTexto,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: corBorda),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _construirIconeFicha(icone, corIcone, corIconeFundo),
          const SizedBox(width: 14),
          Expanded(
            child: _construirTextoFicha(titulo, texto, corTitulo, corTexto),
          ),
        ],
      ),
    );
  }

  /// "Como descartar" é a ação que importa na tela: cartão verde cheio, com
  /// atalho para o mapa de pontos de coleta.
  Widget _construirDescarte(BuildContext context, String texto) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.verdeGradienteInicio,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _construirIconeFicha(
                Icons.recycling,
                AppColors.fundoBranco,
                AppColors.branco20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _construirTextoFicha(
                  'Como descartar',
                  texto,
                  AppColors.fundoBranco,
                  AppColors.fundoBranco,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TelaMapa()),
            ),
            icon: const Icon(Icons.place_outlined, size: 18),
            label: const Text(
              'Ver pontos de coleta',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.fundoBranco,
              foregroundColor: const Color(0xFF1B5E20),
              minimumSize: const Size.fromHeight(48),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirIconeFicha(IconData icone, Color cor, Color corFundo) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icone, color: cor, size: 22),
    );
  }

  Widget _construirTextoFicha(
    String titulo,
    String texto,
    Color corTitulo,
    Color corTexto,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: corTitulo,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          texto,
          style: TextStyle(fontSize: 14, color: corTexto, height: 1.45),
        ),
      ],
    );
  }

  Widget _construirComoDesbloquear(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          const Icon(
            Icons.lock_open_outlined,
            size: 18,
            color: _textoSecundario,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Desbloqueada ${_minusculaInicial(texto)}',
              style: const TextStyle(
                fontSize: 13,
                color: _textoSecundario,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // "Escaneando um mouse..." -> "escaneando um mouse...", para encaixar
  // depois de "Desbloqueada".
  static String _minusculaInicial(String texto) =>
      texto.isEmpty ? texto : texto[0].toLowerCase() + texto.substring(1);
}
