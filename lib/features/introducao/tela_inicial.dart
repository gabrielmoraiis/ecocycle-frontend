import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/conteudo_adaptavel.dart';
import '../cadastro/tela_cadastro.dart';
import '../login/tela_login.dart';

class TelaInicialEcoCycle extends StatelessWidget {
  const TelaInicialEcoCycle({super.key});

  @override
  Widget build(BuildContext context) {
    final tecladoAberto = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppColors.verdeGradienteInicio,
              AppColors.verdeGradienteFim,
            ],
          ),
        ),

        child: Stack(
          children: [
            Positioned(
              top: 70,
              left: 0,
              child: SvgPicture.asset(
                'assets/svg/Ellipse 7.svg',
                width: 156,
                height: 156,
              ),
            ),
            ConteudoAdaptavel(
              tecladoAberto: tecladoAberto,
              builder: (context) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 64.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: AppColors.textoBranco,
                        ),
                        children: [
                          TextSpan(text: "Eco"),
                          TextSpan(
                            text: "Cycle",
                            style: TextStyle(
                              color: AppColors.destaqueVerdeClaro,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Descarte consciente',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppColors.branco70),
                    ),

                    const SizedBox(height: 64),

                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.branco20,
                          border: Border.all(
                            color: AppColors.branco50,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.refresh_rounded,
                            size: 60,
                            color: AppColors.textoBranco,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 64),

                    const Text(
                      'Aprenda, descarte e colecione',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textoBranco,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Localize pontos de coleta, escaneie componentes e complete seu álbum de figurinhas eletrônicas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textoCinzaClaro,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 80),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TelaCadastro(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textoBranco,
                        foregroundColor: AppColors.destaqueVerdeClaro,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Criar conta gratuita',
                        style: TextStyle(color: AppColors.verdeEscuroTexto),
                      ),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TelaLogin(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.destaqueVerdeClaro,
                        foregroundColor: AppColors.textoBranco,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        side: const BorderSide(
                          color: AppColors.textoBranco,
                          width: 1.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Já tenho conta'),
                    ),

                    const SizedBox(height: 48),

                    const Text(
                      'Sem spam - Seus dados protegidos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textoCinzaClaro,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: SvgPicture.asset(
                'assets/svg/Ellipse 8.svg',
                width: 180,
                height: 180,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
