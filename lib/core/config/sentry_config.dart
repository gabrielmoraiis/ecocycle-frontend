abstract class SentryConfig {
  static const String _override = String.fromEnvironment('SENTRY_DSN');

  // Sem DSN no código: o envio fica desligado por padrão. Para ativar, passe o
  // DSN do projeto (Settings -> Projects -> Client Keys) no build:
  // --dart-define=SENTRY_DSN=...
  static const String _padrao = '';

  static String get dsn => _override.isNotEmpty ? _override : _padrao;
}
