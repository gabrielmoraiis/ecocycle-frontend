import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../core/providers/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/formulario_eco.dart';
import '../../core/widgets/layout_eco.dart';
import '../home/tela_home.dart';
import '../login/tela_login.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  final _apelidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _senhaOculta = true;
  bool _aceitouTermos = false;
  bool _carregando = false;
  String? _erroGeral;

  static final _regexApelido = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  @override
  void dispose() {
    _apelidoController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    final formValido = _formKey.currentState?.validate() ?? false;
    if (!formValido || !_aceitouTermos) return;

    setState(() {
      _carregando = true;
      _erroGeral = null;
    });

    try {
      await context.read<SessionController>().registrar(
        email: _emailController.text.trim(),
        apelido: _apelidoController.text.trim(),
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
      if (e.isConflito) {
        mensagem = e.message;
      } else if (e.isValidacao && e.errors != null && e.errors!.isNotEmpty) {
        mensagem = e.errors!.join('\n');
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
    const estiloLink = TextStyle(
      fontWeight: FontWeight.bold,
      color: AppColors.verdeCabecalho,
    );

    return TelaFormularioEco(
      titulo: 'Crie sua conta',
      subtitulo: 'Comece a colecionar figurinhas e acompanhe seu progresso.',
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
              rotulo: 'APELIDO',
              dica: 'Como você quer ser chamado?',
              icone: Icons.person_outline,
              controller: _apelidoController,
              textInputAction: TextInputAction.next,
              ajuda: 'Usado para personalizar sua experiência no app.',
              validator: (valor) {
                final texto = valor?.trim() ?? '';
                if (texto.isEmpty) return 'Informe um apelido';
                if (!_regexApelido.hasMatch(texto)) {
                  return '3-20 caracteres: letras, números ou underscore';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            CampoEco(
              rotulo: 'E-MAIL',
              dica: 'seu@email.com',
              icone: Icons.mail_outline,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              ajuda: 'Para recuperar sua conta e sincronizar seu álbum.',
              validator: (valor) {
                final texto = valor?.trim() ?? '';
                if (texto.isEmpty) return 'Informe seu e-mail';
                if (!texto.contains('@') || !texto.contains('.')) {
                  return 'E-mail inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            CampoEco(
              rotulo: 'SENHA',
              dica: 'Mín. 6 caracteres',
              icone: Icons.lock_outline,
              controller: _senhaController,
              obscureText: _senhaOculta,
              textInputAction: TextInputAction.done,
              sufixo: BotaoVerSenha(
                oculta: _senhaOculta,
                onPressed: () => setState(() => _senhaOculta = !_senhaOculta),
              ),
              validator: (valor) {
                if (valor == null || valor.length < 6) {
                  return 'A senha precisa ter no mínimo 6 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _aceitouTermos = !_aceitouTermos),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _aceitouTermos,
                    activeColor: AppColors.verdeGradienteInicio,
                    onChanged: (novoValor) =>
                        setState(() => _aceitouTermos = novoValor ?? false),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: AppColors.textoEscuro,
                          ),
                          children: [
                            TextSpan(text: 'Aceito os '),
                            TextSpan(text: 'Termos de Uso', style: estiloLink),
                            TextSpan(text: ' e a '),
                            TextSpan(
                              text: 'Política de Privacidade',
                              style: estiloLink,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: (_aceitouTermos && !_carregando) ? _cadastrar : null,
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
                  : const Text('Criar conta'),
            ),
          ],
        ),
      ),
      depoisDoFormulario: [
        RodapeLinkEco(
          pergunta: 'Já tem conta?',
          acao: 'Entrar',
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TelaLogin()),
          ),
        ),
      ],
    );
  }
}
