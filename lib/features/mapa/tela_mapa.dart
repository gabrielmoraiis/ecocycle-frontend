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
import '../../core/widgets/layout_eco.dart';
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
  final TextEditingController _cepController = TextEditingController();

  late final PontoColetaService _pontoColetaService;
  GoogleMapController? _controladorMapa;
  String _filtroSelecionado = 'Todos';
  String _cepPesquisado = '';
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
      body: _carregando && _primeiraCarga
          ? const SafeArea(child: LoadingIndicator())
          : _erro != null
          ? SafeArea(
              child: ErrorState(
                message: _erro!.message,
                onRetry: () => _carregarPontos(),
              ),
            )
          : Stack(
              children: [
                // --- MAPA EM TELA CHEIA ---
                Positioned.fill(
                  child: GoogleMap(
                    initialCameraPosition: _posicaoInicial,
                    onMapCreated: (controller) => _controladorMapa = controller,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    // Mantém o logo e os pinos fora da busca e do painel.
                    padding: const EdgeInsets.only(top: 150, bottom: 300),
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
                          infoWindow: InfoWindow(title: 'CEP $_cepPesquisado'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRose,
                          ),
                        ),
                    },
                  ),
                ),

                // --- BUSCA + FILTROS FLUTUANDO NO TOPO ---
                Positioned(
                  left: 12,
                  right: 12,
                  top: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _construirBusca(),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _construirChipFiltro('Todos'),
                                const SizedBox(width: 8),
                                _construirChipFiltro('Celulares'),
                                const SizedBox(width: 8),
                                _construirChipFiltro('Baterias'),
                              ],
                            ),
                          ),
                          if (_carregando) ...[
                            const SizedBox(height: 10),
                            const Center(
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
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // --- PAINEL DE BAIXO + BOTÃO DE LOCALIZAÇÃO ---
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 14, bottom: 12),
                        child: FloatingActionButton(
                          heroTag: 'localizacaoAtual',
                          backgroundColor: AppColors.fundoBranco,
                          foregroundColor: AppColors.verdeCabecalho,
                          elevation: 3,
                          tooltip: 'Ir para minha localização',
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
                      _construirPainel(pontos, indiceSelecionado),
                    ],
                  ),
                ),
              ],
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

  Widget _construirBusca() {
    return Material(
      color: AppColors.fundoBranco,
      elevation: 4,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 6, 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.chevron_left,
                color: AppColors.verdeCabecalho,
              ),
              tooltip: 'Voltar',
              onPressed: () => Navigator.maybePop(context),
            ),
            Expanded(
              child: TextField(
                controller: _cepController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _buscarPorCep(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoTitulo,
                ),
                decoration: const InputDecoration(
                  labelText: 'BUSCAR POR CEP',
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: AppColors.textoSecundario,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: '00000-000',
                  hintStyle: TextStyle(color: AppColors.textoCinzaClaro),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 6),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Material(
              color: AppColors.verdeGradienteInicio,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _buscandoCep ? null : _buscarPorCep,
                child: SizedBox(
                  width: 46,
                  height: 46,
                  child: Center(
                    child: _buscandoCep
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.fundoBranco,
                            ),
                          )
                        : const Icon(
                            Icons.search,
                            color: AppColors.fundoBranco,
                            semanticLabel: 'Buscar',
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirChipFiltro(String rotulo) {
    final bool selecionado = _filtroSelecionado == rotulo;
    return Material(
      color: selecionado ? AppColors.verdeEscuro : AppColors.fundoBranco,
      elevation: 2,
      shadowColor: const Color(0x26000000),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() {
          _filtroSelecionado = rotulo;
          _indicePontoSelecionado = 0;
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            rotulo,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: selecionado
                  ? AppColors.fundoBranco
                  : AppColors.textoTitulo,
            ),
          ),
        ),
      ),
    );
  }

  /// Seleciona um ponto na lista e centraliza o mapa nele.
  void _selecionarPonto(PontoColeta ponto, int indice) {
    setState(() {
      _indicePontoSelecionado = indice;
      _painelExpandido = false;
    });
    _controladorMapa?.animateCamera(
      CameraUpdate.newLatLng(LatLng(ponto.latitude, ponto.longitude)),
    );
  }

  Widget _construirPainel(List<PontoColeta> pontos, int indiceSelecionado) {
    final bool ordenadoPorDistancia =
        pontos.isNotEmpty && pontos.first.distanciaKm != null;
    final String titulo = !ordenadoPorDistancia
        ? 'PONTOS DE COLETA'
        : _cepPesquisado == 'você'
        ? 'MAIS PRÓXIMO DE VOCÊ'
        : 'MAIS PRÓXIMO DE $_cepPesquisado';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.fundoBranco,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.bordaVerdeClara,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  _painelExpandido ? 'TODOS OS PONTOS' : titulo,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: AppColors.verdeCabecalho,
                  ),
                ),
              ),
              if (pontos.length > 1)
                TextButton(
                  onPressed: () =>
                      setState(() => _painelExpandido = !_painelExpandido),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.verdeCabecalho,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    _painelExpandido
                        ? 'Fechar'
                        : 'Ver todos (${pontos.length})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (pontos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Nenhum ponto encontrado para esse filtro.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textoSecundario),
              ),
            )
          else if (_painelExpandido)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: pontos.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) => _construirLinhaPonto(
                  pontos[index],
                  index,
                  index == indiceSelecionado,
                ),
              ),
            )
          else ...[
            _construirDetalhePonto(pontos[indiceSelecionado]),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _abrirRota(pontos[indiceSelecionado]),
              icon: const Icon(Icons.navigation_outlined, size: 20),
              label: const Text('Como chegar'),
              style: BotoesEco.principal(altura: 50),
            ),
          ],
        ],
      ),
    );
  }

  String _formatarDistancia(PontoColeta ponto) =>
      '${ponto.distanciaKm!.toStringAsFixed(1).replaceAll('.', ',')} km';

  Widget _construirDetalhePonto(PontoColeta ponto) {
    const int maxTags = 3;
    final tipos = ponto.tiposResiduoAceitos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconeQuadradoEco(
              icone: Icons.recycling,
              cor: AppColors.verdeCabecalho,
              corFundo: AppColors.verdeSobreCabecalho,
              tamanho: 48,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          ponto.nome,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textoTitulo,
                          ),
                        ),
                      ),
                      if (ponto.distanciaKm != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formatarDistancia(ponto),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.verdeCabecalho,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ponto.endereco,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppColors.verdeCabecalho,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ponto.horarioFuncionamento,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF2E5E30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (tipos.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tipo in tipos.take(maxTags))
                _construirTagCategoria(tipo),
              if (tipos.length > maxTags)
                _construirTagCategoria(
                  '+${tipos.length - maxTags}',
                  destaque: false,
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _construirLinhaPonto(PontoColeta ponto, int indice, bool selecionado) {
    return Material(
      color: selecionado ? AppColors.verdeClaroFundo : Colors.transparent,
      child: InkWell(
        onTap: () => _selecionarPonto(ponto, indice),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: selecionado
                    ? AppColors.verdeGradienteInicio
                    : AppColors.azulIcone,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ponto.nome,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textoTitulo,
                      ),
                    ),
                    Text(
                      ponto.endereco,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
              if (ponto.distanciaKm != null) ...[
                const SizedBox(width: 8),
                Text(
                  _formatarDistancia(ponto),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.verdeCabecalho,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirTagCategoria(String texto, {bool destaque = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: destaque ? AppColors.verdeClaroFundo : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: destaque ? AppColors.verdeEscuro : AppColors.textoSecundario,
        ),
      ),
    );
  }
}
