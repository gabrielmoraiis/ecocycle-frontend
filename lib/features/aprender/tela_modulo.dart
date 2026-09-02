import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../album/tela_album.dart';
import '../mapa/tela_mapa.dart';
import '../scanner/tela_scanner.dart';
import 'cabecalho_modulo.dart';
import 'tela_aprender.dart';
import 'tela_conquista.dart';
import 'tela_quiz.dart';

class SecaoModulo {
  final IconData icone;
  final Color corIcone;
  final Color corFundoIcone;
  final String titulo;
  final String texto;
  final String? destaque;

  const SecaoModulo({
    required this.icone,
    required this.corIcone,
    required this.corFundoIcone,
    required this.titulo,
    required this.texto,
    this.destaque,
  });
}

// --- CONTEÚDO DO MÓDULO "RECICLAR" (TRILHA 1) ---
const List<SecaoModulo> secoesModuloReciclar = [
  SecaoModulo(
    icone: Icons.info_outline,
    corIcone: AppColors.verdeGradienteInicio,
    corFundoIcone: AppColors.verdeClaroFundo,
    titulo: 'O que é reciclar?',
    texto:
        'Reciclar é transformar resíduos em novos materiais. Uma garrafa PET vira fibra de roupa. Uma lata de alumínio vira outra lata em apenas 60 dias.',
    destaque: 'Reciclar alumínio gasta 95% menos energia do que produzir alumínio novo.',
  ),
  SecaoModulo(
    icone: Icons.info_outline,
    corIcone: Colors.amber,
    corFundoIcone: Color(0xFFFFF8E1),
    titulo: 'E os eletrônicos?',
    texto:
        'Eletrônicos não vão na reciclagem comum. Contêm chumbo, mercúrio e cádmio - precisam de pontos de coleta especializados.',
  ),
  SecaoModulo(
    icone: Icons.location_on_outlined,
    corIcone: Colors.blue,
    corFundoIcone: Color(0xFFE3F2FD),
    titulo: 'Onde descartar?',
    texto:
        'Use a aba Mapa para encontrar o ponto de coleta mais próximo. No Brasil, apenas 3% dos eletrônicos são descartados corretamente.',
  ),
];

class TelaModulo extends StatefulWidget {
  final String rotuloTrilha;
  final String tituloModulo;
  final int numeroModulo;
  final int totalModulos;
  final List<SecaoModulo> secoes;
  final String textoBotao;
  final String? tituloQuiz;
  final List<PerguntaQuiz>? perguntasQuiz;
  final RecompensaModulo? recompensa;

  const TelaModulo({
    super.key,
    required this.rotuloTrilha,
    required this.tituloModulo,
    required this.numeroModulo,
    required this.totalModulos,
    required this.secoes,
    this.textoBotao = 'Pronto! Jogar o mini-game',
    this.tituloQuiz,
    this.perguntasQuiz,
    this.recompensa,
  });

  @override
  State<TelaModulo> createState() => _TelaModuloState();
}

class _TelaModuloState extends State<TelaModulo> {
  final int _abaSelecionada = 1; // Aprender selecionado por padrão

  @override
  Widget build(BuildContext context) {
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
                    // --- CABEÇALHO DO MÓDULO (HERO) ---
                    CabecalhoModulo(
                      rotuloTrilha: widget.rotuloTrilha,
                      titulo: widget.tituloModulo,
                      numeroAtual: widget.numeroModulo,
                      total: widget.totalModulos,
                    ),

                    // --- SEÇÕES DE CONTEÚDO ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final secao in widget.secoes) ...[
                            _construirCartaoSecao(secao),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- BOTÃO FIXO: PRONTO! JOGAR O MINI-GAME ---
            Container(
              width: double.infinity,
              color: AppColors.fundoBranco,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.perguntasQuiz == null || widget.recompensa == null
                      ? null
                      : () => _abrirQuiz(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdeGradienteInicio,
                    foregroundColor: AppColors.fundoBranco,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.textoBotao,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right, size: 20),
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

  void _abrirQuiz(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaQuizModulo(
          rotuloTrilha: widget.rotuloTrilha,
          tituloQuiz: widget.tituloQuiz!,
          perguntas: widget.perguntasQuiz!,
          recompensa: widget.recompensa!,
        ),
      ),
    );
  }

  Widget _construirCartaoSecao(SecaoModulo secao) {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: secao.corFundoIcone, shape: BoxShape.circle),
                child: Icon(secao.icone, color: secao.corIcone, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  secao.titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textoEscuro,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            secao.texto,
            style: const TextStyle(fontSize: 14, color: AppColors.textoCinzaClaro, height: 1.4),
          ),
          if (secao.destaque != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.verdeClaroFundo,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.eco_outlined, color: AppColors.verdeEscuroTexto, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      secao.destaque!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.verdeEscuroTexto,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _abrirAlbum(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaAlbum()),
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaMapa()));
        } else if (indice == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaScanner()));
        } else if (indice == 1) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const TelaAprender()),
            (route) => route.isFirst,
          );
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
