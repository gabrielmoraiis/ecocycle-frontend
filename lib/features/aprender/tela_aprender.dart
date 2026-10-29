import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/trilha_presentation_catalog.dart';
import '../../core/models/trilha.dart' as api;
import '../../core/providers/progresso_provider.dart';
import '../../core/providers/trilhas_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/eco_bottom_nav_bar.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/layout_eco.dart';
import '../../core/widgets/loading_indicator.dart';
import 'tela_modulo.dart';

class ModuloTrilha {
  final int conteudoId;
  final String nome;
  final bool concluido;
  final bool lido;

  const ModuloTrilha({
    required this.conteudoId,
    required this.nome,
    required this.concluido,
    this.lido = false,
  });
}

class TrilhaAprendizado {
  final String tituloSecao;
  final IconData icone;
  final Color corTema;
  final Color corFundoIcone;
  final String titulo;
  final String subtitulo;
  final String ilustracao;
  final List<ModuloTrilha> modulos;

  const TrilhaAprendizado({
    required this.tituloSecao,
    required this.icone,
    required this.corTema,
    required this.corFundoIcone,
    required this.titulo,
    required this.subtitulo,
    required this.ilustracao,
    required this.modulos,
  });

  factory TrilhaAprendizado.fromApi(api.Trilha trilha) {
    final apresentacao = trilhaPresentationCatalog[trilha.trilha]!;
    return TrilhaAprendizado(
      tituloSecao: apresentacao.tituloSecao,
      icone: apresentacao.icone,
      corTema: apresentacao.corTema,
      corFundoIcone: apresentacao.corFundoIcone,
      titulo: trilha.nomeExibicao,
      subtitulo: apresentacao.subtitulo,
      ilustracao: apresentacao.ilustracao,
      modulos: trilha.conteudos
          .map(
            (c) => ModuloTrilha(
              conteudoId: c.id,
              nome: c.titulo,
              concluido: c.quizConcluido,
              lido: c.lido,
            ),
          )
          .toList(),
    );
  }

  int get concluidos => modulos.where((modulo) => modulo.concluido).length;

  double get progresso => modulos.isEmpty ? 0 : concluidos / modulos.length;

  /// Índice do primeiro módulo com quiz pendente, ou -1 se tudo concluído.
  int get indiceProximo => modulos.indexWhere((modulo) => !modulo.concluido);
}

class TelaAprender extends StatefulWidget {
  const TelaAprender({super.key});

  @override
  State<TelaAprender> createState() => _TelaAprenderState();
}

class _TelaAprenderState extends State<TelaAprender> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrilhasProvider>().carregar();
      context.read<ProgressoProvider>().carregar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final trilhasProvider = context.watch<TrilhasProvider>();
    final int xp = context.watch<ProgressoProvider>().progresso?.xpTotal ?? 0;
    final List<TrilhaAprendizado> trilhas = trilhasProvider.trilhas
        .map(TrilhaAprendizado.fromApi)
        .toList();
    final int totalModulos = trilhas.fold(
      0,
      (soma, trilha) => soma + trilha.modulos.length,
    );
    final int modulosConcluidos = trilhas.fold(
      0,
      (soma, trilha) => soma + trilha.concluidos,
    );

    return Scaffold(
      backgroundColor: AppColors.verdeClaroFundo,
      body: trilhasProvider.isLoading && trilhasProvider.trilhas.isEmpty
          ? const Column(
              children: [
                CabecalhoEco(titulo: 'Aprender'),
                Expanded(child: LoadingIndicator()),
              ],
            )
          : trilhasProvider.erro != null && trilhasProvider.trilhas.isEmpty
          ? Column(
              children: [
                const CabecalhoEco(titulo: 'Aprender'),
                Expanded(
                  child: ErrorState(
                    message: trilhasProvider.erro!.message,
                    onRetry: () => context.read<TrilhasProvider>().recarregar(),
                  ),
                ),
              ],
            )
          : RefreshIndicator(
              onRefresh: () => context.read<TrilhasProvider>().recarregar(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CabecalhoEco(
                      titulo: 'Aprender',
                      espacoInferior: 56,
                      conteudo: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SUA JORNADA EDUCATIVA',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: AppColors.bordaVerdeClara,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Escolha uma trilha',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppColors.fundoBranco,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // O resumo sobe para dentro da faixa verde.
                    Transform.translate(
                      offset: const Offset(0, -36),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _construirResumo(
                              modulosConcluidos,
                              totalModulos,
                              xp,
                            ),
                            for (final trilha in trilhas) ...[
                              const SizedBox(height: 22),
                              TituloSecaoEco(
                                trilha.tituloSecao.replaceAll(' - ', ' · '),
                              ),
                              _construirCartaoTrilha(trilha),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

      // --- BARRA DE NAVEGAÇÃO INFERIOR ---
      bottomNavigationBar: const EcoBottomNavBar(tabAtual: EcoTab.aprender),
    );
  }

  // --- MÉTODOS AUXILIARES PARA NÃO REPETIR CÓDIGO ---

  Future<void> _abrirModulo(
    TrilhaAprendizado trilha,
    ModuloTrilha modulo,
    int indice,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaModulo(
          rotuloTrilha: trilha.tituloSecao.split(' - ').first,
          tituloModulo: modulo.nome,
          numeroModulo: indice + 1,
          totalModulos: trilha.modulos.length,
          conteudoId: modulo.conteudoId,
        ),
      ),
    );
    if (!mounted) return;
    context.read<TrilhasProvider>().recarregar();
  }

  Widget _construirResumo(int concluidos, int total, int xp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fundoBranco,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: total == 0 ? 0 : concluidos / total,
                    strokeWidth: 7,
                    backgroundColor: AppColors.verdeSobreCabecalho,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.verdeGradienteInicio,
                    ),
                  ),
                ),
                Text(
                  '$concluidos/$total',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.verdeEscuro,
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
                  'Módulos concluídos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textoTitulo,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cada quiz feito libera uma figurinha',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.laranjaFundo,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, size: 14, color: AppColors.laranjaIcone),
                const SizedBox(width: 2),
                Text(
                  '$xp',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.laranjaTexto,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCartaoTrilha(TrilhaAprendizado trilha) {
    final int proximo = trilha.indiceProximo;
    return CartaoEco(
      padding: EdgeInsets.zero,
      corBorda: trilha.corTema.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            'assets/conteudos/${trilha.ilustracao}',
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        trilha.titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textoTitulo,
                        ),
                      ),
                    ),
                    Text(
                      '${trilha.concluidos} de ${trilha.modulos.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textoSecundario,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  trilha.subtitulo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textoSecundario,
                  ),
                ),
                const SizedBox(height: 8),
                BarraProgressoEco(
                  valor: trilha.progresso,
                  altura: 6,
                  cor: trilha.corTema,
                ),
              ],
            ),
          ),
          for (int i = 0; i < trilha.modulos.length; i++)
            _construirLinhaModulo(trilha, i, proximo: i == proximo),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _construirLinhaModulo(
    TrilhaAprendizado trilha,
    int indice, {
    required bool proximo,
  }) {
    final ModuloTrilha modulo = trilha.modulos[indice];
    final String? status = modulo.concluido
        ? 'Concluído · figurinha ganha'
        : proximo
        ? (modulo.lido ? 'Falta o quiz' : 'Próximo módulo')
        : modulo.lido
        ? 'Falta o quiz'
        : null;

    final Widget marcador = modulo.concluido
        ? const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.verdeGradienteInicio,
            child: Icon(Icons.check, size: 18, color: AppColors.fundoBranco),
          )
        : Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: proximo ? AppColors.fundoBranco : const Color(0xFFEEEEEE),
              border: proximo
                  ? Border.all(color: AppColors.verdeGradienteInicio, width: 2)
                  : null,
            ),
            child: Text(
              '${indice + 1}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: proximo
                    ? AppColors.verdeEscuro
                    : AppColors.textoSecundario,
              ),
            ),
          );

    return Material(
      color: proximo ? AppColors.verdeClaroFundo : Colors.transparent,
      child: InkWell(
        onTap: () => _abrirModulo(trilha, modulo, indice),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              marcador,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      modulo.nome,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textoTitulo,
                      ),
                    ),
                    if (status != null)
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          color: modulo.concluido
                              ? AppColors.verdeCabecalho
                              : AppColors.textoSecundario,
                        ),
                      ),
                  ],
                ),
              ),
              if (proximo)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.verdeGradienteInicio,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    modulo.lido ? 'Continuar' : 'Começar',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.fundoBranco,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textoCinzaClaro,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
