import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../aprender/tela_aprender.dart';
import '../mapa/tela_mapa.dart';
import '../scanner/tela_scanner.dart';
import 'tela_info_figurinha.dart';

class ComponenteAlbum {
  final String titulo;
  final String subtitulo;
  final IconData icone;
  final String raridade;
  final Color corFundo;
  final Color corIcone;
  final Color corBadgeFundo;
  final Color corBadgeTexto;
  final String substanciasPresentes;
  final String riscoAmbiental;
  final String descarteCorreto;
  final String comoDesbloquear;

  const ComponenteAlbum({
    required this.titulo,
    required this.subtitulo,
    required this.icone,
    required this.raridade,
    required this.corFundo,
    required this.corIcone,
    required this.corBadgeFundo,
    required this.corBadgeTexto,
    required this.substanciasPresentes,
    required this.riscoAmbiental,
    required this.descarteCorreto,
    required this.comoDesbloquear,
  });
}

const List<ComponenteAlbum> _componentesIniciais = [
  ComponenteAlbum(
    titulo: 'Placa-mãe',
    subtitulo: 'Chumbo e Ouro',
    icone: Icons.memory,
    raridade: 'ÉPICO',
    corFundo: Color(0xFFE1F0E2),
    corIcone: AppColors.verdeGradienteInicio,
    corBadgeFundo: Color(0xFFC8E6C9),
    corBadgeTexto: AppColors.verdeEscuroTexto,
    substanciasPresentes:
        'Chumbo, Ouro, Paládio - metais preciosos e tóxicos presentes nos circuitos.',
    riscoAmbiental:
        'Contamina solo e água. O chumbo é neurotóxico e persiste no ambiente por décadas.',
    descarteCorreto:
        'Leve a um ponto de coleta de eletrônicos ou cooperativa de reciclagem especializada.',
    comoDesbloquear: 'Desbloqueado ao escanear um computador com o Scanner IA',
  ),
  ComponenteAlbum(
    titulo: 'Tela LCD',
    subtitulo: 'Mercúrio',
    icone: Icons.desktop_windows_outlined,
    raridade: 'COMUM',
    corFundo: Color(0xFFDDEBFB),
    corIcone: Colors.blue,
    corBadgeFundo: Color(0xFFBBDEFB),
    corBadgeTexto: Colors.blue,
    substanciasPresentes:
        'Mercúrio, Cristal líquido - substâncias tóxicas presentes na retroiluminação e no painel.',
    riscoAmbiental:
        'O mercúrio é altamente tóxico ao sistema nervoso e contamina lençóis freáticos.',
    descarteCorreto:
        'Entregue em pontos de coleta específicos para eletrônicos. Nunca quebre a tela.',
    comoDesbloquear: 'Desbloqueado ao escanear uma TV ou monitor com o Scanner IA',
  ),
  ComponenteAlbum(
    titulo: 'Bateria de Lítio',
    subtitulo: 'Lítio e Cobalto',
    icone: Icons.battery_full_outlined,
    raridade: 'RARO',
    corFundo: Color(0xFFFBEFD2),
    corIcone: Colors.orange,
    corBadgeFundo: Color(0xFFFFE0B2),
    corBadgeTexto: Colors.orange,
    substanciasPresentes:
        'Lítio, Cobalto, Manganês - metais tóxicos ao meio ambiente se descartados incorretamente.',
    riscoAmbiental:
        'Contamina solo e lençol freático. Pode causar incêndios em aterros sanitários.',
    descarteCorreto:
        'Leve ao ponto de coleta mais próximo ou a uma loja de eletrônicos parceira. Nunca no lixo comum.',
    comoDesbloquear: 'Desbloqueado ao escanear um celular com o Scanner IA',
  ),
  ComponenteAlbum(
    titulo: 'Cabo USB',
    subtitulo: 'Cobre e PVC',
    icone: Icons.cable,
    raridade: 'COMUM',
    corFundo: Color(0xFFFAD9E1),
    corIcone: Colors.pink,
    corBadgeFundo: Color(0xFFF8BBD0),
    corBadgeTexto: Colors.pink,
    substanciasPresentes:
        'Cobre, PVC - metal reciclável envolto em plástico não biodegradável.',
    riscoAmbiental:
        'O PVC libera dioxinas tóxicas quando queimado incorretamente.',
    descarteCorreto:
        'Separe o cobre do plástico em cooperativas de reciclagem, se possível.',
    comoDesbloquear: 'Desbloqueado ao escanear um cabo com o Scanner IA',
  ),
  ComponenteAlbum(
    titulo: 'Smartphone',
    subtitulo: 'Cobre e PVC',
    icone: Icons.smartphone_outlined,
    raridade: 'RARO',
    corFundo: Color(0xFFEBDFF3),
    corIcone: Colors.purple,
    corBadgeFundo: Color(0xFFE1BEE7),
    corBadgeTexto: Colors.purple,
    substanciasPresentes:
        'Cobre, PVC, terras raras - materiais valiosos misturados em plásticos difíceis de separar.',
    riscoAmbiental:
        'O descarte incorreto libera metais pesados e desperdiça materiais recicláveis escassos.',
    descarteCorreto:
        'Leve a um ponto de coleta de eletrônicos ou devolva ao fabricante em programas de logística reversa.',
    comoDesbloquear: 'Desbloqueado ao escanear um smartphone com o Scanner IA',
  ),
];

// --- COMPONENTES QUE O SCANNER IA AINDA PODE DESCOBRIR ---
const List<ComponenteAlbum> componentesEscaneaveis = [
  ComponenteAlbum(
    titulo: 'Fonte de Alimentação',
    subtitulo: 'Capacitores',
    icone: Icons.electrical_services_outlined,
    raridade: 'RARO',
    corFundo: Color(0xFFFFE9E6),
    corIcone: Colors.deepOrange,
    corBadgeFundo: Color(0xFFFFCCBC),
    corBadgeTexto: Colors.deepOrange,
    substanciasPresentes:
        'Capacitores eletrolíticos, chumbo em soldas - podem reter carga elétrica mesmo desligados.',
    riscoAmbiental:
        'Capacitores podem vazar eletrólitos tóxicos e representam risco de choque se manuseados sem cuidado.',
    descarteCorreto:
        'Nunca abra ou perfure. Leve a um ponto de coleta de eletrônicos.',
    comoDesbloquear: 'Desbloqueado ao escanear uma fonte de alimentação com o Scanner IA',
  ),
  ComponenteAlbum(
    titulo: 'Alto-falante',
    subtitulo: 'Ímã de Neodímio',
    icone: Icons.speaker_outlined,
    raridade: 'ÉPICO',
    corFundo: Color(0xFFE8EAF6),
    corIcone: Colors.indigo,
    corBadgeFundo: Color(0xFFC5CAE9),
    corBadgeTexto: Colors.indigo,
    substanciasPresentes:
        'Ímãs de neodímio, cobre - terras raras valiosas usadas na bobina e no ímã.',
    riscoAmbiental:
        'A extração de terras raras é altamente poluente; reciclar evita mais mineração.',
    descarteCorreto:
        'Entregue em pontos de coleta de eletrônicos para recuperação dos metais.',
    comoDesbloquear: 'Desbloqueado ao escanear uma caixa de som com o Scanner IA',
  ),
];

const int _totalCards = 12;

// --- ESTADO EM MEMÓRIA DOS COMPONENTES JÁ DESBLOQUEADOS ---
class AlbumRepositorio {
  AlbumRepositorio._();

  static final List<ComponenteAlbum> _desbloqueados = List.of(_componentesIniciais);

  static List<ComponenteAlbum> get desbloqueados => List.unmodifiable(_desbloqueados);

  static int get totalCards => _totalCards;

  static int get bloqueadosCount => _totalCards - _desbloqueados.length;

  static bool foiDesbloqueado(ComponenteAlbum componente) =>
      _desbloqueados.any((c) => c.titulo == componente.titulo);

  static ComponenteAlbum? proximoParaDesbloquear() {
    for (final componente in componentesEscaneaveis) {
      if (!foiDesbloqueado(componente)) return componente;
    }
    return null;
  }

  static void desbloquear(ComponenteAlbum componente) {
    if (!foiDesbloqueado(componente)) {
      _desbloqueados.add(componente);
    }
  }
}

class TelaAlbum extends StatefulWidget {
  const TelaAlbum({super.key});

  @override
  State<TelaAlbum> createState() => _TelaAlbumState();
}

class _TelaAlbumState extends State<TelaAlbum> {
  int _abaSelecionada = 4; // Álbum selecionado por padrão

  @override
  Widget build(BuildContext context) {
    final List<ComponenteAlbum> desbloqueados = AlbumRepositorio.desbloqueados;
    final int bloqueadosCount = AlbumRepositorio.bloqueadosCount;
    final double progresso = desbloqueados.length / AlbumRepositorio.totalCards;

    return Scaffold(
      backgroundColor: AppColors.verdeClaroFundo,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TOPO: LOGO + CONTADOR ---
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.verdeClaroFundo,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.bordaVerdeClara),
                      ),
                      child: Text(
                        '${desbloqueados.length}/${AlbumRepositorio.totalCards} cards',
                        style: const TextStyle(
                          color: AppColors.verdeEscuroTexto,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
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
                      'Álbum de Componentes',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textoBranco,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Escaneie aparelhos e leia conteúdos para desbloquear',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.branco70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progresso,
                        minHeight: 10,
                        backgroundColor: AppColors.branco20,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.destaqueVerdeClaro),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${desbloqueados.length} desbloqueados',
                          style: const TextStyle(color: AppColors.branco70, fontSize: 13),
                        ),
                        Text(
                          '${(progresso * 100).round()}%',
                          style: const TextStyle(
                            color: AppColors.textoBranco,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- SEÇÃO DESBLOQUEADOS ---
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _construirTituloSecao('DESBLOQUEADOS'),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: desbloqueados.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, index) {
                        return _construirCartaoDesbloqueado(desbloqueados[index]);
                      },
                    ),
                    const SizedBox(height: 24),

                    // --- SEÇÃO BLOQUEADOS ---
                    _construirTituloSecao('BLOQUEADOS ($bloqueadosCount)'),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bloqueadosCount,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, index) => _construirCartaoBloqueado(),
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

  void _abrirInfoFigurinha(ComponenteAlbum componente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaInfoFigurinha(componente: componente),
      ),
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

  Widget _construirCartaoDesbloqueado(ComponenteAlbum componente) {
    return GestureDetector(
      onTap: () => _abrirInfoFigurinha(componente),
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.fundoBranco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bordaVerdeClara),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: componente.corFundo,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: componente.corBadgeFundo,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        componente.raridade,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: componente.corBadgeTexto,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(componente.icone, color: componente.corIcone, size: 36),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  componente.titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textoEscuro,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  componente.subtitulo,
                  style: const TextStyle(fontSize: 12, color: AppColors.textoCinzaClaro),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _construirCartaoBloqueado() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '???',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 8),
          const Icon(Icons.lock_outline, color: Color(0xFF9E9E9E), size: 32),
          const SizedBox(height: 8),
          const Text(
            'Use o scanner',
            style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }

  Widget _construirItemNavegacao(int indice, IconData icone, String rotulo) {
    final bool selecionado = _abaSelecionada == indice;
    final Color cor = selecionado ? AppColors.verdeGradienteInicio : AppColors.textoCinzaClaro;

    return GestureDetector(
      onTap: () {
        if (indice == _abaSelecionada) return;
        if (indice == 2) {
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (indice == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TelaAprender()),
          );
        } else if (indice == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TelaMapa()),
          );
        } else if (indice == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TelaScanner()),
          );
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
