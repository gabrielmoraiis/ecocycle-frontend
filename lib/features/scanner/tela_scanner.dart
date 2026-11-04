import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../core/ia/classificador_componente.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/figurinhas_provider.dart';
import '../../core/providers/progresso_provider.dart';
import '../../core/services/scanner_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/eco_bottom_nav_bar.dart';
import '../../core/widgets/layout_eco.dart';
import '../album/tela_info_figurinha.dart';
import '../aprender/tela_conquista.dart';

const String _mensagemNaoIdentificado =
    'Tente aproximar mais a câmera ou melhore a iluminação do ambiente.';
const String _mensagemObjetoDesconhecido =
    'Esse objeto não está entre os aparelhos que a IA reconhece. '
    'Aponte a câmera para um deles e tente de novo.';
const String _mensagemSemFoto =
    'Não foi possível abrir a câmera ou a galeria deste aparelho.';
const String _mensagemSemSuporte =
    'O Scanner IA funciona apenas no app para celular.';

// Não baixe muito esse limite: o image_picker reduz a foto sem filtro, e a
// redução certa, com o filtro do notebook, acontece depois, em prepararEntrada.
// Ele continua existindo porque é o que faz o plugin devolver um JPEG, já que o
// pacote image não lê HEIC, e porque evita decodificar fotos de 50 MP ou mais.
const double _ladoMaximoFoto = 4096;

const Color _fundoScanner = Color(0xFF121A12);
const Color _verdeDestaque = Color(0xFFA5D6A7);

class TelaScanner extends StatefulWidget {
  const TelaScanner({super.key, this.carregarClassificador, this.obterFoto});

  // Substituem o modelo real e o seletor de fotos nos testes.
  @visibleForTesting
  final Future<ClassificadorComponente> Function()? carregarClassificador;
  @visibleForTesting
  final Future<XFile?> Function(ImageSource origem)? obterFoto;

  @override
  State<TelaScanner> createState() => _TelaScannerState();
}

class _TelaScannerState extends State<TelaScanner> {
  bool _processando = false;
  bool _falhaIdentificacao = false;
  String _mensagemFalha = _mensagemNaoIdentificado;

  // Carregado uma vez por tela; se falhar, o erro aparece na primeira captura.
  Future<ClassificadorComponente>? _classificador;

  late final ScannerService _scannerService;

  @override
  void initState() {
    super.initState();
    _scannerService = ScannerService(context.read());

    if (!ClassificadorComponente.suportado) {
      // Na web não há modelo: mostra direto o aviso de indisponível.
      _falhaIdentificacao = true;
      _mensagemFalha = _mensagemSemSuporte;
      return;
    }

    _classificador =
        (widget.carregarClassificador ?? ClassificadorComponente.carregar)()
          ..ignore();
  }

  // Vai para o console (adb logcat / flutter run) e fica como "breadcrumb"
  // no Sentry, anexado ao próximo erro reportado.
  void _registrar(String mensagem) {
    debugPrint('Scanner IA: $mensagem');
    Sentry.addBreadcrumb(Breadcrumb(message: mensagem, category: 'scanner'));
  }

  void _encerrarProcessamento() {
    setState(() {
      _processando = false;
      _falhaIdentificacao = false;
    });
  }

  void _mostrarFalha(String mensagem) {
    setState(() {
      _processando = false;
      _falhaIdentificacao = true;
      _mensagemFalha = mensagem;
    });
  }

  @override
  void dispose() {
    _classificador?.then((c) => c.fechar(), onError: (_) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _fundoScanner,
        body: Column(
          children: [
            SafeArea(bottom: false, child: _construirTopo()),
            Expanded(child: _construirAreaCentral()),

            // --- STATUS + BOTÃO DE CAPTURA / PAINEL DE ERRO ---
            _falhaIdentificacao
                ? _construirPainelErro()
                : _construirPainelInstrucoes(),
          ],
        ),

        // --- BARRA DE NAVEGAÇÃO INFERIOR ---
        bottomNavigationBar: const EcoBottomNavBar(tabAtual: EcoTab.scanner),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES PARA NÃO REPETIR CÓDIGO ---

  Widget _construirTopo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          BotaoCircularEco(
            icone: Icons.chevron_left,
            tooltip: 'Voltar',
            corFundo: const Color(0x73000000),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Scanner IA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.fundoBranco,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirAreaCentral() {
    if (_processando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _verdeDestaque),
            SizedBox(height: 16),
            Text(
              'Analisando...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _falhaIdentificacao
                  ? Icons.priority_high_rounded
                  : Icons.center_focus_weak_outlined,
              color: _verdeDestaque,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              ClassificadorComponente.suportado
                  ? 'Tire ou escolha uma foto com o aparelho centralizado'
                  : 'Scanner IA indisponível no navegador.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _rotuloReconhecidos() {
    final int quantidade =
        ClassificadorComponente.componentesReconhecidos.length;
    return quantidade == 1
        ? 'A IA RECONHECE 1 APARELHO'
        : 'A IA RECONHECE $quantidade APARELHOS';
  }

  Widget _construirPainelInstrucoes() {
    return Container(
      width: double.infinity,
      color: _fundoScanner,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _rotuloReconhecidos(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              // Só o que o modelo instalado reconhece de fato.
              for (final componente
                  in ClassificadorComponente.componentesReconhecidos)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x1AFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    componente.rotulo,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label: 'Tirar ou escolher uma foto para identificar',
            child: GestureDetector(
              onTap: _processando ? null : _escolherOrigemFoto,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.verdeGradienteInicio,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: _processando
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                          color: AppColors.fundoBranco,
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(
                        Icons.photo_camera_outlined,
                        color: AppColors.fundoBranco,
                        size: 32,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirPainelErro() {
    return Container(
      width: double.infinity,
      color: _fundoScanner,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3A2224),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF6B3A3E)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFFFB4AB),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Não conseguimos identificar o aparelho',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFDAD6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _mensagemFalha,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: Color(0xFFFFB4AB),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (ClassificadorComponente.suportado) ...[
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _processando ? null : _escolherOrigemFoto,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Tentar novamente'),
              style: BotoesEco.principal(altura: 52),
            ),
          ],
        ],
      ),
    );
  }

  // O app de câmera do aparelho é externo e não aceita um botão de galeria,
  // então a escolha acontece aqui, antes de abri-lo.
  Future<void> _escolherOrigemFoto() async {
    final ImageSource? origem = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: _fundoScanner,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: _verdeDestaque,
              ),
              title: const Text(
                'Tirar foto',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: _verdeDestaque,
              ),
              title: const Text(
                'Escolher da galeria',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (origem == null || !mounted) return;
    await _analisar(origem);
  }

  // A foto vem do app de câmera do aparelho (ACTION_IMAGE_CAPTURE) ou do
  // seletor de fotos do sistema; o app não acessa nenhum deles diretamente.
  Future<XFile?> _obterFoto(ImageSource origem) =>
      widget.obterFoto?.call(origem) ??
      ImagePicker().pickImage(
        source: origem,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: _ladoMaximoFoto,
        maxHeight: _ladoMaximoFoto,
      );

  Future<void> _analisar(ImageSource origem) async {
    setState(() {
      _processando = true;
      _falhaIdentificacao = false;
    });

    // Vem null quando o usuário desiste (ex.: volta sem escolher a foto).
    final XFile? foto;
    try {
      foto = await _obterFoto(origem);
    } on PlatformException catch (e, pilha) {
      // Ex.: nenhum app de câmera instalado (no_available_camera).
      _registrar('falha ao abrir ${origem.name}: ${e.code}');
      Sentry.captureException(e, stackTrace: pilha);
      if (mounted) _mostrarFalha(_mensagemSemFoto);
      return;
    }
    if (foto == null) {
      if (mounted) _encerrarProcessamento();
      return;
    }

    // A foto é analisada aqui, on-device; apenas o identificador e a confiança
    // vão para o back-end, que decide se a leitura passa do limiar.
    final ClassificacaoComponente classificacao;
    try {
      final Future<ClassificadorComponente>? classificador = _classificador;
      if (classificador == null) throw StateError('Modelo indisponível.');
      final bytes = await foto.readAsBytes();
      classificacao = await (await classificador).classificar(bytes);
      _registrar(classificacao.resumo);
    } catch (e, pilha) {
      _registrar('falha ao analisar a foto: $e');
      Sentry.captureException(e, stackTrace: pilha);
      if (!mounted) return;
      _mostrarFalha(_mensagemNaoIdentificado);
      return;
    }
    if (!mounted) return;

    final identificador = classificacao.identificador;
    // Classe Outros: não é um aparelho do Scanner. A API só registra a leitura,
    // então a tela não espera a resposta e uma falha ali não aparece ao usuário.
    if (identificador == null) {
      _mostrarFalha(_mensagemObjetoDesconhecido);
      unawaited(
        _scannerService
            .registrarObjetoDesconhecido(
              classificacao.confianca,
              segundoIdentificador: classificacao.segundoIdentificador,
              segundaConfianca: classificacao.segundaConfianca,
            )
            .catchError((Object e) {
              _registrar('falha ao registrar leitura Outros: $e');
            }),
      );
      return;
    }

    try {
      final resultado = await _scannerService.reconhecer(
        identificador,
        classificacao.confianca,
        segundoIdentificador: classificacao.segundoIdentificador,
        segundaConfianca: classificacao.segundaConfianca,
      );

      if (!mounted) return;

      if (!resultado.reconhecido || resultado.figurinha == null) {
        // Não é erro, mas ajuda a calibrar o limiar do back-end.
        Sentry.captureMessage(
          'Scanner IA: leitura recusada pelo back-end '
          '(${classificacao.resumo}): ${resultado.mensagem}',
        );
        _mostrarFalha(_mensagemNaoIdentificado);
        return;
      }

      if (resultado.novaDesbloqueada) {
        context.read<FigurinhasProvider>().recarregar();
        context.read<ProgressoProvider>().recarregar();
      }

      _encerrarProcessamento();
      // Primeira vez: comemora com a tela de conquista. Já desbloqueada: não
      // há nada novo, então vai direto para o detalhe.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => resultado.novaDesbloqueada
              ? TelaConquista.scanner(resultado: resultado)
              : TelaInfoFigurinha(figurinha: resultado.figurinha!),
        ),
      );
    } on ApiException catch (e, pilha) {
      _registrar('erro na API do scanner: ${e.message}');
      Sentry.captureException(e, stackTrace: pilha);
      if (!mounted) return;
      _encerrarProcessamento();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}
