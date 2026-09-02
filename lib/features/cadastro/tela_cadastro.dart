import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/theme/app_colors.dart';
import '../login/tela_login.dart';

// Se for usar o ícone do Google como SVG, lembre-se do import:
// import 'package:flutter_svg/flutter_svg.dart';

// 1. Mudamos para StatefulWidget para controlar o checkbox e a senha
class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  // Variáveis de Estado (Memória da tela)
  bool _senhaOculta = true;
  bool _aceitouTermos = false;

  @override
  Widget build(BuildContext context) {
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
            color: AppColors.verdeGradienteInicio, // Ou um verde escuro
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CAMPO: NOME
            _construirLabel('NOME'),
            const SizedBox(height: 8),
            TextFormField(
              decoration: _estiloInput(
                dica: 'Como você quer ser chamado?',
                icone: Icons.person_outline,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Usado para personalizar sua experiência no app.',
              style: TextStyle(fontSize: 12, color: AppColors.textoCinzaClaro),
            ),
            const SizedBox(height: 24),

            // 2. CAMPO: E-MAIL
            _construirLabel('E-MAIL'),
            const SizedBox(height: 8),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: _estiloInput(
                dica: 'seu@email.com',
                icone: Icons.mail_outline,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Para recuperar sua conta e sincronizar seu álbum.',
              style: TextStyle(fontSize: 12, color: AppColors.textoCinzaClaro),
            ),
            const SizedBox(height: 24),

            // 3. CAMPO: SENHA
            _construirLabel('SENHA'),
            const SizedBox(height: 8),
            TextFormField(
              obscureText: _senhaOculta, // Esconde ou mostra a senha
              decoration:
                  _estiloInput(
                    dica: 'Mín. 8 caracteres',
                    icone: Icons.lock_outline,
                  ).copyWith(
                    // O sufixo é o ícone clicável do lado direito
                    suffixIcon: IconButton(
                      icon: Icon(
                        _senhaOculta
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textoCinzaClaro,
                      ),
                      onPressed: () {
                        // setState avisa o Flutter para redesenhar a tela com o novo valor
                        setState(() {
                          _senhaOculta = !_senhaOculta;
                        });
                      },
                    ),
                  ),
            ),
            const SizedBox(height: 12),

            // Indicador de força da senha (Barrinhas)
            Row(
              children: [
                Expanded(child: _barraSenha(AppColors.bordaVerdeClara)),
                const SizedBox(width: 8),
                Expanded(child: _barraSenha(AppColors.bordaVerdeClara)),
                const SizedBox(width: 8),
                Expanded(child: _barraSenha(AppColors.bordaVerdeClara)),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Digite sua senha',
              style: TextStyle(fontSize: 12, color: AppColors.textoCinzaClaro),
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
                        // O operador nulo garante que sempre será false se vier null
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

            // --- BOTÃO ENTRAR ---
            ElevatedButton(
              onPressed: _aceitouTermos ? () {} : null,
              // Desabilita se não aceitar termos
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verdeGradienteInicio,
                foregroundColor: AppColors.textoBranco,
                minimumSize: const Size(double.infinity, 56),
                // Largura total, altura 56
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Entrar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  // Substitua pelo seu SvgPicture se tiver o logo exato
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
                    MaterialPageRoute(builder: (context) => const TelaLogin()),
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

  Widget _barraSenha(Color cor) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
