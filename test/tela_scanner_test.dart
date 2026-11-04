import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ecocycle/core/ia/classificador_componente.dart';
import 'package:ecocycle/core/models/identificador_componente.dart';
import 'package:ecocycle/core/providers/figurinhas_provider.dart';
import 'package:ecocycle/core/providers/progresso_provider.dart';
import 'package:ecocycle/core/services/figurinha_service.dart';
import 'package:ecocycle/core/services/progresso_service.dart';
import 'package:ecocycle/features/scanner/tela_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

const String _msgObjetoDesconhecido =
    'Esse objeto não está entre os aparelhos que a IA reconhece. '
    'Aponte a câmera para um deles e tente de novo.';
const String _msgNaoIdentificado =
    'Tente aproximar mais a câmera ou melhore a iluminação do ambiente.';

class _ClassificadorFalso implements ClassificadorComponente {
  final ClassificacaoComponente? resultado;

  _ClassificadorFalso(this.resultado);

  @override
  Future<ClassificacaoComponente> classificar(Uint8List bytesImagem) async {
    final ClassificacaoComponente? r = resultado;
    if (r == null) throw StateError('modelo falhou');
    return r;
  }

  @override
  void fechar() {}
}

class _ApiFalsa implements HttpClientAdapter {
  final List<RequestOptions> pedidos = [];
  final int status;
  final Map<String, dynamic> corpo;

  _ApiFalsa(this.status, this.corpo);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    pedidos.add(options);
    return ResponseBody.fromString(
      jsonEncode(corpo),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _resposta({required bool reconhecido}) => {
  'data': {
    'reconhecido': reconhecido,
    'identificadorComponente': 'FONTE',
    'confianca': 95.0,
    'novaDesbloqueada': false,
    'figurinha': null,
    'mensagem': 'Confianca abaixo do limiar.',
  },
};

Future<void> _analisarFoto(
  WidgetTester tester, {
  required ClassificacaoComponente? classificacao,
  required _ApiFalsa api,
  bool usuarioDesistiu = false,
  bool cameraDisponivel = true,
  String opcao = 'Tirar foto',
  List<ImageSource>? origens,
}) async {
  Future<XFile?> obterFoto(ImageSource origem) async {
    origens?.add(origem);
    if (!cameraDisponivel) {
      throw PlatformException(code: 'no_available_camera');
    }
    return usuarioDesistiu
        ? null
        : XFile.fromData(Uint8List.fromList([1, 2, 3]));
  }

  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final Dio dio = Dio(BaseOptions(baseUrl: 'http://teste'))
    ..httpClientAdapter = api;
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<Dio>.value(value: dio),
        ChangeNotifierProvider(
          create: (_) => FigurinhasProvider(FigurinhaService(dio)),
        ),
        ChangeNotifierProvider(
          create: (_) => ProgressoProvider(ProgressoService(dio)),
        ),
      ],
      child: MaterialApp(
        home: TelaScanner(
          carregarClassificador: () async => _ClassificadorFalso(classificacao),
          obterFoto: obterFoto,
        ),
      ),
    ),
  );

  await tester.tap(find.byIcon(Icons.photo_camera_outlined));
  await tester.pumpAndSettle();
  await tester.tap(find.text(opcao));
  // A chamada à API alterna entre o relógio real e o do teste.
  for (int i = 0; i < 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 10));
  }
  // Termina de fechar o menu de origem da foto.
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  group('Scanner', () {
    testWidgets('Outros avisa que o objeto não é reconhecido e registra a '
        'leitura na API', (tester) async {
      final api = _ApiFalsa(200, _resposta(reconhecido: false));

      await _analisarFoto(
        tester,
        classificacao: const ClassificacaoComponente(
          identificador: null,
          confianca: 99,
        ),
        api: api,
      );

      expect(find.text(_msgObjetoDesconhecido), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
      expect(api.pedidos, hasLength(1));
      expect(api.pedidos.single.path, '/scanner/reconhecer');
      expect(api.pedidos.single.data, {
        'identificadorComponente': 'OUTROS',
        'confianca': 99.0,
      });
    });

    testWidgets('segunda classe vai para a API junto com a vencedora', (
      tester,
    ) async {
      final api = _ApiFalsa(200, _resposta(reconhecido: false));

      await _analisarFoto(
        tester,
        classificacao: const ClassificacaoComponente(
          identificador: IdentificadorComponente.mouse,
          confianca: 65,
          segundoIdentificador: 'PENDRIVE',
          segundaConfianca: 21,
        ),
        api: api,
      );

      expect(api.pedidos.single.data, {
        'identificadorComponente': 'MOUSE',
        'confianca': 65.0,
        'segundoIdentificador': 'PENDRIVE',
        'segundaConfianca': 21.0,
      });
    });

    testWidgets('segunda classe também vai junto na leitura Outros', (
      tester,
    ) async {
      final api = _ApiFalsa(200, _resposta(reconhecido: false));

      await _analisarFoto(
        tester,
        classificacao: const ClassificacaoComponente(
          identificador: null,
          confianca: 80,
          segundoIdentificador: 'MOUSE',
          segundaConfianca: 12,
        ),
        api: api,
      );

      expect(api.pedidos.single.data, {
        'identificadorComponente': 'OUTROS',
        'confianca': 80.0,
        'segundoIdentificador': 'MOUSE',
        'segundaConfianca': 12.0,
      });
    });

    testWidgets('Outros mantém o aviso quando o registro na API falha', (
      tester,
    ) async {
      final api = _ApiFalsa(500, {'message': 'erro'});

      await _analisarFoto(
        tester,
        classificacao: const ClassificacaoComponente(
          identificador: null,
          confianca: 99,
        ),
        api: api,
      );

      expect(find.text(_msgObjetoDesconhecido), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });

    for (final componente in [
      IdentificadorComponente.fonte,
      IdentificadorComponente.pendrive,
    ]) {
      testWidgets('${componente.valor} vai para a API com o identificador '
          'certo', (tester) async {
        final api = _ApiFalsa(200, _resposta(reconhecido: false));

        await _analisarFoto(
          tester,
          classificacao: ClassificacaoComponente(
            identificador: componente,
            confianca: 95,
          ),
          api: api,
        );

        expect(api.pedidos, hasLength(1));
        expect(api.pedidos.single.path, '/scanner/reconhecer');
        expect(api.pedidos.single.data, {
          'identificadorComponente': componente.valor,
          'confianca': 95.0,
        });
      });
    }

    testWidgets('lista dos 11 aparelhos cabe em tela pequena', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        Provider<Dio>.value(
          value: Dio(),
          child: MaterialApp(
            home: TelaScanner(
              carregarClassificador: () async => _ClassificadorFalso(null),
            ),
          ),
        ),
      );

      expect(find.text('A IA RECONHECE 11 APARELHOS'), findsOneWidget);
      expect(find.text('Monitor ou TV'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('confiança baixa recusada pela API pede outra foto', (
      tester,
    ) async {
      final api = _ApiFalsa(200, _resposta(reconhecido: false));

      await _analisarFoto(
        tester,
        classificacao: const ClassificacaoComponente(
          identificador: IdentificadorComponente.mouse,
          confianca: 60,
        ),
        api: api,
      );

      expect(find.text(_msgNaoIdentificado), findsOneWidget);
      expect(find.text(_msgObjetoDesconhecido), findsNothing);
    });

    testWidgets('back-end sem o identificador mostra o erro sem travar', (
      tester,
    ) async {
      final api = _ApiFalsa(400, {
        'message': "Identificador de componente desconhecido: 'FONTE'.",
      });

      await _analisarFoto(
        tester,
        classificacao: const ClassificacaoComponente(
          identificador: IdentificadorComponente.fonte,
          confianca: 95,
        ),
        api: api,
      );

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('falha do modelo não chama a API', (tester) async {
      final api = _ApiFalsa(200, _resposta(reconhecido: true));

      await _analisarFoto(tester, classificacao: null, api: api);

      expect(find.text(_msgNaoIdentificado), findsOneWidget);
      expect(api.pedidos, isEmpty);
    });

    testWidgets('desistir da câmera volta ao botão sem analisar nada', (
      tester,
    ) async {
      final api = _ApiFalsa(200, _resposta(reconhecido: true));

      await _analisarFoto(
        tester,
        classificacao: const ClassificacaoComponente(
          identificador: IdentificadorComponente.mouse,
          confianca: 95,
        ),
        api: api,
        usuarioDesistiu: true,
      );

      expect(api.pedidos, isEmpty);
      expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('sem app de câmera avisa e permite tentar de novo', (
      tester,
    ) async {
      final api = _ApiFalsa(200, _resposta(reconhecido: true));

      await _analisarFoto(
        tester,
        classificacao: const ClassificacaoComponente(
          identificador: IdentificadorComponente.mouse,
          confianca: 95,
        ),
        api: api,
        cameraDisponivel: false,
      );

      expect(
        find.text(
          'Não foi possível abrir a câmera ou a galeria deste aparelho.',
        ),
        findsOneWidget,
      );
      expect(find.text('Tentar novamente'), findsOneWidget);
      expect(api.pedidos, isEmpty);
    });

    for (final (opcao, origem) in [
      ('Tirar foto', ImageSource.camera),
      ('Escolher da galeria', ImageSource.gallery),
    ]) {
      testWidgets('"$opcao" usa a origem certa e analisa a foto', (
        tester,
      ) async {
        final api = _ApiFalsa(200, _resposta(reconhecido: false));
        final List<ImageSource> origens = [];

        await _analisarFoto(
          tester,
          classificacao: const ClassificacaoComponente(
            identificador: IdentificadorComponente.mouse,
            confianca: 95,
          ),
          api: api,
          opcao: opcao,
          origens: origens,
        );

        expect(origens, [origem]);
        expect(api.pedidos, hasLength(1));
      });
    }
  });
}
