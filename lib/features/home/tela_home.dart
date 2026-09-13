import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/progresso_provider.dart';
import '../../core/theme/app_colors.dart';
import '../album/tela_album.dart';
import '../aprender/tela_aprender.dart';
import '../mapa/tela_mapa.dart';
import '../perfil/tela_perfil.dart';
import '../scanner/tela_scanner.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  int _abaSelecionada = 2; // Início selecionado por padrão

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressoProvider>().carregar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progresso = context.watch<ProgressoProvider>().progresso;
    final int desbloqueadas = progresso?.figurinhasDesbloqueadas ?? 0;
    final int totalFigurinhas = progresso?.totalFigurinhas ?? 10;
    final double progressoAlbum = totalFigurinhas == 0 ? 0 : desbloqueadas / totalFigurinhas;
    return Scaffold(
      backgroundColor: AppColors.verdeClaroFundo,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TOPO: LOGO + NOTIFICAÇÕES ---
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textoEscuro,
                        ),
                        children: [
                          TextSpan(text: 'Eco'),
                          TextSpan(
                            text: 'Cycle',
                            style: TextStyle(color: AppColors.verdeGradienteInicio),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: AppColors.bordaVerdeClara,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.person_outline,
                              color: AppColors.verdeGradienteInicio,
                            ),
                            onPressed: () => _abrirPerfil(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: const BoxDecoration(
                            color: AppColors.bordaVerdeClara,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: AppColors.verdeGradienteInicio,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- BANNER VERDE (HERO) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.verdeGradienteInicio,
                      AppColors.verdeGradienteFim,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DESCARTE CONSCIENTE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppColors.branco70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Seu guia para um futuro mais verde',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textoBranco,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Localize pontos de coleta, aprenda sobre componentes e ganhe recompensas.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.branco70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _construirEstatistica(AppColors.destaqueVerdeClaro, '3% reciclado no BR'),
                        _construirEstatistica(Colors.amber, '2,4M ton/ano'),
                      ],
                    ),
                  ],
                ),
              ),

              // --- SEÇÃO SCANNER IA ---
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _construirTituloSecao('SCANNER IA'),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _abrirScanner(context),
                      child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.verdeGradienteFim,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.branco20,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.desktop_windows_outlined,
                              color: AppColors.textoBranco,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Identificar componente',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textoBranco,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Aponte a câmera para um aparelho e descubra como descartá-lo',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.branco70,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, color: AppColors.textoBranco),
                        ],
                      ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- SEÇÃO EXPLORAR ---
                    _construirTituloSecao('EXPLORAR'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _abrirAprender(context),
                            child: _construirCartaoExplorar(
                              icone: Icons.menu_book_outlined,
                              corIcone: AppColors.verdeGradienteInicio,
                              corFundoIcone: AppColors.verdeClaroFundo,
                              titulo: 'Educação',
                              descricao: 'Aprenda sobre substâncias e descarte correto',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _abrirMapa(context),
                            child: _construirCartaoExplorar(
                              icone: Icons.location_on_outlined,
                              corIcone: Colors.blue,
                              corFundoIcone: const Color(0xFFE3F2FD),
                              titulo: 'Mapa',
                              descricao: 'Pontos de coleta próximos a você',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- CARTÃO ÁLBUM DE COMPONENTES ---
                    GestureDetector(
                      onTap: () => _abrirAlbum(context),
                      child: Container(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Álbum de Componentes',
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textoEscuro,
                                        height: 1.2,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Escaneie aparelhos e leia conteúdos para desbloquear cards',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textoCinzaClaro,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              _construirIconeCard(Icons.battery_std_outlined, Colors.orange, const Color(0xFFFFF3E0)),
                              const SizedBox(width: 8),
                              _construirIconeCard(Icons.developer_board_outlined, AppColors.verdeGradienteInicio, AppColors.verdeClaroFundo),
                              const SizedBox(width: 8),
                              _construirIconeCard(Icons.lock_outline, AppColors.textoCinzaClaro, const Color(0xFFEEEEEE)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progressoAlbum,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFEEEEEE),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.verdeGradienteInicio),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$desbloqueadas de $totalFigurinhas cards desbloqueados',
                            style: const TextStyle(fontSize: 12, color: AppColors.textoCinzaClaro),
                          ),
                        ],
                      ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
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

  void _abrirAlbum(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaAlbum()),
    );
  }

  void _abrirPerfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaPerfil()),
    );
  }

  void _abrirAprender(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaAprender()),
    );
  }

  void _abrirMapa(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaMapa()),
    );
  }

  void _abrirScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaScanner()),
    );
  }

  Widget _construirTituloSecao(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: AppColors.textoCinzaClaro,
      ),
    );
  }

  Widget _construirEstatistica(Color corPonto, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.branco20,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: corPonto, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            texto,
            style: const TextStyle(color: AppColors.textoBranco, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _construirCartaoExplorar({
    required IconData icone,
    required Color corIcone,
    required Color corFundoIcone,
    required String titulo,
    required String descricao,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fundoBranco,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bordaVerdeClara),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: corFundoIcone, borderRadius: BorderRadius.circular(12)),
            child: Icon(icone, color: corIcone, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textoEscuro),
          ),
          const SizedBox(height: 6),
          Text(
            descricao,
            style: const TextStyle(fontSize: 13, color: AppColors.textoCinzaClaro, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _construirIconeCard(IconData icone, Color corIcone, Color corFundo) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: corFundo, borderRadius: BorderRadius.circular(10)),
      child: Icon(icone, color: corIcone, size: 20),
    );
  }

  Widget _construirItemNavegacao(int indice, IconData icone, String rotulo) {
    final bool selecionado = _abaSelecionada == indice;
    final Color cor = selecionado ? AppColors.verdeGradienteInicio : AppColors.textoCinzaClaro;

    return GestureDetector(
      onTap: () {
        if (indice == 4) {
          _abrirAlbum(context);
        } else if (indice == 1) {
          _abrirAprender(context);
        } else if (indice == 0) {
          _abrirMapa(context);
        } else if (indice == 3) {
          _abrirScanner(context);
        } else {
          setState(() => _abaSelecionada = indice);
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
