import 'package:flutter/material.dart';
import 'features/introducao/tela_inicial.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);

  runApp(const EcoCycleApp());
}

class EcoCycleApp extends StatelessWidget {
  const EcoCycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoCycle',
      home: TelaInicialEcoCycle(),
    );
  }
}