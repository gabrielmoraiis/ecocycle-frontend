import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/figurinha_presentation_catalog.dart';
import '../../core/models/resultado_submissao.dart';
import '../../core/providers/progresso_provider.dart';
import '../../core/theme/app_colors.dart';
import '../album/tela_album.dart';
import 'tela_aprender.dart';

const Color _fundoEscuro = Color(0xFF10190F);
const Color _painelEscuro = Color(0xFF1E2B1C);
const Color _bordaDourada = Color(0xFFE9C86A);
const Color _fundoCartaoClaro = Color(0xFFFFF8E7);

class TelaConquista extends StatelessWidget {
  final ResultadoSubmissao resultado;

  const TelaConquista({super.key, required this.resultado});

  @override
  Widget build(BuildContext context) {
    final figurinha = resultado.figurinhaDesbloqueada;

    return Scaffold(
      backgroundColor: _fundoEscuro,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Quiz concluído! ${resultado.acertos}/${resultado.totalPerguntas} acertos',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textoBranco,
                        ),
                      ),
                      const SizedBox(height: 48),
                      if (figurinha != null)
                        _construirCartaoFigurinha(
                          figurinha.codigo,
                          figurinha.nome ?? '',
                          figurinha.descricao ?? '',
                        )
                      else
                        _construirCartaoSemFigurinha(),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.branco20,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bolt,
                              color: AppColors.destaqueVerdeClaro,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+${resultado.xpGanho} XP ganhos',
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
                      Consumer<ProgressoProvider>(
                        builder: (context, progressoProvider, _) {
                          final progresso = progressoProvider.progresso;
                          final desbloqueadas =
                              progresso?.figurinhasDesbloqueadas ?? 0;
                          final total = progresso?.totalFigurinhas ?? 10;
                          final valor = total == 0
                              ? 0.0
                              : desbloqueadas / total;

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _painelEscuro,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Progresso do álbum',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.destaqueVerdeClaro,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: valor,
                                    minHeight: 8,
                                    backgroundColor: AppColors.branco20,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          AppColors.destaqueVerdeClaro,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '$desbloqueadas de $total figurinhas desbloqueadas',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.branco70,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _irParaProximoModulo(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.destaqueVerdeClaro,
                        foregroundColor: AppColors.textoEscuro,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Voltar às trilhas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ver álbum',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _construirCartaoFigurinha(
    String codigo,
    String nome,
    String descricao,
  ) {
    final apresentacao = apresentacaoDaFigurinha(codigo);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: _fundoCartaoClaro,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _bordaDourada, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(
            apresentacao.icone,
            color: AppColors.verdeGradienteInicio,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            apresentacao.raridade,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: apresentacao.corIcone,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            nome,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textoEscuro,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            descricao,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textoCinzaClaro,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCartaoSemFigurinha() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: _painelEscuro,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.branco20, width: 1.5),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.destaqueVerdeClaro,
            size: 56,
          ),
          SizedBox(height: 16),
          Text(
            'Quiz concluído!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textoBranco,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Nenhuma figurinha nova desta vez.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.branco70),
          ),
        ],
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
