import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/usuario.dart';
import '../../core/network/api_exception.dart';
import '../../core/providers/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../introducao/tela_inicial.dart';

const List<Color> _coresAvatar = [
  AppColors.verdeGradienteInicio,
  Colors.blue,
  Colors.orange,
  Colors.purple,
  Colors.pink,
  Colors.teal,
  Colors.indigo,
  Colors.brown,
  Colors.deepOrange,
  Colors.cyan,
];

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
                        itemCount: Avatar.values.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                            ),
                        itemBuilder: (context, index) {
                          final avatar = Avatar.values[index];
                          final selecionado = avatar == usuario.avatar;
                          return GestureDetector(
                            onTap: () => _selecionarAvatar(avatar),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _coresAvatar[index],
                                shape: BoxShape.circle,
                                border: selecionado
                                    ? Border.all(
                                        color: AppColors.textoEscuro,
                                        width: 3,
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: selecionado
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      )
                                    : Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
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
    final index = Avatar.values.indexOf(avatar);
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: _coresAvatar[index],
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 44),
    );
  }
}
