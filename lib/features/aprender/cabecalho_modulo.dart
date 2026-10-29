import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Barra do topo do módulo: voltar, "TRILHA · MÓDULO X DE Y" e o progresso
/// da trilha em segmentos (concluídos, atual e restantes).
class CabecalhoModulo extends StatelessWidget {
  final String rotuloTrilha;
  final int numeroAtual;
  final int total;

  const CabecalhoModulo({
    super.key,
    required this.rotuloTrilha,
    required this.numeroAtual,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 10),
      decoration: const BoxDecoration(
        color: AppColors.fundoBranco,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Material(
            color: AppColors.verdeClaroFundo,
            shape: const CircleBorder(),
            child: IconButton(
              icon: const Icon(
                Icons.chevron_left,
                color: AppColors.verdeGradienteInicio,
              ),
              tooltip: 'Voltar',
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${rotuloTrilha.toUpperCase()} · MÓDULO $numeroAtual DE $total',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: AppColors.textoSecundario,
                  ),
                ),
                const SizedBox(height: 6),
                _construirSegmentos(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirSegmentos() {
    final int indiceAtual = numeroAtual - 1;
    return Row(
      children: [
        for (int i = 0; i < total; i++) ...[
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: i < indiceAtual
                    ? AppColors.verdeGradienteInicio
                    : i == indiceAtual
                    ? const Color(0xFFA5D6A7)
                    : const Color(0xFFEEEEEE),
              ),
            ),
          ),
          if (i != total - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }
}
