import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
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
const String _mensagemSemCamera =
    'Não foi possível usar a câmera. Verifique a permissão do app.';
const String _mensagemSemSuporte =
    'O Scanner IA funciona apenas no app para celular.';

// Fundo escuro do Scanner: a câmera ocupa a tela e o resto não compete.
const Color _fundoScanner = Color(0xFF121A12);
const Color _verdeMoldura = Color(0xFFA5D6A7);

class TelaScanner extends StatefulWidget {
  const TelaScanner({super.key});

  @override
  State<TelaScanner> createState() => _TelaScannerState();
}

class _TelaScannerState extends State<TelaScanner>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _controladorCamera;
  Future<void>? _inicializacaoCamera;
  String? _erroCamera;
  bool _processando = false;
  bool _falhaIdentificacao = false;
  String _mensagemFalha = _mensagemNaoIdentificado;
  bool _cameraPausada = false;
  bool _lanternaLigada = false;

  // Carregado uma vez por tela; se falhar, o erro aparece na primeira captura.
  Future<ClassificadorComponente>? _classificador;

  late final AnimationController _pulsoController;
  late final ScannerService _scannerService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulsoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scannerService = ScannerService(context.read());

    if (!ClassificadorComponente.suportado) {
      // Na web não há modelo: mostra direto o aviso de indisponível.
      _erroCamera = 'Scanner IA indisponível no navegador.';
      _falhaIdentificacao = true;
      _mensagemFalha = _mensagemSemSuporte;
      return;
    }

    _classificador = ClassificadorComponente.carregar()..ignore();
    _inicializarCamera();
  }

  Future<void> _inicializarCamera() async {
    try {
      final List<CameraDescription> cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        _mostrarFalhaCamera('Nenhuma câmera encontrada neste dispositivo.');
        return;
      }
      final CameraDescription camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final CameraController controlador = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      _controladorCamera = controlador;
      // O setState não pode devolver o Future (em debug isso é um erro).
      final Future<void> inicializacao = controlador.initialize();
      setState(() {
        _inicializacaoCamera = inicializacao;
      });
      await inicializacao;
      // Redesenha o topo para mostrar o botão da lanterna.
      if (mounted) setState(() {});
    } catch (e, pilha) {
      _registrar('falha ao abrir a câmera: $e');
      Sentry.captureException(e, stackTrace: pilha);
      if (!mounted) return;
      _mostrarFalhaCamera(
        'Não foi possível acessar a câmera. Verifique a permissão do app.',
      );
    }
  }

  // Vai para o console (adb logcat / flutter run) e fica como "breadcrumb"
  // no Sentry, anexado ao próximo erro reportado.
  void _registrar(String mensagem) {
    debugPrint('Scanner IA: $mensagem');
    Sentry.addBreadcrumb(Breadcrumb(message: mensagem, category: 'scanner'));
  }

  void _mostrarFalhaCamera(String erro) {
    setState(() {
      _erroCamera = erro;
      _processando = false;
      _falhaIdentificacao = true;
      _mensagemFalha = _mensagemSemCamera;
    });
  }

  // Sem câmera, o painel de falha continua visível.
  void _encerrarProcessamento() {
    setState(() {
      _processando = false;
      _falhaIdentificacao = _erroCamera != null;
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      final CameraController? controlador = _controladorCamera;
      // Só libera uma câmera já pronta: durante a inicialização o app fica
      // "inactive" enquanto o diálogo de permissão está aberto.
      if (controlador == null || !controlador.value.isInitialized) return;
      setState(() {
        _controladorCamera = null;
        _cameraPausada = true;
        _lanternaLigada = false;
      });
      controlador.dispose();
    } else if (state == AppLifecycleState.resumed && _cameraPausada) {
      _cameraPausada = false;
      _inicializarCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulsoController.dispose();
    _controladorCamera?.dispose();
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
            // --- CÂMERA EM TELA CHEIA, COM O TOPO POR CIMA ---
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _construirAreaCamera(),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    // Escurece o topo para o título e os botões ficarem
                    // legíveis sobre qualquer imagem da câmera.
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x99000000), Color(0x00000000)],
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _construirTopo(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- STATUS + BOTÃO DE CAPTURA / PAINEL DE ERRO ---
            _falhaIdentificacao
                ? _construirPainelErro()
                : _construirPainelEscaneando(),
          ],
        ),

        // --- BARRA DE NAVEGAÇÃO INFERIOR ---
        bottomNavigationBar: const EcoBottomNavBar(tabAtual: EcoTab.scanner),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES PARA NÃO REPETIR CÓDIGO ---

  bool get _cameraPronta {
    final CameraController? controlador = _controladorCamera;
    return controlador != null && controlador.value.isInitialized;
  }

  Future<void> _alternarLanterna() async {
    final CameraController? controlador = _controladorCamera;
    if (controlador == null || !controlador.value.isInitialized) return;
    final bool ligar = !_lanternaLigada;
    try {
      await controlador.setFlashMode(ligar ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _lanternaLigada = ligar);
    } on CameraException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este aparelho não tem lanterna.')),
      );
    }
  }

  Widget _construirTopo() {
    const Color fundoBotao = Color(0x73000000);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          BotaoCircularEco(
            icone: Icons.chevron_left,
            tooltip: 'Voltar',
            corFundo: fundoBotao,
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
          if (_cameraPronta)
            BotaoCircularEco(
              icone: _lanternaLigada
                  ? Icons.flashlight_off_outlined
                  : Icons.flashlight_on_outlined,
              tooltip: _lanternaLigada ? 'Desligar lanterna' : 'Ligar lanterna',
              corFundo: _lanternaLigada ? const Color(0xE6FFFFFF) : fundoBotao,
              corIcone: _lanternaLigada
                  ? AppColors.verdeEscuro
                  : AppColors.fundoBranco,
              onPressed: _alternarLanterna,
            ),
        ],
      ),
    );
  }

  Widget _construirAreaCamera() {
    if (_erroCamera != null) {
      return Container(
        color: const Color(0xFF263228),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videocam_off_outlined,
                color: Colors.white54,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _erroCamera!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        FutureBuilder<void>(
          future: _inicializacaoCamera,
          builder: (context, snapshot) {
            final CameraController? controlador = _controladorCamera;
            if (snapshot.connectionState == ConnectionState.done &&
                controlador != null &&
                controlador.value.isInitialized) {
              return ClipRect(
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controlador.value.previewSize?.height ?? 1,
                      height: controlador.value.previewSize?.width ?? 1,
                      child: CameraPreview(controlador),
                    ),
                  ),
                ),
              );
            }
            return const ColoredBox(
              color: Color(0xFF263228),
              child: Center(
                child: CircularProgressIndicator(color: _verdeMoldura),
              ),
            );
          },
        ),
        if (_falhaIdentificacao)
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x73000000),
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: const Icon(
                Icons.priority_high_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          )
        else ...[
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _MolduraScanner()),
                  ),
                  // Linha de varredura pulsando no meio da moldura.
                  Center(
                    child: FadeTransition(
                      opacity: _pulsoController,
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: _verdeMoldura,
                          borderRadius: BorderRadius.circular(1),
                          boxShadow: const [
                            BoxShadow(color: _verdeMoldura, blurRadius: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.9),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0x80000000),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _processando
                    ? 'Analisando...'
                    : 'Centralize o aparelho no quadrado',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _rotuloReconhecidos() {
    final int quantidade =
        ClassificadorComponente.componentesReconhecidos.length;
    return quantidade == 1
        ? 'A IA RECONHECE 1 APARELHO'
        : 'A IA RECONHECE $quantidade APARELHOS';
  }

  Widget _construirPainelEscaneando() {
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
            label: 'Tirar foto e identificar',
            child: GestureDetector(
              onTap: _processando ? null : _capturarEAnalisar,
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
          ..._botaoGaleriaDebug(),
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
              onPressed: _processando ? null : _tentarNovamente,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Tentar novamente'),
              style: BotoesEco.principal(altura: 52),
            ),
          ],
          ..._botaoGaleriaDebug(),
        ],
      ),
    );
  }

  List<Widget> _botaoGaleriaDebug() {
    if (!kDebugMode || !ClassificadorComponente.suportado) return const [];
    return [
      const SizedBox(height: 8),
      Center(
        child: TextButton.icon(
          onPressed: _processando ? null : _escolherDaGaleria,
          icon: const Icon(Icons.photo_library_outlined, size: 18),
          label: const Text('Escolher da galeria (debug)'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.verdeGradienteInicio,
          ),
        ),
      ),
    ];
  }

  void _tentarNovamente() {
    final CameraController? controlador = _controladorCamera;
    if (controlador != null && controlador.value.isInitialized) {
      _capturarEAnalisar();
      return;
    }
    // A câmera falhou antes: tenta abri-la de novo em vez de capturar.
    setState(() {
      _erroCamera = null;
      _falhaIdentificacao = false;
    });
    _inicializarCamera();
  }

  Future<void> _capturarEAnalisar() => _analisar(() {
    final CameraController? controlador = _controladorCamera;
    if (controlador == null || !controlador.value.isInitialized) {
      throw StateError('Câmera indisponível.');
    }
    return controlador.takePicture();
  });

  // Só em debug: analisa uma foto da galeria, para testar o modelo no
  // emulador sem câmera.
  Future<void> _escolherDaGaleria() =>
      _analisar(() => ImagePicker().pickImage(source: ImageSource.gallery));

  /// [obterFoto] devolve null quando o usuário desiste (ex.: fecha a galeria).
  Future<void> _analisar(Future<XFile?> Function() obterFoto) async {
    setState(() {
      _processando = true;
      _falhaIdentificacao = false;
    });

    // A foto é analisada aqui, on-device; apenas o identificador e a confiança
    // vão para o back-end, que decide se a leitura passa do limiar.
    final ClassificacaoComponente classificacao;
    try {
      final Future<ClassificadorComponente>? classificador = _classificador;
      if (classificador == null) throw StateError('Modelo indisponível.');
      final XFile? foto = await obterFoto();
      if (foto == null) {
        if (mounted) _encerrarProcessamento();
        return;
      }
      final bytes = await foto.readAsBytes();
      classificacao = await (await classificador).classificar(bytes);
      _registrar(
        '${classificacao.identificador.valor} '
        '(${classificacao.confianca.toStringAsFixed(1)}%)',
      );
    } catch (e, pilha) {
      _registrar('falha ao analisar a foto: $e');
      Sentry.captureException(e, stackTrace: pilha);
      if (!mounted) return;
      _mostrarFalha(_mensagemNaoIdentificado);
      return;
    }
    if (!mounted) return;

    try {
      final resultado = await _scannerService.reconhecer(
        classificacao.identificador,
        classificacao.confianca,
      );

      if (!mounted) return;

      if (!resultado.reconhecido || resultado.figurinha == null) {
        // Não é erro, mas ajuda a calibrar o limiar do back-end.
        Sentry.captureMessage(
          'Scanner IA: leitura recusada pelo back-end '
          '(${classificacao.identificador.valor}, '
          '${classificacao.confianca.toStringAsFixed(1)}%): '
          '${resultado.mensagem}',
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

class _MolduraScanner extends CustomPainter {
  static const double _tamanhoCanto = 40;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint tinta = Paint()
      ..color = _verdeMoldura
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Canto superior esquerdo
    canvas.drawPath(
      Path()
        ..moveTo(0, _tamanhoCanto)
        ..lineTo(0, 0)
        ..lineTo(_tamanhoCanto, 0),
      tinta,
    );
    // Canto superior direito
    canvas.drawPath(
      Path()
        ..moveTo(size.width - _tamanhoCanto, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, _tamanhoCanto),
      tinta,
    );
    // Canto inferior esquerdo
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - _tamanhoCanto)
        ..lineTo(0, size.height)
        ..lineTo(_tamanhoCanto, size.height),
      tinta,
    );
    // Canto inferior direito
    canvas.drawPath(
      Path()
        ..moveTo(size.width - _tamanhoCanto, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - _tamanhoCanto),
      tinta,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
