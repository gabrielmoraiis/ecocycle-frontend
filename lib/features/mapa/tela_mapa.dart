import 'package:flutter/material.dart';
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

  bool _carregando = true;
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

  Future<void> _carregarPontos({double? lat, double? lng}) async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final pontos = await _pontoColetaService.listar(
        lat: lat,
        lng: lng,
        raioKm: 5,
      );
      setState(() {
        _pontos = pontos;
        _indicePontoSelecionado = 0;
      });
    } on ApiException catch (e) {
      setState(() => _erro = e);
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
                        onPressed: _buscarPorCep,
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
                        child: const Text(
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

            // --- MAPA ---
            Expanded(
              child: _carregando
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
                          },
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
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
                      ],
                    ),
            ),

            // --- PAINEL DE PONTOS ENCONTRADOS ---
            Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.bordaVerdeClara,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                            color: AppColors.textoCinzaClaro,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (pontos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Nenhum ponto encontrado para esse filtro.',
                        style: TextStyle(color: AppColors.textoCinzaClaro),
                      ),
                    )
                  else ...[
                    SizedBox(
                      height: 108,
                      child: ListView.separated(
                        itemCount: pontos.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) => _construirCartaoPonto(
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
                        onPressed: () => _abrirRota(pontos[indiceSelecionado]),
                        icon: const Icon(Icons.navigation_outlined, size: 20),
                        label: const Text(
                          'Como chegar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.verdeGradienteInicio,
                          foregroundColor: AppColors.fundoBranco,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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

      // --- BARRA DE NAVEGAÇÃO INFERIOR ---
      bottomNavigationBar: const EcoBottomNavBar(tabAtual: EcoTab.mapa),
    );
  }

  // --- MÉTODOS AUXILIARES PARA NÃO REPETIR CÓDIGO ---

  void _buscarPorCep() {
    setState(() {
      _cepPesquisado = _cepController.text.trim();
      _indicePontoSelecionado = 0;
    });
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
      await _controladorMapa?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(posicao.latitude, posicao.longitude),
          15,
        ),
      );
      await _carregarPontos(lat: posicao.latitude, lng: posicao.longitude);
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
