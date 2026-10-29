import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/layout_eco.dart';
import '../cadastro/tela_cadastro.dart';
import '../login/tela_login.dart';

class TelaInicialEcoCycle extends StatelessWidget {
  const TelaInicialEcoCycle({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.verdeCabecalho,
        body: Stack(
          children: [
            // Círculos decorativos ao fundo.
            Positioned(left: -80, top: -60, child: _construirCirculo(260)),
            Positioned(right: -90, top: 300, child: _construirCirculo(220)),
            Column(
              children: [
                Expanded(
                  child: SafeArea(
                    bottom: false,
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(child: _construirApresentacao()),
                        ),
                      ),
                    ),
                  ),
                ),
                _construirPainelAcoes(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirCirculo(double tamanho) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: AppColors.fundoBranco.withValues(alpha: 0.06),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _construirApresentacao() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        Container(
          width: 132,
          height: 132,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.fundoBranco,
            borderRadius: BorderRadius.circular(36),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4D002800),
                blurRadius: 36,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Image.asset('assets/logo/simbolo.png'),
        ),
        const SizedBox(height: 18),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: AppColors.fundoBranco,
            ),
            children: [
              TextSpan(text: 'Eco'),
              TextSpan(
                text: 'Cycle',
                style: TextStyle(color: Color(0xFFA5D6A7)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Aprenda, descarte e colecione',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            height: 1.2,
            color: AppColors.fundoBranco,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Localize pontos de coleta, escaneie componentes e complete seu álbum de figurinhas eletrônicas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.45,
            color: AppColors.verdeSobreCabecalho,
          ),
        ),
        const SizedBox(height: 18),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _ChipRecurso(icone: Icons.location_on_outlined, texto: 'Mapa'),
            _ChipRecurso(
              icone: Icons.photo_camera_outlined,
              texto: 'Scanner IA',
            ),
            _ChipRecurso(icone: Icons.check_circle_outline, texto: 'Álbum'),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _construirPainelAcoes(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.fundoBranco,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        24,
        20,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TelaCadastro()),
            ),
            style: BotoesEco.principal(),
            child: const Text('Criar conta gratuita'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TelaLogin()),
            ),
            style: BotoesEco.secundario(),
            child: const Text('Já tenho conta'),
          ),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 14,
                color: AppColors.textoSecundario,
              ),
              SizedBox(width: 6),
              Text(
                'Sem spam · seus dados protegidos',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textoSecundario,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipRecurso extends StatelessWidget {
  final IconData icone;
  final String texto;

  const _ChipRecurso({required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.fundoBranco.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: AppColors.fundoBranco),
          const SizedBox(width: 6),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.fundoBranco,
            ),
          ),
        ],
      ),
    );
  }
}
