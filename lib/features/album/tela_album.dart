import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/figurinha_presentation_catalog.dart';
import '../../core/models/figurinha.dart';
import '../../core/providers/figurinhas_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/eco_bottom_nav_bar.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/layout_eco.dart';
import '../../core/widgets/loading_indicator.dart';
import '../scanner/tela_scanner.dart';
import 'tela_info_figurinha.dart';

class TelaAlbum extends StatefulWidget {
  const TelaAlbum({super.key});

  @override
  State<TelaAlbum> createState() => _TelaAlbumState();
}

class _TelaAlbumState extends State<TelaAlbum> {
  /// null = todas; senão, só as figurinhas desse tipo.
  TipoFigurinha? _filtro;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FigurinhasProvider>().carregar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FigurinhasProvider>();

    return Scaffold(
      backgroundColor: AppColors.verdeClaroFundo,
      body: provider.isLoading && provider.figurinhas.isEmpty
          ? const Column(
              children: [
                CabecalhoEco(titulo: 'Álbum'),
                Expanded(child: LoadingIndicator()),
              ],
            )
          : provider.erro != null && provider.figurinhas.isEmpty
          ? Column(
              children: [
                const CabecalhoEco(titulo: 'Álbum'),
                Expanded(
                  child: ErrorState(
                    message: provider.erro!.message,
                    onRetry: () =>
                        context.read<FigurinhasProvider>().recarregar(),
                  ),
                ),
              ],
            )
          : _construirConteudo(provider),

      // --- BARRA DE NAVEGAÇÃO INFERIOR ---
      bottomNavigationBar: const EcoBottomNavBar(tabAtual: EcoTab.album),
    );
  }

  Widget _construirConteudo(FigurinhasProvider provider) {
    // Ordem do álbum (Nº 01, 02...), com as que faltam no lugar delas.
    final List<Figurinha> todas = [...provider.figurinhas]
      ..sort((a, b) => a.ordem.compareTo(b.ordem));
    final List<Figurinha> visiveis = _filtro == null
        ? todas
        : todas.where((f) => f.tipo == _filtro).toList();
    final int desbloqueadas = provider.desbloqueadas.length;
    final int total = todas.length;
    final List<Figurinha> faltamDoScanner = todas
        .where((f) => f.tipo == TipoFigurinha.scan && !f.desbloqueada)
        .toList();

    return RefreshIndicator(
      onRefresh: () => context.read<FigurinhasProvider>().recarregar(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CabecalhoEco(
              titulo: 'Álbum',
              conteudo: _construirResumo(desbloqueadas, total),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _construirFiltro(null, 'Todas', total),
                        const SizedBox(width: 8),
                        _construirFiltro(
                          TipoFigurinha.quiz,
                          'Quiz',
                          todas
                              .where((f) => f.tipo == TipoFigurinha.quiz)
                              .length,
                        ),
                        const SizedBox(width: 8),
                        _construirFiltro(
                          TipoFigurinha.scan,
                          'Scanner',
                          todas
                              .where((f) => f.tipo == TipoFigurinha.scan)
                              .length,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visiveis.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.66,
                        ),
                    itemBuilder: (context, index) {
                      final figurinha = visiveis[index];
                      return figurinha.desbloqueada
                          ? _construirCartaoDesbloqueado(figurinha)
                          : _construirCartaoBloqueado(figurinha);
                    },
                  ),
                  if (faltamDoScanner.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _construirDicaScanner(faltamDoScanner.length),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES PARA NÃO REPETIR CÓDIGO ---

  void _abrirInfoFigurinha(Figurinha figurinha) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaInfoFigurinha(figurinha: figurinha),
      ),
    );
  }

  Widget _construirResumo(int desbloqueadas, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: total == 0 ? 0 : desbloqueadas / total,
                    strokeWidth: 8,
                    backgroundColor: const Color(0x2EFFFFFF),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFA5D6A7),
                    ),
                  ),
                ),
                Text(
                  '$desbloqueadas/$total',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.fundoBranco,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Álbum de Componentes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.fundoBranco,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Escaneie aparelhos e conclua quizzes para completar.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: AppColors.verdeSobreCabecalho,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirFiltro(TipoFigurinha? tipo, String rotulo, int quantidade) {
    final bool selecionado = _filtro == tipo;
    return ChoiceChip(
      label: Text('$rotulo · $quantidade'),
      selected: selecionado,
      showCheckmark: false,
      onSelected: (_) => setState(() => _filtro = tipo),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: selecionado ? AppColors.fundoBranco : AppColors.textoTitulo,
      ),
      selectedColor: AppColors.verdeEscuro,
      backgroundColor: AppColors.fundoBranco,
      side: BorderSide(
        color: selecionado ? AppColors.verdeEscuro : AppColors.bordaVerdeClara,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _construirCartaoDesbloqueado(Figurinha figurinha) {
    final apresentacao = apresentacaoDaFigurinha(figurinha.codigo);
    final String numero = figurinha.ordem.toString().padLeft(2, '0');
    final String raridade =
        apresentacao.raridade[0] +
        apresentacao.raridade.substring(1).toLowerCase();

    return Material(
      color: AppColors.fundoBranco,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Color.lerp(
            apresentacao.corBadgeFundo,
            apresentacao.corIcone,
            0.3,
          )!,
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _abrirInfoFigurinha(figurinha),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: apresentacao.corFundo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    apresentacao.icone,
                    color: apresentacao.corIcone,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                figurinha.nome ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textoTitulo,
                ),
              ),
              Text(
                'Nº $numero · $raridade',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textoSecundario,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirCartaoBloqueado(Figurinha figurinha) {
    final apresentacao = apresentacaoDaFigurinha(figurinha.codigo);
    final String numero = figurinha.ordem.toString().padLeft(2, '0');
    final bool doScanner = figurinha.tipo == TipoFigurinha.scan;

    return Semantics(
      label: 'Figurinha $numero bloqueada. ${apresentacao.comoDesbloquear}',
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBDBDBD), width: 1.5),
        ),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEAEA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        doScanner
                            ? Icons.center_focus_strong_outlined
                            : Icons.lock_outline,
                        size: 16,
                        color: const Color(0xFF9E9E9E),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        numero,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFBDBDBD),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '???',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textoCinzaClaro,
                ),
              ),
              Text(
                apresentacao.comoDesbloquear,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  height: 1.2,
                  color: AppColors.textoSecundario,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirDicaScanner(int faltam) {
    return CartaoEco(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TelaScanner()),
      ),
      child: Row(
        children: [
          const IconeQuadradoEco(
            icone: Icons.photo_camera_outlined,
            cor: AppColors.azulIcone,
            corFundo: AppColors.azulFundo,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faltam == 1
                      ? 'Falta 1 figurinha do Scanner'
                      : 'Faltam $faltam figurinhas do Scanner',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textoTitulo,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Escaneie aparelhos para completar o álbum',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textoCinzaClaro),
        ],
      ),
    );
  }
}
