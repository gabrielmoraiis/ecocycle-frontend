import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../album/tela_album.dart';
import '../album/tela_info_figurinha.dart';
import '../aprender/tela_aprender.dart';
import '../mapa/tela_mapa.dart';

class TelaScanner extends StatefulWidget {
  const TelaScanner({super.key});

  @override
  State<TelaScanner> createState() => _TelaScannerState();
}

class _TelaScannerState extends State<TelaScanner> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final int _abaSelecionada = 3; // Scanner selecionado por padrão

  CameraController? _controladorCamera;
  Future<void>? _inicializacaoCamera;
  String? _erroCamera;
  bool _processando = false;
  bool _falhaIdentificacao = false;

  final Random _sorteio = Random();
  late final AnimationController _pulsoController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulsoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _inicializarCamera();
  }

  Future<void> _inicializarCamera() async {
    try {
      final List<CameraDescription> cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _erroCamera = 'Nenhuma câmera encontrada neste dispositivo.');
        return;
      }
      final CameraDescription camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final CameraController controlador = CameraController(camera, ResolutionPreset.medium, enableAudio: false);
      _controladorCamera = controlador;
      setState(() => _inicializacaoCamera = controlador.initialize());
      await _inicializacaoCamera;
    } catch (e) {
      setState(() => _erroCamera = 'Não foi possível acessar a câmera. Verifique a permissão do app.');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? controlador = _controladorCamera;
    if (controlador == null || !controlador.value.isInitialized) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      controlador.dispose();
      _controladorCamera = null;
    } else if (state == AppLifecycleState.resumed) {
      _inicializarCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulsoController.dispose();
    _controladorCamera?.dispose();
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
                        icon: const Icon(Icons.chevron_left, color: AppColors.verdeGradienteInicio),
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
            _falhaIdentificacao ? _construirPainelErro() : _construirPainelEscaneando(),
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
              const Icon(Icons.videocam_off_outlined, color: Colors.white54, size: 48),
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
            if (snapshot.connectionState == ConnectionState.done && controlador != null && controlador.value.isInitialized) {
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
            return const Center(child: CircularProgressIndicator(color: AppColors.destaqueVerdeClaro));
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
              child: const Icon(Icons.priority_high_rounded, color: Colors.white, size: 32),
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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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
                      child: CircularProgressIndicator(color: AppColors.fundoBranco, strokeWidth: 3),
                    )
                  : const Icon(Icons.camera_alt, color: AppColors.fundoBranco, size: 30),
            ),
          ),
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
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tente aproximar mais a câmera ou melhore a iluminação do ambiente.',
                  style: TextStyle(fontSize: 13, color: Colors.red.shade400, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _capturarEAnalisar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verdeGradienteInicio,
                foregroundColor: AppColors.fundoBranco,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Tentar novamente', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _abrirBuscaManual,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.verdeGradienteInicio,
                backgroundColor: AppColors.fundoBranco,
                side: const BorderSide(color: AppColors.bordaVerdeClara),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Buscar manualmente por nome', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _capturarEAnalisar() async {
    setState(() {
      _processando = true;
      _falhaIdentificacao = false;
    });

    // Simula o tempo de análise da IA (sem backend de reconhecimento real ainda).
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final ComponenteAlbum? componente = AlbumRepositorio.proximoParaDesbloquear();
    // Sem componente restante para descobrir ou "falha" simulada de reconhecimento.
    final bool falhou = componente == null || _sorteio.nextDouble() < 0.25;

    if (falhou) {
      setState(() {
        _processando = false;
        _falhaIdentificacao = true;
      });
      return;
    }

    AlbumRepositorio.desbloquear(componente);
    setState(() => _processando = false);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TelaInfoFigurinha(componente: componente)),
    );
  }

  void _abrirBuscaManual() {
    final List<ComponenteAlbum> disponiveis =
        componentesEscaneaveis.where((c) => !AlbumRepositorio.foiDesbloqueado(c)).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.fundoBranco,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textoEscuro),
                ),
                const SizedBox(height: 16),
                if (disponiveis.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Nenhum componente disponível para busca manual no momento.',
                      style: TextStyle(color: AppColors.textoCinzaClaro),
                    ),
                  )
                else
                  for (final componente in disponiveis)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: componente.corFundo, borderRadius: BorderRadius.circular(10)),
                        child: Icon(componente.icone, color: componente.corIcone, size: 20),
                      ),
                      title: Text(componente.titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(componente.subtitulo),
                      onTap: () => _selecionarManualmente(componente),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selecionarManualmente(ComponenteAlbum componente) {
    AlbumRepositorio.desbloquear(componente);
    Navigator.pop(context); // fecha o bottom sheet
    setState(() => _falhaIdentificacao = false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TelaInfoFigurinha(componente: componente)),
    );
  }

  void _abrirAlbum(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaAlbum()));
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
        } else if (indice == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaAprender()));
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
