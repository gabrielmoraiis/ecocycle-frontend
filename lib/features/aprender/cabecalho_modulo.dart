import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CabecalhoModulo extends StatelessWidget {
  final String rotuloTrilha;
  final String titulo;
  final int numeroAtual;
  final int total;

  const CabecalhoModulo({
    super.key,
    required this.rotuloTrilha,
    required this.titulo,
    required this.numeroAtual,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.verdeGradienteInicio, AppColors.verdeGradienteFim],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MÓDULO $numeroAtual DE $total - $rotuloTrilha',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppColors.branco70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textoBranco,
            ),
          ),
          const SizedBox(height: 16),
          _construirBarraProgresso(),
        ],
      ),
    );
  }

  Widget _construirBarraProgresso() {
    final int indiceAtual = numeroAtual - 1;

    return Row(
      children: [
        for (int i = 0; i < total; i++) ...[
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 8,
                color: i < indiceAtual
                    ? AppColors.destaqueVerdeClaro
                    : i == indiceAtual
                    ? AppColors.fundoBranco
                    : AppColors.branco20,
              ),
            ),
          ),
          if (i != total - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}
