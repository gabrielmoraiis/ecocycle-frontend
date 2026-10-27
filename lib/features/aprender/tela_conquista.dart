import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/models/figurinha.dart';
import '../../core/models/resultado_scanner.dart';
import '../../core/models/resultado_submissao.dart';
import '../../core/providers/progresso_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/cartao_figurinha.dart';
import '../album/tela_album.dart';
import '../album/tela_info_figurinha.dart';
import 'tela_aprender.dart';

const Color _fundo = Color(0xFF2E7D32);
const Color _verdeEscuro = Color(0xFF1B5E20);
const Color _textoTitulo = Color(0xFF212121);
const Color _textoCorpo = Color(0xFF555555);

/// Tela de comemoração depois de um desbloqueio. Serve a dois caminhos:
/// o fim de um quiz ([TelaConquista.new]) e o Scanner IA reconhecendo um
/// componente pela primeira vez ([TelaConquista.scanner]).
class TelaConquista extends StatelessWidget {
  final ResultadoSubmissao? _quiz;
  final ResultadoScanner? _scanner;

  const TelaConquista({super.key, required ResultadoSubmissao resultado})
    : _quiz = resultado,
      _scanner = null;

  const TelaConquista.scanner({super.key, required ResultadoScanner resultado})
    : _quiz = null,
      _scanner = resultado;

  Figurinha? get _figurinha =>
      _quiz != null ? _quiz.figurinhaDesbloqueada : _scanner!.figurinha;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _fundo,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ..._construirConfete(),
                    Positioned.fill(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                        child: _construirDestaque(),
                      ),
                    ),
                  ],
                ),
              ),
              _construirPainel(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES PARA NÃO REPETIR CÓDIGO ---

  Widget _construirDestaque() {
    final Figurinha? figurinha = _figurinha;
    final ResultadoSubmissao? quiz = _quiz;

    final String titulo = quiz != null
        ? 'Quiz concluído!'
        : 'Componente identificado!';
    final String subtitulo;
    if (quiz != null) {
      subtitulo = figurinha != null
          ? 'Você acertou ${quiz.acertos} de ${quiz.totalPerguntas} perguntas'
          : 'Nenhuma figurinha nova desta vez.';
    } else {
      final nome = figurinha?.nome;
      subtitulo = nome == null
          ? 'O Scanner IA reconheceu o aparelho'
          : 'O Scanner IA reconheceu: $nome';
    }

    return Column(
      children: [
        _construirSelo(figurinha != null ? 'NOVA FIGURINHA' : 'QUIZ CONCLUÍDO'),
        const SizedBox(height: 12),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.fundoBranco,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitulo,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: Color(0xFFE8F5E9)),
        ),
        const SizedBox(height: 16),
        if (figurinha != null) ...[
          _construirHalo(
            CartaoFigurinha(figurinha: figurinha, largura: 150, sombra: 0.35),
          ),
          const SizedBox(height: 14),
          EtiquetasFigurinha(figurinha: figurinha),
        ] else if (quiz != null)
          _construirHalo(_construirPlacar(quiz)),
      ],
    );
  }

  Widget _construirSelo(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.fundoBranco.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 14,
            color: AppColors.fundoBranco,
          ),
          const SizedBox(width: 6),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: AppColors.fundoBranco,
            ),
          ),
        ],
      ),
    );
  }

  /// Círculo claro atrás do conteúdo central, para destacá-lo do fundo.
  Widget _construirHalo(Widget filho) {
    return SizedBox(
      width: 230,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.fundoBranco.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
          ),
          filho,
        ],
      ),
    );
  }

  /// Quiz sem figurinha nova: a pontuação ocupa o lugar do card.
  Widget _construirPlacar(ResultadoSubmissao quiz) {
    return Container(
      width: 150,
      height: 150,
      decoration: const BoxDecoration(
        color: AppColors.fundoBranco,
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${quiz.acertos}/${quiz.totalPerguntas}',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: _verdeEscuro,
            ),
          ),
          const Text(
            'acertos',
            style: TextStyle(fontSize: 15, color: _textoCorpo),
          ),
        ],
      ),
    );
  }

  // Confete decorativo nas laterais do destaque, abaixo do texto. Posições
  // proporcionais (Alignment) para acompanhar qualquer largura de tela.
  List<Widget> _construirConfete() {
    const pecas = [
      (-0.86, -0.18, 10.0, 18.0, Color(0xFFFFD54F), -0.42),
      (-0.7, 0.42, 8.0, 8.0, Color(0xFFA5D6A7), 0.0),
      (-0.9, 0.78, 12.0, 6.0, AppColors.fundoBranco, 0.7),
      (0.86, -0.1, 10.0, 18.0, Color(0xFF81D4FA), 0.52),
      (0.72, 0.5, 12.0, 6.0, Color(0xFFFFAB91), -0.21),
      (0.9, 0.86, 7.0, 7.0, AppColors.fundoBranco, 0.0),
    ];
    return [
      for (final (x, y, largura, altura, cor, angulo) in pecas)
        Positioned.fill(
          child: Align(
            alignment: Alignment(x, y),
            child: Transform.rotate(
              angle: angulo,
              child: Container(
                width: largura,
                height: altura,
                decoration: BoxDecoration(
                  color: cor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
    ];
  }

  /// Painel branco de baixo: destaques, progresso do álbum e botões.
  Widget _construirPainel(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.fundoBranco,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        22,
        20,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: _construirDestaquesNumericos()),
          const SizedBox(height: 16),
          _construirProgresso(),
          const SizedBox(height: 16),
          ..._construirBotoes(context),
        ],
      ),
    );
  }

  List<Widget> _construirDestaquesNumericos() {
    final ResultadoSubmissao? quiz = _quiz;
    if (quiz != null) {
      final bool ganhouXp = quiz.xpGanho > 0;
      return [
        Expanded(
          child: _construirBlocoNumero(
            icone: Icons.bolt,
            valor: ganhouXp ? '+${quiz.xpGanho} XP' : '0 XP',
            rotulo: ganhouXp ? 'ganhos agora' : 'já recebido antes',
            corFundo: const Color(0xFFFFF6E5),
            corIconeFundo: const Color(0xFFFFE0B2),
            corValor: const Color(0xFF7A3A00),
            corRotulo: const Color(0xFF5D3A12),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _construirBlocoNumero(
            icone: Icons.check_rounded,
            valor: '${quiz.acertos}/${quiz.totalPerguntas}',
            rotulo: 'acertos',
            corFundo: AppColors.verdeClaroFundo,
            corIconeFundo: AppColors.bordaVerdeClara,
            corValor: _verdeEscuro,
            corRotulo: const Color(0xFF2E5E30),
          ),
        ),
      ];
    }

    final ResultadoScanner scanner = _scanner!;
    // O app envia a confiança de 0 a 100; aceita também 0 a 1, por segurança.
    final double confianca = scanner.confianca <= 1
        ? scanner.confianca * 100
        : scanner.confianca;
    final Figurinha? figurinha = scanner.figurinha;
    return [
      Expanded(
        child: _construirBlocoNumero(
          icone: Icons.center_focus_strong_outlined,
          valor: '${confianca.round()}%',
          rotulo: 'de confiança',
          corFundo: const Color(0xFFE3F2FD),
          corIconeFundo: const Color(0xFFBBDEFB),
          corValor: const Color(0xFF0D47A1),
          corRotulo: const Color(0xFF1A3A6B),
        ),
      ),
      if (figurinha != null) ...[
        const SizedBox(width: 10),
        Expanded(
          child: _construirBlocoNumero(
            icone: Icons.style_outlined,
            valor: 'Nº ${figurinha.ordem.toString().padLeft(2, '0')}',
            rotulo: 'do álbum',
            corFundo: AppColors.verdeClaroFundo,
            corIconeFundo: AppColors.bordaVerdeClara,
            corValor: _verdeEscuro,
            corRotulo: const Color(0xFF2E5E30),
          ),
        ),
      ],
    ];
  }

  Widget _construirBlocoNumero({
    required IconData icone,
    required String valor,
    required String rotulo,
    required Color corFundo,
    required Color corIconeFundo,
    required Color corValor,
    required Color corRotulo,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: corIconeFundo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, size: 18, color: corValor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: corValor,
                  ),
                ),
                Text(
                  rotulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: corRotulo),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirProgresso() {
    return Consumer<ProgressoProvider>(
      builder: (context, progressoProvider, _) {
        final progresso = progressoProvider.progresso;
        final desbloqueadas = progresso?.figurinhasDesbloqueadas ?? 0;
        final total = progresso?.totalFigurinhas ?? 10;
        final valor = total == 0 ? 0.0 : desbloqueadas / total;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Progresso do álbum',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _textoTitulo,
                    ),
                  ),
                ),
                Text(
                  '$desbloqueadas de $total figurinhas',
                  style: const TextStyle(fontSize: 13, color: _textoCorpo),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: valor,
                minHeight: 10,
                backgroundColor: const Color(0xFFE8F5E9),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.verdeGradienteInicio,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _construirBotoes(BuildContext context) {
    final Figurinha? figurinha = _figurinha;
    if (_quiz != null) {
      return [
        _construirBotaoPrincipal(
          texto: 'Voltar às trilhas',
          onPressed: () => _irParaTrilhas(context),
        ),
        const SizedBox(height: 10),
        _construirBotaoSecundario(
          texto: figurinha != null ? 'Ver figurinha no álbum' : 'Ver álbum',
          onPressed: () => _abrirAlbum(context),
        ),
      ];
    }
    return [
      if (figurinha != null) ...[
        _construirBotaoPrincipal(
          texto: 'Ver detalhes',
          icone: Icons.chevron_right,
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TelaInfoFigurinha(figurinha: figurinha),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
      _construirBotaoSecundario(
        texto: 'Escanear outro aparelho',
        // Volta para o Scanner, que continua aberto por baixo.
        onPressed: () => Navigator.pop(context),
      ),
    ];
  }

  Widget _construirBotaoPrincipal({
    required String texto,
    required VoidCallback onPressed,
    IconData? icone,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.verdeGradienteInicio,
        foregroundColor: AppColors.fundoBranco,
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            texto,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (icone != null) ...[
            const SizedBox(width: 6),
            Icon(icone, size: 20),
          ],
        ],
      ),
    );
  }

  Widget _construirBotaoSecundario({
    required String texto,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _verdeEscuro,
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: AppColors.bordaVerdeClara),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _irParaTrilhas(BuildContext context) {
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
