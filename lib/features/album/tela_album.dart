import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/figurinha_presentation_catalog.dart';
import '../../core/models/figurinha.dart';
import '../../core/providers/figurinhas_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_indicator.dart';
import '../aprender/tela_aprender.dart';
import '../mapa/tela_mapa.dart';
import '../scanner/tela_scanner.dart';
import 'tela_info_figurinha.dart';

class TelaAlbum extends StatefulWidget {
  const TelaAlbum({super.key});

  @override
  State<TelaAlbum> createState() => _TelaAlbumState();
}

class _TelaAlbumState extends State<TelaAlbum> {
  int _abaSelecionada = 4; // Álbum selecionado por padrão

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
      body: SafeArea(
        child: provider.isLoading && provider.figurinhas.isEmpty
            ? const LoadingIndicator()
            : provider.erro != null && provider.figurinhas.isEmpty
                ? ErrorState(
                    message: provider.erro!.message,
                    onRetry: () => context.read<FigurinhasProvider>().recarregar(),
                  )
                : _construirConteudo(provider),
      ),

      // --- BARRA DE NAVEGAÇÃO INFERIOR ---
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.fundoBranco,
            border: Border(top: BorderSide(color: AppColors.bordaCinza, width: 1.0)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _construirItemNavegacao(0, Icons.location_on_outlined, 'Mapa'),
              _construirItemNavegacao(1, Icons.menu_book_outlined, 'Aprender'),
              _construirItemNavegacao(2, Icons.home_outlined, 'Início'),
              _construirItemNavegacao(3, Icons.camera_alt_outlined, 'Scanner'),
              _construirItemNavegacao(4, Icons.check_circle_outline, 'Álbum'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirConteudo(FigurinhasProvider provider) {
    final List<Figurinha> desbloqueadas = provider.desbloqueadas;
    final List<Figurinha> bloqueadas = provider.bloqueadas;
    final int total = provider.figurinhas.length;
    final double progresso = total == 0 ? 0 : desbloqueadas.length / total;

    return RefreshIndicator(
      onRefresh: () => context.read<FigurinhasProvider>().recarregar(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TOPO: LOGO + CONTADOR ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textoEscuro,
                      ),
                      children: [
                        TextSpan(text: 'Eco'),
                        TextSpan(
                          text: 'Cycle',
                          style: TextStyle(color: AppColors.verdeGradienteInicio),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.verdeClaroFundo,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.bordaVerdeClara),
                    ),
                    child: Text(
                      '${desbloqueadas.length}/$total cards',
                      style: const TextStyle(
                        color: AppColors.verdeEscuroTexto,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- BANNER VERDE (HERO) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.verdeGradienteInicio,
                    AppColors.verdeGradienteFim,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Álbum de Componentes',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoBranco,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Escaneie aparelhos e leia conteúdos para desbloquear',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.branco70,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progresso,
                      minHeight: 10,
                      backgroundColor: AppColors.branco20,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.destaqueVerdeClaro),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${desbloqueadas.length} desbloqueados',
                        style: const TextStyle(color: AppColors.branco70, fontSize: 13),
                      ),
                      Text(
                        '${(progresso * 100).round()}%',
                        style: const TextStyle(
                          color: AppColors.textoBranco,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- SEÇÃO DESBLOQUEADOS ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _construirTituloSecao('DESBLOQUEADOS'),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: desbloqueadas.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, index) {
                      return _construirCartaoDesbloqueado(desbloqueadas[index]);
                    },
                  ),
                  const SizedBox(height: 24),

                  // --- SEÇÃO BLOQUEADOS ---
                  _construirTituloSecao('BLOQUEADOS (${bloqueadas.length})'),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bloqueadas.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, index) => _construirCartaoBloqueado(),
                  ),
                  const SizedBox(height: 24),
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

  Widget _construirTituloSecao(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: AppColors.textoCinzaClaro,
      ),
    );
  }

  Widget _construirCartaoDesbloqueado(Figurinha figurinha) {
    final apresentacao = apresentacaoDaFigurinha(figurinha.codigo);
    return GestureDetector(
      onTap: () => _abrirInfoFigurinha(figurinha),
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.fundoBranco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bordaVerdeClara),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: apresentacao.corFundo,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: apresentacao.corBadgeFundo,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        apresentacao.raridade,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: apresentacao.corBadgeTexto,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(apresentacao.icone, color: apresentacao.corIcone, size: 36),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  figurinha.nome ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textoEscuro,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  figurinha.descricao ?? '',
                  style: const TextStyle(fontSize: 12, color: AppColors.textoCinzaClaro),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _construirCartaoBloqueado() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '???',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 8),
          const Icon(Icons.lock_outline, color: Color(0xFF9E9E9E), size: 32),
          const SizedBox(height: 8),
          const Text(
            'Use o scanner',
            style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }

  Widget _construirItemNavegacao(int indice, IconData icone, String rotulo) {
    final bool selecionado = _abaSelecionada == indice;
    final Color cor = selecionado ? AppColors.verdeGradienteInicio : AppColors.textoCinzaClaro;

    return GestureDetector(
      onTap: () {
        if (indice == _abaSelecionada) return;
        if (indice == 2) {
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (indice == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TelaAprender()),
          );
        } else if (indice == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TelaMapa()),
          );
        } else if (indice == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TelaScanner()),
          );
        } else {
          setState(() => _abaSelecionada = indice);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: cor, size: 24),
          const SizedBox(height: 4),
          Text(rotulo, style: TextStyle(fontSize: 11, color: cor, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: selecionado ? AppColors.verdeGradienteInicio : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
