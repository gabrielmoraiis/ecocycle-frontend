import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema central do app. As telas continuam definindo suas próprias cores
/// explicitamente widget a widget (padrão já usado em todo o projeto), então
/// isto não muda a aparência de nada que já está estilizado — só passa a
/// valer como padrão para o que nenhuma tela define (seleção de texto,
/// cursor, splash/highlight de toque, cor de fundo padrão de Scaffold etc.).
abstract class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.verdeGradienteInicio,
      primary: AppColors.verdeGradienteInicio,
      secondary: AppColors.destaqueVerdeClaro,
      surface: AppColors.fundoBranco,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.fundoBranco,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.verdeGradienteInicio,
        selectionColor: AppColors.bordaVerdeClara,
        selectionHandleColor: AppColors.verdeGradienteInicio,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.verdeGradienteInicio,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.fundoBranco,
        foregroundColor: AppColors.verdeGradienteInicio,
        elevation: 0,
        centerTitle: true,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.textoEscuro,
        contentTextStyle: TextStyle(color: AppColors.fundoBranco),
      ),
    );
  }
}
