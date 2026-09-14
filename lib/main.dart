import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/network/dio_client.dart';
import 'core/providers/figurinhas_provider.dart';
import 'core/providers/progresso_provider.dart';
import 'core/providers/session_controller.dart';
import 'core/providers/trilhas_provider.dart';
import 'core/services/auth_service.dart';
import 'core/services/figurinha_service.dart';
import 'core/services/progresso_service.dart';
import 'core/services/trilha_service.dart';
import 'core/services/user_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/loading_indicator.dart';
import 'features/home/tela_home.dart';
import 'features/introducao/tela_inicial.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  late final SessionController sessionController;
  final dio = buildDioClient(
    getToken: () => sessionController.token,
    onUnauthorized: () => sessionController.forceLogout(),
  );

  sessionController = SessionController(
    authService: AuthService(dio),
    userService: UserService(dio),
  );
  await sessionController.tentarRestaurarSessao();

  runApp(EcoCycleApp(dio: dio, sessionController: sessionController));
}

class EcoCycleApp extends StatelessWidget {
  final Dio dio;
  final SessionController sessionController;

  const EcoCycleApp({
    super.key,
    required this.dio,
    required this.sessionController,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionController>.value(
          value: sessionController,
        ),
        Provider<Dio>.value(value: dio),
        ChangeNotifierProvider<FigurinhasProvider>(
          create: (_) => FigurinhasProvider(FigurinhaService(dio)),
        ),
        ChangeNotifierProvider<ProgressoProvider>(
          create: (_) => ProgressoProvider(ProgressoService(dio)),
        ),
        ChangeNotifierProvider<TrilhasProvider>(
          create: (_) => TrilhasProvider(TrilhaService(dio)),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EcoCycle',
        theme: AppTheme.light,
        home: Consumer<SessionController>(
          builder: (context, session, _) {
            switch (session.status) {
              case AuthStatus.unknown:
                return const Scaffold(body: LoadingIndicator());
              case AuthStatus.authenticated:
                return const TelaHome();
              case AuthStatus.unauthenticated:
                return const TelaInicialEcoCycle();
            }
          },
        ),
      ),
    );
  }
}
