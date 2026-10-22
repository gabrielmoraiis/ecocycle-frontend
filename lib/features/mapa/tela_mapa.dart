import 'dart:math' show max, min;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/ponto_coleta.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/ponto_coleta_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/eco_bottom_nav_bar.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_indicator.dart';

// Centralizado na região dos pontos de coleta cadastrados (região central de São Paulo).
const CameraPosition _posicaoInicial = CameraPosition(
  target: LatLng(-23.561, -46.665),
  zoom: 12,
);

class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  final TextEditingController _cepController = TextEditingController(
    text: '06600-000',
  );

  late final PontoColetaService _pontoColetaService;
  GoogleMapController? _controladorMapa;
  String _filtroSelecionado = 'Todos';
  String _cepPesquisado = '06600-000';
  int _indicePontoSelecionado = 0;
  bool _buscandoLocalizacao = false;
  bool _buscandoCep = false;
  bool _painelExpandido = false;
  LatLng? _centroBusca;

  bool _carregando = true;
  // Só a primeira carga ocupa a tela inteira; recargas (CEP/localização)
  // mantêm o GoogleMap montado para o controlador continuar válido.
  bool _primeiraCarga = true;
  ApiException? _erro;
  List<PontoColeta> _pontos = [];

  @override
  void initState() {
    super.initState();
    _pontoColetaService = PontoColetaService(context.read());
    _carregarPontos();
  }

  @override
  void dispose() {
    _cepController.dispose();
    _controladorMapa?.dispose();
    super.dispose();
  }

  // Carrega todos os pontos uma única vez (são poucos); buscas por CEP ou
  // localização só reordenam por distância, sem filtrar por raio.
  Future<void> _carregarPontos() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final pontos = await _pontoColetaService.listar();
      if (!mounted) return;
      setState(() {
        _pontos = pontos;
        _indicePontoSelecionado = 0;
        _primeiraCarga = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (_primeiraCarga) {
        setState(() => _erro = e);
      } else {
        _mostrarAviso(e.message);
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<PontoColeta> get _pontosFiltrados {
    if (_filtroSelecionado == 'Todos') return _pontos;
    return _pontos
        .where((p) => p.tiposResiduoAceitos.contains(_filtroSelecionado))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<PontoColeta> pontos = _pontosFiltrados;
    final int indiceSelecionado = _indicePontoSelecionado < pontos.length
        ? _indicePontoSelecionado
        : 0;

    return Scaffold(
      backgroundColor: AppColors.fundoBranco,
      body: SafeArea(
        child: Column(
          children: [
            // --- TOPO: VOLTAR + LOGO ---
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
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textoEscuro,
                      ),
                      children: [
                        TextSpan(text: 'Eco'),
                        TextSpan(
                          text: 'Cycle',
                          style: TextStyle(
                            color: AppColors.verdeGradienteInicio,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- BUSCA + FILTROS ---
            Container(
              width: double.infinity,
              color: AppColors.fundoBranco,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ENCONTRAR PONTOS DE COLETA',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoEscuro,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.verdeClaroFundo,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.bordaVerdeClara,
                            ),
                          ),
                          child: TextField(
                            controller: _cepController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _buscarPorCep(),
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textoEscuro,
                            ),
                            decoration: const InputDecoration(
                              hintText: '06600-000',
                              hintStyle: TextStyle(
                                color: AppColors.textoCinzaClaro,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _buscandoCep ? null : _buscarPorCep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.verdeGradienteInicio,
                          foregroundColor: AppColors.fundoBranco,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _buscandoCep
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.fundoBranco,
                                ),
                              )
                            : const Text(
                                'Buscar',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _construirChipFiltro('Todos'),
                      const SizedBox(width: 8),
                      _construirChipFiltro('Celulares'),
                      const SizedBox(width: 8),
                      _construirChipFiltro('Baterias'),
                    ],
                  ),
                ],
              ),
            ),

            // --- MAPA + PAINEL DE PONTOS (painel flutua sobre o mapa como
            // overlay: expandir/recolher não redimensiona o GoogleMap, que é
            // caro para relayoutar a cada frame da animação) ---
            Expanded(
              child: _carregando && _primeiraCarga
                  ? const LoadingIndicator()
                  : _erro != null
                  ? ErrorState(
                      message: _erro!.message,
                      onRetry: () => _carregarPontos(),
                    )
                  : Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: _posicaoInicial,
                          onMapCreated: (controller) =>
                              _controladorMapa = controller,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: true,
                          markers: {
                            for (int i = 0; i < pontos.length; i++)
                              Marker(
                                markerId: MarkerId(pontos[i].id.toString()),
                                position: LatLng(
                                  pontos[i].latitude,
                                  pontos[i].longitude,
                                ),
                                infoWindow: InfoWindow(
                                  title: pontos[i].nome,
                                  snippet: pontos[i].endereco,
                                ),
                                icon: i == indiceSelecionado
                                    ? BitmapDescriptor.defaultMarkerWithHue(
                                        BitmapDescriptor.hueGreen,
                                      )
                                    : BitmapDescriptor.defaultMarkerWithHue(
                                        BitmapDescriptor.hueAzure,
                                      ),
                                onTap: () =>
                                    setState(() => _indicePontoSelecionado = i),
                              ),
                            if (_centroBusca != null)
                              Marker(
                                markerId: const MarkerId('centroBusca'),
                                position: _centroBusca!,
                                infoWindow: InfoWindow(
                                  title: 'CEP $_cepPesquisado',
                                ),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueRose,
                                ),
                              ),
                          },
                        ),
                        if (_carregando)
                          const Positioned(
                            top: 12,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Card(
                                shape: CircleBorder(),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.verdeGradienteInicio,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          right: 16,
                          bottom: 96,
                          child: FloatingActionButton(
                            heroTag: 'localizacaoAtual',
                            backgroundColor: AppColors.fundoBranco,
                            foregroundColor: AppColors.verdeGradienteInicio,
                            elevation: 3,
                            onPressed: _buscandoLocalizacao
                                ? null
                                : _irParaLocalizacaoAtual,
                            child: _buscandoLocalizacao
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.my_location),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: AppColors.fundoBranco,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 12,
                                  offset: Offset(0, -4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => setState(
                                    () => _painelExpandido = !_painelExpandido,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 40,
                                          height: 4,
                                          margin: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.bordaVerdeClara,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${pontos.length} ponto${pontos.length == 1 ? '' : 's'} encontrado${pontos.length == 1 ? '' : 's'}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textoEscuro,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'próximos a $_cepPesquisado',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color:
                                                    AppColors.textoCinzaClaro,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          AnimatedRotation(
                                            turns: _painelExpandido ? 0.5 : 0,
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            child: const Icon(
                                              Icons.keyboard_arrow_up,
                                              color: AppColors.textoCinzaClaro,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 220),
                                  sizeCurve: Curves.easeInOut,
                                  crossFadeState: _painelExpandido
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  firstChild: const SizedBox(
                                    width: double.infinity,
                                  ),
                                  secondChild: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      if (pontos.isEmpty)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 24,
                                          ),
                                          child: Text(
                                            'Nenhum ponto encontrado para esse filtro.',
                                            style: TextStyle(
                                              color: AppColors.textoCinzaClaro,
                                            ),
                                          ),
                                        )
                                      else ...[
                                        SizedBox(
                                          height: 108,
                                          child: ListView.separated(
                                            itemCount: pontos.length,
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(height: 10),
                                            itemBuilder: (context, index) =>
                                                _construirCartaoPonto(
                                                  pontos[index],
                                                  index,
                                                  indiceSelecionado,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () => _abrirRota(
                                              pontos[indiceSelecionado],
                                            ),
                                            icon: const Icon(
                                              Icons.navigation_outlined,
                                              size: 20,
                                            ),
                                            label: const Text(
                                              'Como chegar',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors
                                                  .verdeGradienteInicio,
                                              foregroundColor:
                                                  AppColors.fundoBranco,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              elevation: 0,
                                            ),
                                          ),
                                        ),
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
          ],
        ),
      ),
      // --- BARRA DE NAVEGAÇÃO INFERIOR ---
      bottomNavigationBar: const EcoBottomNavBar(tabAtual: EcoTab.mapa),
    );
  }

  // --- MÉTODOS AUXILIARES PARA NÃO REPETIR CÓDIGO ---

  Future<void> _buscarPorCep() async {
    if (_buscandoCep) return;
    FocusScope.of(context).unfocus();

    final String cep = _cepController.text.replaceAll(RegExp(r'\D'), '');
    if (cep.length != 8) {
      _mostrarAviso('Digite um CEP válido com 8 dígitos.');
      return;
    }
    if (kIsWeb) {
      _mostrarAviso('A busca por CEP está disponível apenas no app.');
      return;
    }

    final String cepFormatado = '${cep.substring(0, 5)}-${cep.substring(5)}';
    setState(() => _buscandoCep = true);
    try {
      final LatLng? centro = await _geocodificarCep(cepFormatado);
      if (!mounted) return;
      if (centro == null) {
        _mostrarAviso('Não encontramos esse CEP. Confira e tente novamente.');
        return;
      }

      setState(() {
        _cepController.text = cepFormatado;
        _cepPesquisado = cepFormatado;
        _centroBusca = centro;
      });
      _ordenarPorDistancia(centro);
      await _enquadrarBusca(centro);
    } finally {
      if (mounted) setState(() => _buscandoCep = false);
    }
  }

  // Geocoder nativo do Android/iOS: não precisa de chave de API.
  Future<LatLng?> _geocodificarCep(String cepFormatado) async {
    try {
      final List<Location> locais = await Geocoding().locationFromAddress(
        '$cepFormatado, Brasil',
      );
      if (locais.isEmpty) return null;
      return LatLng(locais.first.latitude, locais.first.longitude);
    } catch (_) {
      return null;
    }
  }

  /// Calcula a distância de cada ponto até [origem] e ordena a lista do mais
  /// próximo ao mais distante; o mais próximo já fica selecionado.
  void _ordenarPorDistancia(LatLng origem) {
    final ordenados = [
      for (final ponto in _pontos)
        ponto.comDistancia(
          Geolocator.distanceBetween(
                origem.latitude,
                origem.longitude,
                ponto.latitude,
                ponto.longitude,
              ) /
              1000,
        ),
    ]..sort((a, b) => a.distanciaKm!.compareTo(b.distanciaKm!));

    setState(() {
      _pontos = ordenados;
      _indicePontoSelecionado = 0;
      _painelExpandido = true;
    });
  }

  /// Ajusta a câmera para mostrar a origem da busca junto com o ponto de
  /// coleta mais próximo; sem pontos, apenas aproxima na origem.
  Future<void> _enquadrarBusca(LatLng centro) async {
    final GoogleMapController? controlador = _controladorMapa;
    if (controlador == null) return;

    final List<PontoColeta> pontos = _pontosFiltrados;
    if (pontos.isEmpty) {
      await controlador.animateCamera(CameraUpdate.newLatLngZoom(centro, 14));
      return;
    }

    final PontoColeta maisProximo = pontos.first;
    final double minLat = min(centro.latitude, maisProximo.latitude);
    final double maxLat = max(centro.latitude, maisProximo.latitude);
    final double minLng = min(centro.longitude, maisProximo.longitude);
    final double maxLng = max(centro.longitude, maisProximo.longitude);
    await controlador.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        72,
      ),
    );
  }

  Future<void> _irParaLocalizacaoAtual() async {
    setState(() => _buscandoLocalizacao = true);
    try {
      bool servicoAtivo = await Geolocator.isLocationServiceEnabled();
      if (!servicoAtivo) {
        _mostrarAviso(
          'Ative a localização do dispositivo para usar essa opção.',
        );
        return;
      }

      LocationPermission permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }
      if (permissao == LocationPermission.denied ||
          permissao == LocationPermission.deniedForever) {
        _mostrarAviso(
          'Permita o acesso à localização para se centralizar no mapa.',
        );
        return;
      }

      final Position posicao = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final LatLng origem = LatLng(posicao.latitude, posicao.longitude);
      setState(() {
        _cepPesquisado = 'você';
        _centroBusca = null;
      });
      _ordenarPorDistancia(origem);
      await _enquadrarBusca(origem);
    } finally {
      if (mounted) setState(() => _buscandoLocalizacao = false);
    }
  }

  Future<void> _abrirRota(PontoColeta ponto) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${ponto.latitude},${ponto.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _mostrarAviso('Não foi possível abrir o app de mapas.');
    }
  }

  void _mostrarAviso(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Widget _construirChipFiltro(String rotulo) {
    final bool selecionado = _filtroSelecionado == rotulo;
    return GestureDetector(
      onTap: () => setState(() {
        _filtroSelecionado = rotulo;
        _indicePontoSelecionado = 0;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selecionado
              ? AppColors.verdeClaroFundo
              : AppColors.fundoBranco,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selecionado
                ? AppColors.destaqueVerdeClaro
                : AppColors.bordaVerdeClara,
          ),
        ),
        child: Text(
          rotulo,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selecionado
                ? AppColors.verdeEscuroTexto
                : AppColors.textoEscuro,
          ),
        ),
      ),
    );
  }

  Widget _construirCartaoPonto(
    PontoColeta ponto,
    int indice,
    int indiceSelecionado,
  ) {
    final bool selecionado = indice == indiceSelecionado;

    return GestureDetector(
      onTap: () => setState(() => _indicePontoSelecionado = indice),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selecionado
              ? AppColors.verdeClaroFundo
              : AppColors.fundoBranco,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selecionado
                ? AppColors.destaqueVerdeClaro
                : AppColors.bordaVerdeClara,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.fundoBranco,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.verdeGradienteInicio,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ponto.nome,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoEscuro,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ponto.endereco,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textoCinzaClaro,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final tipo in ponto.tiposResiduoAceitos)
                        _construirTagCategoria(tipo),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ponto.distanciaKm == null
                      ? '--'
                      : '${ponto.distanciaKm!.toStringAsFixed(1).replaceAll('.', ',')} km',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.verdeGradienteInicio,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ponto.horarioFuncionamento,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textoCinzaClaro,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirTagCategoria(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 11,
        color: AppColors.textoCinzaClaro,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
