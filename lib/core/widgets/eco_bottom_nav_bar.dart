import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../../features/album/tela_album.dart';
import '../../features/aprender/tela_aprender.dart';
import '../../features/mapa/tela_mapa.dart';
import '../../features/scanner/tela_scanner.dart';

enum EcoTab { mapa, aprender, inicio, scanner, album }

/// Barra de navegação inferior compartilhada por todas as telas principais.
/// Cada aba (exceto "Início") navega sempre com pushAndRemoveUntil até a
/// primeira rota (a Home), evitando empilhar telas indefinidamente ao
/// alternar entre abas — a mesma estratégia que só algumas telas usavam
/// antes desta extração.
class EcoBottomNavBar extends StatelessWidget {
  final EcoTab tabAtual;

  const EcoBottomNavBar({super.key, required this.tabAtual});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.fundoBranco,
          border: Border(
            top: BorderSide(color: AppColors.bordaCinza, width: 1.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _construirItem(
              context,
              EcoTab.mapa,
              Icons.location_on_outlined,
              'Mapa',
            ),
            _construirItem(
              context,
              EcoTab.aprender,
              Icons.menu_book_outlined,
              'Aprender',
            ),
            _construirItem(
              context,
              EcoTab.inicio,
              Icons.home_outlined,
              'Início',
            ),
            _construirItem(
              context,
              EcoTab.scanner,
              Icons.camera_alt_outlined,
              'Scanner',
            ),
            _construirItem(
              context,
              EcoTab.album,
              Icons.check_circle_outline,
              'Álbum',
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirItem(
    BuildContext context,
    EcoTab tab,
    IconData icone,
    String rotulo,
  ) {
    final bool selecionado = tab == tabAtual;
    final Color cor = selecionado
        ? AppColors.verdeGradienteInicio
        : AppColors.textoCinzaClaro;

    return GestureDetector(
      onTap: selecionado ? null : () => _navegar(context, tab),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: cor, size: 24),
          const SizedBox(height: 4),
          Text(
            rotulo,
            style: TextStyle(
              fontSize: 11,
              color: cor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: selecionado
                  ? AppColors.verdeGradienteInicio
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  void _navegar(BuildContext context, EcoTab destino) {
    if (destino == EcoTab.inicio) {
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }

    final Widget tela = switch (destino) {
      EcoTab.mapa => const TelaMapa(),
      EcoTab.aprender => const TelaAprender(),
      EcoTab.scanner => const TelaScanner(),
      EcoTab.album => const TelaAlbum(),
      EcoTab.inicio => const SizedBox.shrink(),
    };

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => tela),
      (route) => route.isFirst,
    );
  }
}
