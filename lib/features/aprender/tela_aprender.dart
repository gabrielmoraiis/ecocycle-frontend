import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../album/tela_album.dart';
import '../mapa/tela_mapa.dart';
import '../scanner/tela_scanner.dart';
import 'tela_conquista.dart';
import 'tela_modulo.dart';
import 'tela_quiz.dart';

class ModuloTrilha {
  final String nome;
  final bool concluido;
  final List<SecaoModulo>? secoes;
  final String? tituloQuiz;
  final List<PerguntaQuiz>? perguntasQuiz;
  final RecompensaModulo? recompensa;

  const ModuloTrilha({
    required this.nome,
    required this.concluido,
    this.secoes,
    this.tituloQuiz,
    this.perguntasQuiz,
    this.recompensa,
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

  double get progresso =>
      modulos.where((modulo) => modulo.concluido).length / modulos.length;
}

const List<TrilhaAprendizado> _trilhas = [
  TrilhaAprendizado(
    tituloSecao: "TRILHA 1 - OS 4 R'S",
    icone: Icons.refresh,
    corTema: AppColors.verdeGradienteInicio,
    corFundoIcone: AppColors.verdeClaroFundo,
    titulo: 'Os 4Rs do consumo consciente',
    subtitulo: 'Reduzir, Reutilizar, Reciclar e Reparar',
    modulos: [
      ModuloTrilha(nome: 'Reduzir', concluido: true),
      ModuloTrilha(nome: 'Reutilizar', concluido: true),
      ModuloTrilha(
        nome: 'Reciclar',
        concluido: false,
        secoes: secoesModuloReciclar,
        tituloQuiz: 'Quiz: na lixeira certa!',
        perguntasQuiz: perguntasQuizReciclar,
        recompensa: recompensaModuloReciclar,
      ),
      ModuloTrilha(nome: 'Reparar', concluido: false),
    ],
  ),
  TrilhaAprendizado(
    tituloSecao: 'TRILHA 2 - LIXO ELETRÔNICO',
    icone: Icons.desktop_windows_outlined,
    corTema: Colors.orange,
    corFundoIcone: Color(0xFFFFF3E0),
    titulo: 'O problema do e-lixo',
    subtitulo: 'O problema, componentes, substâncias',
    modulos: [
      ModuloTrilha(nome: 'O problema', concluido: true),
      ModuloTrilha(nome: 'Componentes', concluido: false),
      ModuloTrilha(nome: 'Substâncias', concluido: false),
    ],
  ),
];

const int _figurinhasDesbloqueadas = 2;

class TelaAprender extends StatefulWidget {
  const TelaAprender({super.key});

  @override
  State<TelaAprender> createState() => _TelaAprenderState();
}

class _TelaAprenderState extends State<TelaAprender> {
  int _abaSelecionada = 1; // Aprender selecionado por padrão

  @override
  Widget build(BuildContext context) {
    final int totalModulos = _trilhas.fold(0, (soma, trilha) => soma + trilha.modulos.length);
    final int modulosConcluidos = _trilhas.fold(
      0,
      (soma, trilha) => soma + trilha.modulos.where((modulo) => modulo.concluido).length,
    );

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
              child: SingleChildScrollView(
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
                                '$_figurinhasDesbloqueadas figurinhas',
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
                            SizedBox(height: i == _trilhas.length - 1 ? 24 : 24),
                          ],
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

  void _abrirModulo(BuildContext context, TrilhaAprendizado trilha, ModuloTrilha modulo, int indice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaModulo(
          rotuloTrilha: trilha.tituloSecao.split(' - ').first,
          tituloModulo: modulo.nome,
          numeroModulo: indice + 1,
          totalModulos: trilha.modulos.length,
          secoes: modulo.secoes!,
          tituloQuiz: modulo.tituloQuiz,
          perguntasQuiz: modulo.perguntasQuiz,
          recompensa: modulo.recompensa,
        ),
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
      onTap: modulo.secoes == null ? null : () => _abrirModulo(context, trilha, modulo, indice),
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
