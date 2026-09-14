import 'package:flutter/material.dart';

import '../network/api_exception.dart';
import 'error_state.dart';
import 'loading_indicator.dart';

/// Reduz o boilerplate repetido de "carregando / erro / dado" que cada tela
/// reimplementava manualmente (isLoading + erro + dado + try/catch). A tela
/// só fornece a função que busca o dado e como renderizá-lo; loading e erro
/// (com botão de repetir) ficam a cargo deste widget.
class AsyncBuilder<T> extends StatefulWidget {
  final Future<T> Function() carregar;
  final Widget Function(
    BuildContext context,
    T dado,
    Future<void> Function() recarregar,
  )
  builder;

  const AsyncBuilder({
    super.key,
    required this.carregar,
    required this.builder,
  });

  @override
  State<AsyncBuilder<T>> createState() => AsyncBuilderState<T>();
}

class AsyncBuilderState<T> extends State<AsyncBuilder<T>> {
  bool _carregando = true;
  ApiException? _erro;
  T? _dado;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final dado = await widget.carregar();
      if (mounted) setState(() => _dado = dado);
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando && _dado == null) return const LoadingIndicator();
    if (_erro != null && _dado == null) {
      return ErrorState(message: _erro!.message, onRetry: _carregar);
    }
    return widget.builder(context, _dado as T, _carregar);
  }
}
