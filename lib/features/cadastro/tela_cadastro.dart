import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../core/providers/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/conteudo_adaptavel.dart';
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
    final tecladoAberto = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.fundoBranco,

      // --- APP BAR (Cabeçalho) ---
      appBar: AppBar(
        backgroundColor: AppColors.fundoBranco,
        elevation: 0,
        centerTitle: true,
        shape: const Border(
          bottom: BorderSide(color: AppColors.bordaCinza, width: 1.0),
        ),
        title: const Text(
          'Criar conta',
          style: TextStyle(
            color: AppColors.verdeGradienteInicio,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.verdeClaroFundo,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.verdeGradienteInicio,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),

      // --- CORPO DA TELA ---
      body: ConteudoAdaptavel(
        alignment: Alignment.topCenter,
        tecladoAberto: tecladoAberto,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_erroGeral != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECEA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF5C6CB)),
                    ),
                    child: Text(
                      _erroGeral!,
                      style: const TextStyle(
                        color: Color(0xFFB00020),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 1. CAMPO: APELIDO
                _construirLabel('APELIDO'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _apelidoController,
                  decoration: _estiloInput(
                    dica: 'Como você quer ser chamado?',
                    icone: Icons.person_outline,
                  ),
                  validator: (valor) {
                    final texto = valor?.trim() ?? '';
                    if (texto.isEmpty) return 'Informe um apelido';
                    if (!_regexApelido.hasMatch(texto)) {
                      return '3-20 caracteres: letras, números ou underscore';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 6),
                const Text(
                  'Usado para personalizar sua experiência no app.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textoCinzaClaro,
                  ),
                ),
                const SizedBox(height: 24),

                // 2. CAMPO: E-MAIL
                _construirLabel('E-MAIL'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _estiloInput(
                    dica: 'seu@email.com',
                    icone: Icons.mail_outline,
                  ),
                  validator: (valor) {
                    final texto = valor?.trim() ?? '';
                    if (texto.isEmpty) return 'Informe seu e-mail';
                    if (!texto.contains('@') || !texto.contains('.')) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 6),
                const Text(
                  'Para recuperar sua conta e sincronizar seu álbum.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textoCinzaClaro,
                  ),
                ),
                const SizedBox(height: 24),

                // 3. CAMPO: SENHA
                _construirLabel('SENHA'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _senhaController,
                  obscureText: _senhaOculta,
                  decoration:
                      _estiloInput(
                        dica: 'Mín. 6 caracteres',
                        icone: Icons.lock_outline,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _senhaOculta
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textoCinzaClaro,
                          ),
                          onPressed: () {
                            setState(() {
                              _senhaOculta = !_senhaOculta;
                            });
                          },
                        ),
                      ),
                  validator: (valor) {
                    if (valor == null || valor.length < 6) {
                      return 'A senha precisa ter no mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // --- CHECKBOX TERMOS DE USO ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _aceitouTermos,
                        activeColor: AppColors.verdeGradienteInicio,
                        onChanged: (novoValor) {
                          setState(() {
                            _aceitouTermos = novoValor ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textoEscuro,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(text: 'Aceito os '),
                            TextSpan(
                              text: 'Termos de Uso',
                              style: TextStyle(
                                color: AppColors.verdeGradienteInicio,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: ' e a '),
                            TextSpan(
                              text: 'Política de Privacidade',
                              style: TextStyle(
                                color: AppColors.verdeGradienteInicio,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '. Meus dados são usados apenas para salvar meu progresso.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // --- BOTÃO CRIAR CONTA ---
                ElevatedButton(
                  onPressed: (_aceitouTermos && !_carregando)
                      ? _cadastrar
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdeGradienteInicio,
                    foregroundColor: AppColors.textoBranco,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: _carregando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.textoBranco,
                          ),
                        )
                      : const Text(
                          'Criar conta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // --- DIVISOR "OU" ---
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: AppColors.bordaVerdeClara),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'ou',
                        style: TextStyle(
                          color: AppColors.textoCinzaClaro,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: AppColors.bordaVerdeClara),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- BOTÃO GOOGLE ---
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: const BorderSide(color: AppColors.bordaVerdeClara),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/svg/material-icon-theme_google.svg',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Continuar com Google',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textoEscuro,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // --- RODAPÉ LOGIN ---
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TelaLogin(),
                        ),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: AppColors.textoEscuro,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(text: 'Já tem conta? '),
                          TextSpan(
                            text: 'Entrar',
                            style: TextStyle(
                              color: AppColors.verdeGradienteInicio,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES PARA NÃO REPETIR CÓDIGO ---

  Widget _construirLabel(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textoEscuro,
        letterSpacing: 1.2,
      ),
    );
  }

  InputDecoration _estiloInput({
    required String dica,
    required IconData icone,
  }) {
    return InputDecoration(
      hintText: dica,
      hintStyle: const TextStyle(color: AppColors.textoCinzaClaro),
      prefixIcon: Icon(icone, color: AppColors.verdeGradienteInicio),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.bordaVerdeClara),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.verdeGradienteInicio,
          width: 2,
        ),
      ),
    );
  }
}
