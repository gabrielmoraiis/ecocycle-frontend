import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../core/data/figurinha_presentation_catalog.dart';
import '../../core/ia/classificador_componente.dart';
import '../../core/models/figurinha.dart';
import '../../core/models/identificador_componente.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/figurinhas_provider.dart';
import '../../core/providers/progresso_provider.dart';
import '../../core/services/scanner_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/eco_bottom_nav_bar.dart';
import '../album/tela_info_figurinha.dart';

const String _mensagemNaoIdentificado =
    'Tente aproximar mais a câmera ou melhore a iluminação do ambiente.';
const String _mensagemSemCamera =
    'Não foi possível usar a câmera. Verifique a permissão do app ou busque o componente pelo nome.';
const String _mensagemSemSuporte =
    'O Scanner IA funciona apenas no app para celular. Busque o componente pelo nome.';

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
      // Na web não há modelo: vai direto para a busca manual.
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
      setState(() => _inicializacaoCamera = controlador.initialize());
      await _inicializacaoCamera;
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

  // Sem câmera, o painel de falha (busca manual) continua sendo a saída.
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
    return Scaffold(
      backgroundColor: Colors.black,
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
                        icon: const Icon(
                          Icons.chevron_left,
                          color: AppColors.verdeGradienteInicio,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  const Text(
                    'Scanner IA',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.verdeGradienteInicio,
                    ),
                  ),
                ],
              ),
            ),

            // --- ÁREA DA CÂMERA ---
            Expanded(child: _construirAreaCamera()),

            // --- STATUS + BOTÃO DE CAPTURA / PAINEL DE ERRO ---
            _falhaIdentificacao
                ? _construirPainelErro()
                : _construirPainelEscaneando(),
          ],
        ),
      ),

      // --- BARRA DE NAVEGAÇÃO INFERIOR ---
      bottomNavigationBar: const EcoBottomNavBar(tabAtual: EcoTab.scanner),
    );
  }

  // --- MÉTODOS AUXILIARES PARA NÃO REPETIR CÓDIGO ---

  Widget _construirAreaCamera() {
    if (_erroCamera != null) {
      return Container(
        width: double.infinity,
        color: Colors.black,
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
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.destaqueVerdeClaro,
              ),
            );
          },
        ),
        if (_falhaIdentificacao)
          Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
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
              width: 220,
              height: 220,
              child: CustomPaint(painter: _MolduraScanner()),
            ),
          ),
          const Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Text(
              'Centralize o aparelho no quadrado',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _construirPainelEscaneando() {
    return Container(
      width: double.infinity,
      color: AppColors.verdeClaroFundo,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _pulsoController,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.destaqueVerdeClaro,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _processando ? 'Analisando...' : 'Escaneando...',
                style: const TextStyle(
                  color: AppColors.verdeGradienteInicio,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _processando ? null : _capturarEAnalisar,
            child: Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: AppColors.verdeGradienteInicio,
                shape: BoxShape.circle,
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
                      Icons.camera_alt,
                      color: AppColors.fundoBranco,
                      size: 30,
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
      color: AppColors.verdeClaroFundo,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4E7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF5B8C0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Não conseguimos identificar o aparelho',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _mensagemFalha,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.red.shade400,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (ClassificadorComponente.suportado) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processando ? null : _tentarNovamente,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.verdeGradienteInicio,
                  foregroundColor: AppColors.fundoBranco,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Tentar novamente',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _abrirBuscaManual,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.verdeGradienteInicio,
                backgroundColor: AppColors.fundoBranco,
                side: const BorderSide(color: AppColors.bordaVerdeClara),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Buscar manualmente por nome',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
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
  Future<void> _escolherDaGaleria() => _analisar(
    () => ImagePicker().pickImage(source: ImageSource.gallery),
  );

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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TelaInfoFigurinha(figurinha: resultado.figurinha!),
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

  void _abrirBuscaManual() {
    final bloqueadas = context
        .read<FigurinhasProvider>()
        .bloqueadas
        .where((f) => f.tipo == TipoFigurinha.scan)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.fundoBranco,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buscar componente por nome',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textoEscuro,
                  ),
                ),
                const SizedBox(height: 16),
                if (bloqueadas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Nenhum componente disponível para busca manual no momento.',
                      style: TextStyle(color: AppColors.textoCinzaClaro),
                    ),
                  )
                else
                  for (final figurinha in bloqueadas)
                    Builder(
                      builder: (context) {
                        final apresentacao = apresentacaoDaFigurinha(
                          figurinha.codigo,
                        );
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: apresentacao.corFundo,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              apresentacao.icone,
                              color: apresentacao.corIcone,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            figurinha.nome ??
                                IdentificadorComponente.daFigurinha(
                                  figurinha.codigo,
                                )?.rotulo ??
                                'Componente ${figurinha.codigo}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          onTap: () => _selecionarManualmente(figurinha),
                        );
                      },
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selecionarManualmente(Figurinha figurinha) async {
    final identificador = IdentificadorComponente.daFigurinha(
      figurinha.codigo,
    );
    Navigator.pop(context); // fecha o bottom sheet
    if (identificador == null) return;

    try {
      final resultado = await _scannerService.reconhecer(identificador, 100);
      if (!mounted) return;
      // Sem câmera (ou na web) o painel de falha continua sendo a saída.
      if (_erroCamera == null) setState(() => _falhaIdentificacao = false);
      if (resultado.novaDesbloqueada) {
        context.read<FigurinhasProvider>().recarregar();
        context.read<ProgressoProvider>().recarregar();
      }
      if (resultado.figurinha != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TelaInfoFigurinha(figurinha: resultado.figurinha!),
          ),
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

class _MolduraScanner extends CustomPainter {
  static const double _tamanhoCanto = 32;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint tinta = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
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
