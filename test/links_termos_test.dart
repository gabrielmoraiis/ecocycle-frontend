import 'package:ecocycle/features/cadastro/tela_cadastro.dart';
import 'package:ecocycle/features/termos/tela_documento_legal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _abrirCadastro(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(411, 900));
  await tester.pumpWidget(const MaterialApp(home: TelaCadastro()));
  await tester.pumpAndSettle();
}

/// A tela do documento abre carregando o texto (spinner animado), então não
/// dá para esperar "assentar": avança a transição de rota e confere.
Future<void> _esperarTransicao(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

bool _caixinhaMarcada(WidgetTester tester) =>
    tester.widget<Checkbox>(find.byType(Checkbox, skipOffstage: false)).value ??
    false;

void main() {
  for (final (link, titulo) in [
    ('Termos de Uso', 'Termos de Uso'),
    ('Política de Privacidade', 'Política de Privacidade'),
  ]) {
    testWidgets('tocar em "$link" no texto do aceite abre o documento', (
      tester,
    ) async {
      await _abrirCadastro(tester);

      await tester.tap(find.text(link));
      await _esperarTransicao(tester);

      expect(find.byType(TelaDocumentoLegal), findsOneWidget);
      expect(find.widgetWithText(AppBar, titulo), findsOneWidget);
    });

    testWidgets('tocar logo acima/abaixo de "$link" ainda abre o documento', (
      tester,
    ) async {
      await _abrirCadastro(tester);

      // a área de toque do link é maior que a palavra (para o dedo não cair
      // na caixinha)
      final palavra = tester.getRect(find.text(link));
      await tester.tapAt(Offset(palavra.center.dx, palavra.bottom + 4));
      await _esperarTransicao(tester);

      expect(find.byType(TelaDocumentoLegal), findsOneWidget);
    });
  }

  testWidgets('abrir um documento não marca a caixinha', (tester) async {
    await _abrirCadastro(tester);

    await tester.tap(find.text('Termos de Uso'));
    await _esperarTransicao(tester);
    expect(_caixinhaMarcada(tester), isFalse);
  });

  testWidgets('tocar no texto fora dos links marca a caixinha', (tester) async {
    await _abrirCadastro(tester);
    expect(_caixinhaMarcada(tester), isFalse);

    // toca em "Aceito os", no começo do texto (o centro cai em cima do link)
    final texto = tester.getRect(find.textContaining('Aceito os'));
    await tester.tapAt(Offset(texto.left + 12, texto.top + 14));
    await tester.pumpAndSettle();

    expect(_caixinhaMarcada(tester), isTrue);
    expect(find.byType(TelaDocumentoLegal), findsNothing);
  });

  testWidgets('não há botões extras para ler os documentos', (tester) async {
    await _abrirCadastro(tester);
    expect(find.textContaining('Ler os Termos'), findsNothing);
    expect(find.textContaining('Ler a Política'), findsNothing);
  });
}
