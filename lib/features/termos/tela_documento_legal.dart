import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';

/// Os dois documentos que a pessoa aceita no cadastro. Ficam dentro do app
/// (assets/termos), então abrem mesmo sem internet.
enum DocumentoLegal {
  termosDeUso('Termos de Uso', 'assets/termos/termos_de_uso.md'),
  politicaDePrivacidade(
    'Política de Privacidade',
    'assets/termos/politica_de_privacidade.md',
  );

  final String titulo;
  final String caminho;
  const DocumentoLegal(this.titulo, this.caminho);

  void abrir(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaDocumentoLegal(documento: this),
      ),
    );
  }
}

class TelaDocumentoLegal extends StatelessWidget {
  final DocumentoLegal documento;

  const TelaDocumentoLegal({super.key, required this.documento});

  @override
  Widget build(BuildContext context) {
    const corpo = TextStyle(
      fontSize: 15,
      height: 1.5,
      color: AppColors.textoEscuro,
    );
    return Scaffold(
      backgroundColor: AppColors.fundoBranco,
      appBar: AppBar(
        title: Text(documento.titulo),
        backgroundColor: AppColors.fundoBranco,
        foregroundColor: AppColors.textoTitulo,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: rootBundle.loadString(documento.caminho),
          builder: (context, snapshot) {
            final texto = snapshot.data;
            if (texto == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return Markdown(
              data: texto,
              // E-mails de contato abrem o app de e-mail.
              onTapLink: (texto, href, titulo) {
                final destino = href ?? texto;
                final uri = destino.contains('@') && !destino.contains(':')
                    ? Uri(scheme: 'mailto', path: destino)
                    : Uri.tryParse(destino);
                if (uri != null) launchUrl(uri);
              },
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              styleSheet: MarkdownStyleSheet(
                p: corpo,
                listBullet: corpo,
                h1: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textoTitulo,
                ),
                h2: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.verdeEscuro,
                ),
                h2Padding: const EdgeInsets.only(top: 16),
                strong: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
    );
  }
}
