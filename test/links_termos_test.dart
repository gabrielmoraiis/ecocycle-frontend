import 'package:ecocycle/features/cadastro/tela_cadastro.dart';
import 'package:ecocycle/features/termos/tela_documento_legal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('link "Termos de Uso" do cadastro abre o documento', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(411, 900));
    await tester.pumpWidget(const MaterialApp(home: TelaCadastro()));
    await tester.pumpAndSettle();

    final texto = find.byWidgetPredicate(
      (w) => w is RichText && w.text.toPlainText().startsWith('Aceito os'),
    );
    expect(texto, findsOneWidget);
    // toca no meio da palavra "Termos de Uso"
    final caixa = tester.getRect(texto);
    await tester.tapAt(Offset(caixa.left + 160, caixa.top + 8));
    // a tela abre carregando o texto (spinner animado): não espera assentar
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(TelaDocumentoLegal), findsOneWidget);
  });

  for (final (rotulo, titulo) in [
    ('Ler os Termos de Uso', 'Termos de Uso'),
    ('Ler a Política de Privacidade', 'Política de Privacidade'),
  ]) {
    testWidgets('botão "$rotulo" abre o documento', (tester) async {
      await tester.binding.setSurfaceSize(const Size(411, 900));
      await tester.pumpWidget(const MaterialApp(home: TelaCadastro()));
      await tester.pumpAndSettle();

      await tester.tap(find.text(rotulo));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(TelaDocumentoLegal), findsOneWidget);
      expect(find.widgetWithText(AppBar, titulo), findsOneWidget);
    });
  }
}
