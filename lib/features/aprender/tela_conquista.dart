import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../album/tela_album.dart';
import 'tela_aprender.dart';

const Color _fundoEscuro = Color(0xFF10190F);
const Color _painelEscuro = Color(0xFF1E2B1C);
const Color _bordaDourada = Color(0xFFE9C86A);
const Color _fundoCartaoClaro = Color(0xFFFFF8E7);

class RecompensaModulo {
  final IconData icone;
  final String raridade;
  final Color corRaridade;
  final String nomeFigurinha;
  final String categoriaFigurinha;
  final int xpGanho;
  final int figurinhasDesbloqueadas;
  final int totalFigurinhas;

  const RecompensaModulo({
    required this.icone,
    required this.raridade,
    required this.corRaridade,
    required this.nomeFigurinha,
    required this.categoriaFigurinha,
    required this.xpGanho,
    required this.figurinhasDesbloqueadas,
    required this.totalFigurinhas,
  });
}

const RecompensaModulo recompensaModuloReciclar = RecompensaModulo(
  icone: Icons.refresh,
  raridade: 'COMUM',
  corRaridade: Colors.orange,
  nomeFigurinha: 'Símbolo Reciclagem',
  categoriaFigurinha: 'Álbum - 4Rs',
  xpGanho: 50,
  figurinhasDesbloqueadas: 6,
  totalFigurinhas: 12,
);

class TelaConquista extends StatelessWidget {
  final RecompensaModulo recompensa;

  const TelaConquista({super.key, required this.recompensa});

  @override
  Widget build(BuildContext context) {
    final double progresso = recompensa.figurinhasDesbloqueadas / recompensa.totalFigurinhas;

    return Scaffold(
      backgroundColor: _fundoEscuro,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Text(
                'Módulo concluído!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textoBranco),
              ),
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                decoration: BoxDecoration(
                  color: _fundoCartaoClaro,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _bordaDourada, width: 1.5),
                ),
                child: Column(
                  children: [
                    Icon(recompensa.icone, color: AppColors.verdeGradienteInicio, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      recompensa.raridade,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: recompensa.corRaridade,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      recompensa.nomeFigurinha,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textoEscuro),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recompensa.categoriaFigurinha,
                      style: const TextStyle(fontSize: 14, color: AppColors.textoCinzaClaro),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.branco20,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, color: AppColors.destaqueVerdeClaro, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '+${recompensa.xpGanho} XP ganhos',
                      style: const TextStyle(
                        color: AppColors.destaqueVerdeClaro,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: _painelEscuro, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    const Text(
                      'Progresso do álbum',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.destaqueVerdeClaro),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progresso,
                        minHeight: 8,
                        backgroundColor: AppColors.branco20,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.destaqueVerdeClaro),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${recompensa.figurinhasDesbloqueadas} de ${recompensa.totalFigurinhas} figurinhas desbloqueadas',
                      style: const TextStyle(fontSize: 13, color: AppColors.branco70),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _irParaProximoModulo(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.destaqueVerdeClaro,
                        foregroundColor: AppColors.textoEscuro,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Próximo módulo',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _abrirAlbum(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _painelEscuro,
                        foregroundColor: AppColors.textoBranco,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Ver álbum', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _irParaProximoModulo(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TelaAprender()),
      (route) => route.isFirst,
    );
  }

  void _abrirAlbum(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TelaAlbum()),
      (route) => route.isFirst,
    );
  }
}
