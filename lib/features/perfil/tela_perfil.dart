import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/models/usuario.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/figurinhas_provider.dart';
import '../../core/providers/progresso_provider.dart';
import '../../core/providers/session_controller.dart';
import '../../core/providers/trilhas_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/avatar_usuario.dart';
import '../introducao/tela_inicial.dart';

const Color _textoTitulo = Color(0xFF212121);
const Color _textoSecundario = Color(0xFF616161);
const Color _vermelho = Color(0xFFC62828);
const Color _vermelhoFundo = Color(0xFFFDECEA);

const List<String> _meses = [
  'jan.',
  'fev.',
  'mar.',
  'abr.',
  'mai.',
  'jun.',
  'jul.',
  'ago.',
  'set.',
  'out.',
  'nov.',
  'dez.',
];

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  bool _atualizandoAvatar = false;
  bool _encerrando = false;

  @override
  void initState() {
    super.initState();
    // Depois do primeiro frame: carregar() notifica os ouvintes na hora.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProgressoProvider>().carregar();
    });
  }

  Future<void> _selecionarAvatar(Avatar avatar) async {
    if (_atualizandoAvatar) return;
    setState(() => _atualizandoAvatar = true);
    try {
      await context.read<SessionController>().atualizarAvatar(avatar);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _atualizandoAvatar = false);
    }
  }

  Future<bool> _confirmar({
    required String titulo,
    required String mensagem,
    required String acao,
    required Color corAcao,
  }) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              acao,
              style: TextStyle(color: corAcao, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return confirmou == true;
  }

  Future<void> _confirmarSaida() async {
    final confirmou = await _confirmar(
      titulo: 'Sair da conta',
      mensagem:
          'Você vai precisar entrar de novo com seu e-mail e senha. Seu progresso continua salvo.',
      acao: 'Sair',
      corAcao: AppColors.verdeGradienteInicio,
    );
    if (!confirmou || !mounted) return;
    await _encerrarSessao(() => context.read<SessionController>().logout());
  }

  Future<void> _confirmarExclusao() async {
    final confirmou = await _confirmar(
      titulo: 'Excluir conta',
      mensagem:
          'Tem certeza que deseja excluir sua conta? Essa ação não pode ser desfeita e você perderá o acesso ao seu progresso.',
      acao: 'Excluir',
      corAcao: _vermelho,
    );
    if (!confirmou || !mounted) return;
    await _encerrarSessao(
      () => context.read<SessionController>().excluirConta(),
    );
  }

  /// Sair e excluir terminam igual: limpa o cache da conta (para a próxima
  /// pessoa que entrar não herdar progresso, figurinhas e trilhas) e volta
  /// para a tela inicial.
  Future<void> _encerrarSessao(Future<void> Function() acao) async {
    final figurinhas = context.read<FigurinhasProvider>();
    final progresso = context.read<ProgressoProvider>();
    final trilhas = context.read<TrilhasProvider>();
    setState(() => _encerrando = true);
    try {
      await acao();
      figurinhas.limpar();
      progresso.limpar();
      trilhas.limpar();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const TelaInicialEcoCycle()),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _encerrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<SessionController>().usuario;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.verdeClaroFundo,
        body: usuario == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.verdeGradienteInicio,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _construirCabecalho(usuario),
                    // O cartão de números sobe para dentro da faixa verde.
                    Transform.translate(
                      offset: const Offset(0, -36),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _construirNumeros(),
                            const SizedBox(height: 24),
                            _construirTituloSecao('SEU AVATAR'),
                            _construirCartao(_construirGradeAvatares(usuario)),
                            const SizedBox(height: 24),
                            _construirTituloSecao('CONTA'),
                            _construirCartao(_construirOpcoesConta()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES PARA NÃO REPETIR CÓDIGO ---

  Widget _construirCabecalho(Usuario usuario) {
    final DateTime criado = usuario.criadoEm.toLocal();
    return Container(
      color: AppColors.verdeGradienteInicio,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 60),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
                        color: AppColors.fundoBranco,
                        size: 28,
                      ),
                      tooltip: 'Voltar',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    'Perfil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.fundoBranco,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.fundoBranco,
                  shape: BoxShape.circle,
                ),
                child: AvatarUsuario(avatar: usuario.avatar, tamanho: 104),
              ),
              const SizedBox(height: 14),
              Text(
                usuario.apelido,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.fundoBranco,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                usuario.email,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFFE8F5E9)),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.fundoBranco.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.eco_outlined,
                      size: 14,
                      color: AppColors.fundoBranco,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Membro desde ${_meses[criado.month - 1]} ${criado.year}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.fundoBranco,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// XP, figurinhas e quizzes do usuário; "–" enquanto o progresso carrega.
  Widget _construirNumeros() {
    final progresso = context.watch<ProgressoProvider>().progresso;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.fundoBranco,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _construirNumero(
              icone: Icons.bolt,
              cor: const Color(0xFF9A4A00),
              corFundo: const Color(0xFFFFE0B2),
              valor: progresso == null ? '–' : '${progresso.xpTotal}',
              rotulo: 'XP',
            ),
            const VerticalDivider(width: 1, color: Color(0xFFEEEEEE)),
            _construirNumero(
              icone: Icons.style_outlined,
              cor: const Color(0xFF1B5E20),
              corFundo: AppColors.bordaVerdeClara,
              valor: progresso == null
                  ? '–'
                  : '${progresso.figurinhasDesbloqueadas}/${progresso.totalFigurinhas}',
              rotulo: 'figurinhas',
            ),
            const VerticalDivider(width: 1, color: Color(0xFFEEEEEE)),
            _construirNumero(
              icone: Icons.quiz_outlined,
              cor: const Color(0xFF0D47A1),
              corFundo: const Color(0xFFBBDEFB),
              valor: progresso == null ? '–' : '${progresso.quizzesConcluidos}',
              rotulo: 'quizzes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirNumero({
    required IconData icone,
    required Color cor,
    required Color corFundo,
    required String valor,
    required String rotulo,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: corFundo,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icone, size: 18, color: cor),
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _textoTitulo,
            ),
          ),
          Text(
            rotulo,
            style: const TextStyle(fontSize: 12, color: _textoSecundario),
          ),
        ],
      ),
    );
  }

  Widget _construirTituloSecao(String texto) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: _textoSecundario,
        ),
      ),
    );
  }

  Widget _construirCartao(Widget filho) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fundoBranco,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bordaVerdeClara),
      ),
      child: filho,
    );
  }

  Widget _construirGradeAvatares(Usuario usuario) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        // Sem isso o GridView herda o recuo da barra de status (a tela não
        // está dentro de um SafeArea) e abre um vão no topo do cartão.
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: Avatar.selecionaveis.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final avatar = Avatar.selecionaveis[index];
          return _construirOpcaoAvatar(
            avatar,
            selecionado: avatar == usuario.avatar,
          );
        },
      ),
    );
  }

  Widget _construirOpcaoAvatar(Avatar avatar, {required bool selecionado}) {
    return GestureDetector(
      onTap: () => _selecionarAvatar(avatar),
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selecionado
                    ? AppColors.verdeGradienteInicio
                    : AppColors.bordaVerdeClara,
              ),
              child: AvatarUsuario(
                avatar: avatar,
                tamanho: constraints.maxWidth - 6,
              ),
            ),
            if (selecionado)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.verdeGradienteInicio,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.fundoBranco, width: 2),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.fundoBranco,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirOpcoesConta() {
    return Column(
      children: [
        _construirOpcaoConta(
          icone: Icons.logout_rounded,
          cor: AppColors.textoEscuro,
          corFundo: AppColors.verdeClaroFundo,
          titulo: 'Sair da conta',
          subtitulo: 'Você pode entrar de novo quando quiser',
          onTap: _encerrando ? null : _confirmarSaida,
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        _construirOpcaoConta(
          icone: Icons.delete_outline,
          cor: _vermelho,
          corFundo: _vermelhoFundo,
          titulo: 'Excluir conta',
          subtitulo: 'Apaga sua conta e seu progresso',
          onTap: _encerrando ? null : _confirmarExclusao,
        ),
      ],
    );
  }

  Widget _construirOpcaoConta({
    required IconData icone,
    required Color cor,
    required Color corFundo,
    required String titulo,
    required String subtitulo,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: corFundo,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icone, color: cor, size: 22),
      ),
      title: Text(
        titulo,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: cor == _vermelho ? _vermelho : _textoTitulo,
        ),
      ),
      subtitle: Text(
        subtitulo,
        style: const TextStyle(fontSize: 13, color: _textoSecundario),
      ),
      trailing: _encerrando
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right, color: _textoSecundario),
    );
  }
}
