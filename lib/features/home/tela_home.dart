import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/ilustracao_conteudo_catalog.dart';
import '../../core/models/usuario.dart';
import '../../core/providers/progresso_provider.dart';
import '../../core/providers/session_controller.dart';
import '../../core/providers/trilhas_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/avatar_usuario.dart';
import '../../core/widgets/eco_bottom_nav_bar.dart';
import '../../core/widgets/layout_eco.dart';
import '../album/tela_album.dart';
import '../aprender/tela_aprender.dart';
import '../aprender/tela_modulo.dart';
import '../mapa/tela_mapa.dart';
import '../perfil/tela_perfil.dart';
import '../scanner/tela_scanner.dart';

/// Próximo módulo a estudar: o primeiro, na ordem das trilhas, com o quiz
/// ainda não concluído.
class _ProximoModulo {
  final TrilhaAprendizado trilha;
  final ModuloTrilha modulo;
  final int indice;

  const _ProximoModulo(this.trilha, this.modulo, this.indice);
}

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressoProvider>().carregar();
      context.read<TrilhasProvider>().carregar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<SessionController>().usuario;
    final progresso = context.watch<ProgressoProvider>().progresso;
    final trilhas = context
        .watch<TrilhasProvider>()
        .trilhas
        .map(TrilhaAprendizado.fromApi)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.verdeClaroFundo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- TOPO: AVATAR + SAUDAÇÃO + XP ---
              Row(
                children: [
                  _construirBotaoPerfil(usuario?.avatar),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bem-vindo de volta',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textoSecundario,
                          ),
                        ),
                        Text(
                          usuario == null ? 'Olá!' : 'Olá, ${usuario.apelido}!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textoTitulo,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (progresso != null) _construirXp(progresso.xpTotal),
                ],
              ),
              const SizedBox(height: 20),

              _construirCartaoScanner(),
              const SizedBox(height: 20),

              TituloSecaoEco(
                'CONTINUE APRENDENDO',
                acao: GestureDetector(
                  onTap: () => _abrir(const TelaAprender()),
                  child: const Text(
                    'Ver trilhas',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.verdeCabecalho,
                    ),
                  ),
                ),
              ),
              _construirContinuarAprendendo(trilhas),
              const SizedBox(height: 20),

              // --- ÁLBUM + PONTOS DE COLETA ---
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _construirCartaoAlbum(
                        progresso?.figurinhasDesbloqueadas ?? 0,
                        progresso?.totalFigurinhas ?? 10,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _construirCartaoMapa()),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _construirVoceSabia(),
            ],
          ),
        ),
      ),

      // --- BARRA DE NAVEGAÇÃO INFERIOR ---
      bottomNavigationBar: const EcoBottomNavBar(tabAtual: EcoTab.inicio),
    );
  }

  // --- MÉTODOS AUXILIARES PARA NÃO REPETIR CÓDIGO ---

  Future<void> _abrir(Widget tela) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => tela),
    );
  }

  Widget _construirBotaoPerfil(Avatar? avatar) {
    return Semantics(
      button: true,
      label: 'Abrir perfil',
      child: GestureDetector(
        onTap: () => _abrir(const TelaPerfil()),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: AppColors.bordaVerdeClara,
            shape: BoxShape.circle,
          ),
          child: avatar == null
              ? const SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.verdeGradienteInicio,
                  ),
                )
              : AvatarUsuario(avatar: avatar, tamanho: 46),
        ),
      ),
    );
  }

  Widget _construirXp(int xp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.laranjaFundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, size: 16, color: AppColors.laranjaIcone),
          const SizedBox(width: 4),
          Text(
            '$xp XP',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.laranjaTexto,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCartaoScanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.verdeCabecalho,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const IconeQuadradoEco(
                icone: Icons.center_focus_strong_outlined,
                cor: AppColors.fundoBranco,
                corFundo: Color(0x29FFFFFF),
                tamanho: 64,
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SCANNER IA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: AppColors.bordaVerdeClara,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'O que vamos descartar?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.fundoBranco,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Aponte a câmera para um aparelho e descubra como descartá-lo',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: AppColors.verdeSobreCabecalho,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _abrir(const TelaScanner()),
            icon: const Icon(Icons.photo_camera_outlined, size: 20),
            label: const Text('Escanear aparelho'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.fundoBranco,
              foregroundColor: AppColors.verdeEscuro,
              minimumSize: const Size.fromHeight(50),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _ProximoModulo? _proximoModulo(List<TrilhaAprendizado> trilhas) {
    for (final trilha in trilhas) {
      for (int i = 0; i < trilha.modulos.length; i++) {
        if (!trilha.modulos[i].concluido) {
          return _ProximoModulo(trilha, trilha.modulos[i], i);
        }
      }
    }
    return null;
  }

  Future<void> _abrirModulo(_ProximoModulo proximo) async {
    await _abrir(
      TelaModulo(
        rotuloTrilha: proximo.trilha.tituloSecao.split(' - ').first,
        tituloModulo: proximo.modulo.nome,
        numeroModulo: proximo.indice + 1,
        totalModulos: proximo.trilha.modulos.length,
        conteudoId: proximo.modulo.conteudoId,
      ),
    );
    if (!mounted) return;
    context.read<TrilhasProvider>().recarregar();
  }

  Widget _construirContinuarAprendendo(List<TrilhaAprendizado> trilhas) {
    // Trilhas ainda carregando (ou com erro): atalho simples para Aprender.
    if (trilhas.isEmpty) {
      return CartaoEco(
        onTap: () => _abrir(const TelaAprender()),
        child: const Row(
          children: [
            IconeQuadradoEco(
              icone: Icons.menu_book_outlined,
              cor: AppColors.verdeGradienteInicio,
              corFundo: AppColors.verdeClaroFundo,
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'Aprenda sobre descarte correto e ganhe figurinhas',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoTitulo,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textoSecundario),
          ],
        ),
      );
    }

    final int total = trilhas.fold(0, (s, t) => s + t.modulos.length);
    final int concluidos = trilhas.fold(
      0,
      (s, t) => s + t.modulos.where((m) => m.concluido).length,
    );
    final _ProximoModulo? proximo = _proximoModulo(trilhas);

    if (proximo == null) {
      return CartaoEco(
        onTap: () => _abrir(const TelaAprender()),
        child: const Row(
          children: [
            IconeQuadradoEco(
              icone: Icons.emoji_events_outlined,
              cor: AppColors.laranjaIcone,
              corFundo: AppColors.laranjaIconeFundo,
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trilhas concluídas!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textoTitulo,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Revise os módulos quando quiser',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textoSecundario,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textoSecundario),
          ],
        ),
      );
    }

    final String? ilustracao = ilustracaoPorTitulo(proximo.modulo.nome);
    final String rotuloTrilha = proximo.trilha.tituloSecao
        .replaceAll(' - ', ' · ')
        .toUpperCase();

    return CartaoEco(
      padding: EdgeInsets.zero,
      onTap: () => _abrirModulo(proximo),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ilustracao != null)
            Image.asset(
              'assets/conteudos/$ilustracao',
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '$rotuloTrilha · MÓDULO ${proximo.indice + 1} DE '
                  '${proximo.trilha.modulos.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: AppColors.verdeCabecalho,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        proximo.modulo.nome,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textoTitulo,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _abrirModulo(proximo),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.verdeGradienteInicio,
                        foregroundColor: AppColors.fundoBranco,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Continuar',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                BarraProgressoEco(valor: total == 0 ? 0 : concluidos / total),
                const SizedBox(height: 6),
                Text(
                  '$concluidos de $total módulos concluídos',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCartaoAlbum(int desbloqueadas, int total) {
    return CartaoEco(
      onTap: () => _abrir(const TelaAlbum()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _construirMiniFigurinha(
                const Color(0xFFE1F0E2),
                const Color(0xFFA5D6A7),
                -0.1,
              ),
              const SizedBox(width: 4),
              _construirMiniFigurinha(
                const Color(0xFFFFF3E0),
                const Color(0xFFFFCC80),
                0,
              ),
              const SizedBox(width: 4),
              _construirMiniFigurinha(
                const Color(0xFFEEEEEE),
                const Color(0xFFBDBDBD),
                0.1,
                bloqueada: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Álbum',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textoTitulo,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$desbloqueadas de $total figurinhas',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textoSecundario,
            ),
          ),
          const Spacer(),
          const SizedBox(height: 10),
          BarraProgressoEco(
            valor: total == 0 ? 0 : desbloqueadas / total,
            altura: 6,
          ),
        ],
      ),
    );
  }

  Widget _construirMiniFigurinha(
    Color fundo,
    Color borda,
    double angulo, {
    bool bloqueada = false,
  }) {
    return Transform.rotate(
      angle: angulo,
      child: Container(
        width: 30,
        height: 38,
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borda, width: 1.5),
        ),
        child: bloqueada
            ? const Icon(
                Icons.lock_outline,
                size: 14,
                color: AppColors.textoCinzaClaro,
              )
            : null,
      ),
    );
  }

  Widget _construirCartaoMapa() {
    return CartaoEco(
      onTap: () => _abrir(const TelaMapa()),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconeQuadradoEco(
            icone: Icons.location_on_outlined,
            cor: AppColors.azulIcone,
            corFundo: AppColors.azulFundo,
          ),
          SizedBox(height: 10),
          Text(
            'Pontos de coleta',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textoTitulo,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Encontre o mais perto de você',
            style: TextStyle(
              fontSize: 13,
              height: 1.3,
              color: AppColors.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirVoceSabia() {
    return const CartaoEco(
      cor: AppColors.laranjaFundo,
      corBorda: Color(0xFFFFD8A8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconeQuadradoEco(
            icone: Icons.lightbulb_outline,
            cor: AppColors.laranjaIcone,
            corFundo: AppColors.laranjaIconeFundo,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VOCÊ SABIA?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: AppColors.laranjaTexto,
                  ),
                ),
                SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF5D3A12),
                    ),
                    children: [
                      TextSpan(text: 'Só '),
                      TextSpan(
                        text: '3%',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            ' do lixo eletrônico é reciclado no Brasil, que descarta ',
                      ),
                      TextSpan(
                        text: '2,4 milhões de toneladas',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' por ano.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
