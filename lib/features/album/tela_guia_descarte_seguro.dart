import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/layout_eco.dart';
import '../mapa/tela_mapa.dart';

const Color _ardosia = Color(0xFF263238);

class _Passo {
  final String titulo;
  final String texto;
  final bool alerta;
  final List<(String, String)> detalhes;

  const _Passo({
    required this.titulo,
    required this.texto,
    this.alerta = false,
    this.detalhes = const [],
  });
}

// Passos para apagar um disco (HD/SSD) antes do descarte. Valem para o HD
// solto e para o notebook, que tem um disco dentro.
const List<_Passo> _passos = [
  _Passo(
    titulo: 'Faça backup',
    texto: 'Copie fotos e documentos para outro disco ou para a nuvem.',
  ),
  _Passo(
    titulo: 'Saia das suas contas',
    texto: 'Desconecte e-mail, nuvem e navegadores do computador.',
  ),
  _Passo(
    titulo: 'Apague com limpeza segura',
    texto:
        'Formatar ou esvaziar a lixeira não basta. Use uma limpeza que sobrescreve os dados.',
    detalhes: [
      (
        'NO WINDOWS',
        'Configurações › Recuperação › Redefinir este PC › Remover tudo › Limpar a unidade',
      ),
      ('É UM SSD?', 'Use a ferramenta do fabricante (opção "Secure Erase").'),
    ],
  ),
  _Passo(
    titulo: 'Disco quebrado ou dados sensíveis?',
    texto:
        'Se não dá para apagar, peça a destruição física a uma empresa especializada. Não abra nem fure o disco em casa.',
    alerta: true,
  ),
  _Passo(
    titulo: 'Leve a um ponto de coleta',
    texto:
        'Nunca no lixo comum: os metais e os ímãs são reaproveitados na reciclagem.',
  ),
];

/// Guia passo a passo para descartar com segurança um aparelho com disco
/// (HD ou notebook): proteger os dados e depois levar à coleta.
class TelaGuiaDescarteSeguro extends StatefulWidget {
  final String aparelho;

  const TelaGuiaDescarteSeguro({super.key, required this.aparelho});

  @override
  State<TelaGuiaDescarteSeguro> createState() => _TelaGuiaDescarteSeguroState();
}

class _TelaGuiaDescarteSeguroState extends State<TelaGuiaDescarteSeguro> {
  final Set<int> _feitos = {};

  void _alternar(int indice) {
    setState(() {
      if (!_feitos.remove(indice)) _feitos.add(indice);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.verdeClaroFundo,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _construirCabecalho(),
                    Transform.translate(
                      offset: const Offset(0, -32),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _construirProgresso(),
                            const SizedBox(height: 18),
                            for (int i = 0; i < _passos.length; i++) ...[
                              _construirPasso(i),
                              const SizedBox(height: 10),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: const BoxDecoration(
                color: AppColors.fundoBranco,
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaMapa()),
                ),
                icon: const Icon(Icons.place_outlined, size: 20),
                label: const Text('Ver pontos de coleta'),
                style: BotoesEco.principal(altura: 52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES PARA NÃO REPETIR CÓDIGO ---

  Widget _construirCabecalho() {
    return Container(
      color: _ardosia,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 52),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BotaoCircularEco(
                    icone: Icons.chevron_left,
                    tooltip: 'Voltar',
                    corFundo: const Color(0x24FFFFFF),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Descarte seguro',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.fundoBranco,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GUIA DO ${widget.aparelho.toUpperCase()} · '
                      '${_passos.length} PASSOS',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Color(0xFFB0BEC5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Seus dados saem com você, o aparelho vai para a reciclagem',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
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

  Widget _construirProgresso() {
    final int feitos = _feitos.length;
    final bool completo = feitos == _passos.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fundoBranco,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            completo
                ? 'Tudo pronto! Pode levar à coleta.'
                : '$feitos de ${_passos.length} passos feitos',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textoTitulo,
            ),
          ),
          const SizedBox(height: 8),
          BarraProgressoEco(valor: feitos / _passos.length),
        ],
      ),
    );
  }

  Widget _construirPasso(int indice) {
    final _Passo passo = _passos[indice];
    final bool feito = _feitos.contains(indice);

    final Color fundo = passo.alerta && !feito
        ? AppColors.laranjaFundo
        : AppColors.fundoBranco;
    final Color borda = feito
        ? AppColors.bordaVerdeClara
        : passo.alerta
        ? const Color(0xFFFFD8A8)
        : const Color(0xFFE0E0E0);

    return Semantics(
      checked: feito,
      child: Material(
        color: fundo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: borda),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _alternar(indice),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _construirMarcador(indice, feito, passo.alerta),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${indice + 1}. ${passo.titulo}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: feito
                                  ? AppColors.textoSecundario
                                  : passo.alerta
                                  ? AppColors.laranjaTexto
                                  : AppColors.textoTitulo,
                              decoration: feito
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            passo.texto,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: passo.alerta && !feito
                                  ? const Color(0xFF5D3A12)
                                  : AppColors.textoSecundario,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (passo.detalhes.isNotEmpty && !feito) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.verdeClaroFundo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final (titulo, texto) in passo.detalhes) ...[
                          Text(
                            titulo,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: AppColors.verdeEscuro,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            texto,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: Color(0xFF2E5E30),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirMarcador(int indice, bool feito, bool alerta) {
    if (feito) {
      return const CircleAvatar(
        radius: 15,
        backgroundColor: AppColors.verdeGradienteInicio,
        child: Icon(Icons.check, size: 18, color: AppColors.fundoBranco),
      );
    }
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: alerta ? AppColors.laranjaIconeFundo : AppColors.fundoBranco,
        border: alerta
            ? null
            : Border.all(color: AppColors.verdeGradienteInicio, width: 2),
      ),
      child: Text(
        '${indice + 1}',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: alerta ? AppColors.laranjaTexto : AppColors.verdeEscuro,
        ),
      ),
    );
  }
}
