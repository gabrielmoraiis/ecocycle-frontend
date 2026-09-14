import 'package:flutter/material.dart';

import '../../core/data/figurinha_presentation_catalog.dart';
import '../../core/models/figurinha.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/eco_bottom_nav_bar.dart';

class TelaInfoFigurinha extends StatefulWidget {
  final Figurinha figurinha;

  const TelaInfoFigurinha({super.key, required this.figurinha});

  @override
  State<TelaInfoFigurinha> createState() => _TelaInfoFigurinhaState();
}

class _TelaInfoFigurinhaState extends State<TelaInfoFigurinha> {
  @override
  Widget build(BuildContext context) {
    final Figurinha figurinha = widget.figurinha;
    final apresentacao = apresentacaoDaFigurinha(figurinha.codigo);

    return Scaffold(
      backgroundColor: AppColors.verdeClaroFundo,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TOPO: VOLTAR + TÍTULO ---
            Container(
              color: AppColors.fundoBranco,
              padding: const EdgeInsets.fromLTRB(8, 8, 24, 16),
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
                  const Text(
                    'Álbum',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.verdeGradienteInicio,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- CARTÃO PRINCIPAL: ÍCONE + NOME + RARIDADE ---
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                      decoration: BoxDecoration(
                        color: AppColors.fundoBranco,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.bordaVerdeClara),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: apresentacao.corFundo,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              apresentacao.icone,
                              color: apresentacao.corIcone,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            figurinha.nome ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textoEscuro,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: apresentacao.corBadgeFundo,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              apresentacao.raridade,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: apresentacao.corBadgeTexto,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (figurinha.descricao != null &&
                        figurinha.descricao!.isNotEmpty) ...[
                      _construirSecaoInfo(
                        titulo: 'SOBRE',
                        texto: figurinha.descricao!,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // --- SUBSTÂNCIAS PRESENTES ---
                    _construirSecaoInfo(
                      titulo: 'SUBSTÂNCIAS PRESENTES',
                      texto: apresentacao.substanciasPresentes,
                    ),
                    const SizedBox(height: 16),

                    // --- RISCO AMBIENTAL ---
                    _construirSecaoInfo(
                      titulo: 'RISCO AMBIENTAL',
                      texto: apresentacao.riscoAmbiental,
                    ),
                    const SizedBox(height: 16),

                    // --- DESCARTE CORRETO ---
                    _construirSecaoInfo(
                      titulo: 'DESCARTE CORRETO',
                      texto: apresentacao.descarteCorreto,
                      corFundo: AppColors.verdeClaroFundo,
                      corBorda: AppColors.bordaVerdeClara,
                      corTitulo: AppColors.verdeEscuroTexto,
                    ),
                    const SizedBox(height: 20),

                    // --- COMO DESBLOQUEAR ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.fundoBranco,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.bordaVerdeClara),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.textoCinzaClaro,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              apresentacao.comoDesbloquear,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textoCinzaClaro,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
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

  Widget _construirSecaoInfo({
    required String titulo,
    required String texto,
    Color corFundo = AppColors.fundoBranco,
    Color corBorda = AppColors.bordaVerdeClara,
    Color corTitulo = AppColors.textoEscuro,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: corBorda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: corTitulo,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textoCinzaClaro,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
