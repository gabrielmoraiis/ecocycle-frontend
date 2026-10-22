import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/usuario.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/avatar_usuario.dart';
import '../introducao/tela_inicial.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  bool _atualizandoAvatar = false;
  bool _excluindo = false;

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

  Future<void> _confirmarExclusao() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text(
          'Tem certeza que deseja excluir sua conta? Essa ação não pode ser desfeita e você perderá o acesso ao seu progresso.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmou != true || !mounted) return;

    final sessionController = context.read<SessionController>();
    setState(() => _excluindo = true);
    try {
      await sessionController.excluirConta();
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
      if (mounted) setState(() => _excluindo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<SessionController>().usuario;

    return Scaffold(
      backgroundColor: AppColors.verdeClaroFundo,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Perfil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.verdeGradienteInicio,
                    ),
                  ),
                ],
              ),
            ),

            if (usuario == null)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.verdeGradienteInicio,
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- CARTÃO DO USUÁRIO ---
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.fundoBranco,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.bordaVerdeClara),
                        ),
                        child: Column(
                          children: [
                            _construirAvatarAtual(usuario.avatar),
                            const SizedBox(height: 16),
                            Text(
                              usuario.apelido,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textoEscuro,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              usuario.email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textoCinzaClaro,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'ESCOLHA UM AVATAR',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textoCinzaClaro,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: Avatar.selecionaveis.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                      const SizedBox(height: 32),

                      OutlinedButton.icon(
                        onPressed: _excluindo ? null : _confirmarExclusao,
                        icon: _excluindo
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                              )
                            : const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                        label: const Text(
                          'Excluir conta',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirAvatarAtual(Avatar avatar) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.bordaVerdeClara,
        shape: BoxShape.circle,
      ),
      child: AvatarUsuario(avatar: avatar, tamanho: 96),
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
}
