import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/trilha_presentation_catalog.dart';
import '../../core/models/trilha.dart' as api;
import '../../core/network/api_exception.dart';
import '../../core/providers/progresso_provider.dart';
import '../../core/services/trilha_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_indicator.dart';
import '../album/tela_album.dart';
import '../mapa/tela_mapa.dart';
import '../scanner/tela_scanner.dart';
import 'tela_modulo.dart';

class ModuloTrilha {
  final int conteudoId;
  final String nome;
  final bool concluido;

  const ModuloTrilha({
    required this.conteudoId,
    required this.nome,
    required this.concluido,
  });
}

class TrilhaAprendizado {
  final String tituloSecao;
  final IconData icone;
  final Color corTema;
  final Color corFundoIcone;
  final String titulo;
  final String subtitulo;
  final List<ModuloTrilha> modulos;

  const TrilhaAprendizado({
    required this.tituloSecao,
    required this.icone,
    required this.corTema,
    required this.corFundoIcone,
    required this.titulo,
    required this.subtitulo,
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
      modulos: trilha.conteudos
          .map((c) => ModuloTrilha(conteudoId: c.id, nome: c.titulo, concluido: c.quizConcluido))
          .toList(),
    );
  }

  double get progresso =>
      modulos.isEmpty ? 0 : modulos.where((modulo) => modulo.concluido).length / modulos.length;
}

class TelaAprender extends StatefulWidget {
  const TelaAprender({super.key});

  @override
  State<TelaAprender> createState() => _TelaAprenderState();
}

class _TelaAprenderState extends State<TelaAprender> {
  int _abaSelecionada = 1; // Aprender selecionado por padrão

  late final TrilhaService _trilhaService;
  bool _carregando = true;
  ApiException? _erro;
  List<TrilhaAprendizado> _trilhas = [];

  @override
  void initState() {
    super.initState();
    _trilhaService = TrilhaService(context.read());
    _carregarTrilhas();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressoProvider>().carregar();
    });
  }

  Future<void> _carregarTrilhas() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final trilhas = await _trilhaService.listarTrilhas();
      setState(() {
        _trilhas = trilhas.map(TrilhaAprendizado.fromApi).toList();
      });
    } on ApiException catch (e) {
      setState(() => _erro = e);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalModulos = _trilhas.fold(0, (soma, trilha) => soma + trilha.modulos.length);
    final int modulosConcluidos = _trilhas.fold(
      0,
      (soma, trilha) => soma + trilha.modulos.where((modulo) => modulo.concluido).length,
    );
    final int figurinhasDesbloqueadas =
        context.watch<ProgressoProvider>().progresso?.figurinhasDesbloqueadas ?? 0;

    return Scaffold(
      backgroundColor: AppColors.verdeClaroFundo,
      body: SafeArea(
        child: Column(
          children: [
            // --- TOPO: VOLTAR + TÍTULO ---
            Container(
              color: AppColors.fundoBranco,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.verdeClaroFundo,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.chevron_left, color: AppColors.verdeGradienteInicio),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  const Text(
                    'Aprender',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.verdeGradienteInicio,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _carregando
                  ? const LoadingIndicator()
                  : _erro != null
                      ? ErrorState(message: _erro!.message, onRetry: _carregarTrilhas)
                      : RefreshIndicator(
                          onRefresh: _carregarTrilhas,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- BANNER VERDE (HERO) ---
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
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
                                        'SUA JORNADA EDUCATIVA',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                          color: AppColors.branco70,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Escolha uma trilha',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textoBranco,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 12,
                                        children: [
                                          _construirEstatistica(
                                            AppColors.destaqueVerdeClaro,
                                            '$modulosConcluidos/$totalModulos módulos',
                                          ),
                                          _construirEstatistica(
                                            Colors.amber,
                                            '$figurinhasDesbloqueadas figurinhas',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // --- TRILHAS ---
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for (int i = 0; i < _trilhas.length; i++) ...[
                                        _construirTituloSecao(_trilhas[i].tituloSecao),
                                        const SizedBox(height: 12),
                                        _construirCartaoTrilha(_trilhas[i]),
                                        const SizedBox(height: 24),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
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

  // --- MÉTODOS AUXILIARES PARA NÃO REPETIR CÓDIGO ---

  void _abrirAlbum(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaAlbum()),
    );
  }

  void _abrirMapa(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaMapa()),
    );
  }

  void _abrirScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaScanner()),
    );
  }

  Future<void> _abrirModulo(
    BuildContext context,
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
    if (mounted) _carregarTrilhas();
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

  Widget _construirEstatistica(Color corPonto, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.branco20,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: corPonto, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            texto,
            style: const TextStyle(color: AppColors.textoBranco, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _construirCartaoTrilha(TrilhaAprendizado trilha) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.fundoBranco,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bordaVerdeClara),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: trilha.corFundoIcone,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(trilha.icone, color: trilha.corTema, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trilha.titulo,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textoEscuro,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      trilha.subtitulo,
                      style: const TextStyle(fontSize: 13, color: AppColors.textoCinzaClaro, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: trilha.progresso,
              minHeight: 8,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: AlwaysStoppedAnimation<Color>(trilha.corTema),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < trilha.modulos.length; i++)
                _construirChipModulo(trilha.modulos[i], trilha.corTema, trilha, i),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirChipModulo(ModuloTrilha modulo, Color corTema, TrilhaAprendizado trilha, int indice) {
    return GestureDetector(
      onTap: () => _abrirModulo(context, trilha, modulo, indice),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: modulo.concluido ? corTema.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: corTema.withValues(alpha: modulo.concluido ? 0.0 : 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (modulo.concluido) ...[
              Icon(Icons.check, color: corTema, size: 14),
              const SizedBox(width: 4),
            ],
            Text(
              modulo.nome,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: corTema),
            ),
          ],
        ),
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
        } else if (indice == 4) {
          _abrirAlbum(context);
        } else if (indice == 0) {
          _abrirMapa(context);
        } else if (indice == 3) {
          _abrirScanner(context);
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
