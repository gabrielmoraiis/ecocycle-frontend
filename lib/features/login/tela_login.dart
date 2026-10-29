import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../core/providers/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/formulario_eco.dart';
import '../../core/widgets/layout_eco.dart';
import '../cadastro/tela_cadastro.dart';
import '../home/tela_home.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _senhaOculta = true;
  bool _carregando = false;
  String? _erroGeral;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final formValido = _formKey.currentState?.validate() ?? false;
    if (!formValido) return;

    setState(() {
      _carregando = true;
      _erroGeral = null;
    });

    try {
      await context.read<SessionController>().login(
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const TelaHome()),
        (route) => false,
      );
    } on ApiException catch (e) {
      String mensagem;
      if (e.isRateLimit) {
        mensagem =
            'Muitas tentativas de login. Tente novamente em alguns minutos.';
      } else if (e.isNaoAutorizado) {
        mensagem = 'E-mail ou senha inválidos.';
      } else {
        mensagem = e.message;
      }
      setState(() => _erroGeral = mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TelaFormularioEco(
      titulo: 'Bem-vindo de volta',
      subtitulo: 'Entre para continuar seu progresso e ver seu álbum.',
      mostrarLogo: true,
      formulario: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_erroGeral != null) ...[
              AvisoErroEco(_erroGeral!),
              const SizedBox(height: 16),
            ],
            CampoEco(
              rotulo: 'E-MAIL',
              dica: 'seu@email.com',
              icone: Icons.mail_outline,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Informe seu e-mail';
                }
                if (!valor.contains('@') || !valor.contains('.')) {
                  return 'E-mail inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CampoEco(
              rotulo: 'SENHA',
              dica: 'Sua senha',
              icone: Icons.lock_outline,
              controller: _senhaController,
              obscureText: _senhaOculta,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _carregando ? null : _entrar(),
              sufixo: BotaoVerSenha(
                oculta: _senhaOculta,
                onPressed: () => setState(() => _senhaOculta = !_senhaOculta),
              ),
              validator: (valor) {
                if (valor == null || valor.isEmpty) {
                  return 'Informe sua senha';
                }
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                // A recuperação de senha ainda não existe no backend.
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'A recuperação de senha ainda não está disponível.',
                    ),
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.verdeCabecalho,
                ),
                child: const Text(
                  'Esqueci minha senha',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _carregando ? null : _entrar,
              style: BotoesEco.principal(),
              child: _carregando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.fundoBranco,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Entrar'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
            ),
          ],
        ),
      ),
      depoisDoFormulario: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.verdeSobreCabecalho,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.cloud_done_outlined,
                size: 20,
                color: AppColors.verdeCabecalho,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Suas figurinhas, progresso e módulos concluídos ficam salvos na sua conta em qualquer dispositivo.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF2E5E30),
                  ),
                ),
              ),
            ],
          ),
        ),
        RodapeLinkEco(
          pergunta: 'Não tem conta?',
          acao: 'Cadastre-se',
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TelaCadastro()),
          ),
        ),
      ],
    );
  }
}
