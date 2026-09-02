import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../album/tela_album.dart';
import '../mapa/tela_mapa.dart';
import '../scanner/tela_scanner.dart';
import 'cabecalho_modulo.dart';
import 'tela_aprender.dart';
import 'tela_conquista.dart';

class PerguntaQuiz {
  final String texto;
  final List<String> alternativas;
  final int indiceCorreto;

  const PerguntaQuiz({
    required this.texto,
    required this.alternativas,
    required this.indiceCorreto,
  });
}

// --- QUIZ DO MÓDULO "RECICLAR" (TRILHA 1) ---
const List<PerguntaQuiz> perguntasQuizReciclar = [
  PerguntaQuiz(
    texto: 'Uma garrafa PET vazia - qual o destino correto?',
    alternativas: ['Lixo Comum', 'Reciclagem comum', 'Ponto de eletrônicos', 'Aterro'],
    indiceCorreto: 1,
  ),
  PerguntaQuiz(
    texto: 'Uma pilha usada - qual o destino correto?',
    alternativas: ['Lixo Comum', 'Reciclagem comum', 'Ponto de eletrônicos', 'Aterro'],
    indiceCorreto: 2,
  ),
  PerguntaQuiz(
    texto: 'Um pote de vidro limpo - qual o destino correto?',
    alternativas: ['Lixo Comum', 'Reciclagem comum', 'Ponto de eletrônicos', 'Aterro'],
    indiceCorreto: 1,
  ),
];

class TelaQuizModulo extends StatefulWidget {
  final String rotuloTrilha;
  final String tituloQuiz;
  final List<PerguntaQuiz> perguntas;
  final RecompensaModulo recompensa;

  const TelaQuizModulo({
    super.key,
    required this.rotuloTrilha,
    required this.tituloQuiz,
    required this.perguntas,
    required this.recompensa,
  });

  @override
  State<TelaQuizModulo> createState() => _TelaQuizModuloState();
}

class _TelaQuizModuloState extends State<TelaQuizModulo> {
  final int _abaSelecionada = 1; // Aprender selecionado por padrão

  int _indicePergunta = 0;
  int? _indiceSelecionado;

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
                    CabecalhoModulo(
                      rotuloTrilha: widget.rotuloTrilha,
                      titulo: widget.tituloQuiz,
                      numeroAtual: _indicePergunta + 1,
                      total: widget.perguntas.length,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                      child: _construirPergunta(),
                    ),
                  ],
                ),
              ),
            ),

            // --- BOTÃO FIXO: PRÓXIMA PERGUNTA / CONCLUIR ---
            Container(
              width: double.infinity,
              color: AppColors.fundoBranco,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _indiceSelecionado == null ? null : _avancar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdeGradienteInicio,
                    foregroundColor: AppColors.fundoBranco,
                    disabledBackgroundColor: AppColors.bordaVerdeClara,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _indicePergunta == widget.perguntas.length - 1
                            ? 'Concluir quiz'
                            : 'Próxima pergunta',
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

  void _selecionarResposta(int indice) {
    if (_indiceSelecionado != null) return;
    setState(() => _indiceSelecionado = indice);
  }

  void _avancar() {
    if (_indicePergunta == widget.perguntas.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TelaConquista(recompensa: widget.recompensa)),
      );
    } else {
      setState(() {
        _indicePergunta++;
        _indiceSelecionado = null;
      });
    }
  }

  Widget _construirPergunta() {
    final PerguntaQuiz pergunta = widget.perguntas[_indicePergunta];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pergunta.texto,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textoEscuro,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 20),
        for (int i = 0; i < pergunta.alternativas.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _construirOpcao(pergunta, i)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: i + 1 < pergunta.alternativas.length
                        ? _construirOpcao(pergunta, i + 1)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _construirOpcao(PerguntaQuiz pergunta, int indice) {
    final bool respondida = _indiceSelecionado != null;
    final bool ehCorreta = indice == pergunta.indiceCorreto;
    final bool ehSelecionada = indice == _indiceSelecionado;

    Color corFundo = AppColors.fundoBranco;
    Color corBorda = AppColors.bordaVerdeClara;
    Color corTexto = AppColors.textoEscuro;
    IconData? icone;

    if (respondida && ehCorreta) {
      corFundo = AppColors.verdeClaroFundo;
      corBorda = AppColors.destaqueVerdeClaro;
      corTexto = AppColors.verdeEscuroTexto;
      icone = Icons.check_circle;
    } else if (respondida && ehSelecionada && !ehCorreta) {
      corFundo = const Color(0xFFFFEBEE);
      corBorda = Colors.red.shade300;
      corTexto = Colors.red.shade700;
      icone = Icons.cancel;
    }

    return GestureDetector(
      onTap: () => _selecionarResposta(indice),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: corFundo,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: corBorda),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icone != null) ...[
              Icon(icone, color: corTexto, size: 18),
              const SizedBox(height: 6),
            ],
            Text(
              pergunta.alternativas[indice],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: corTexto),
            ),
          ],
        ),
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
