abstract class SentryConfig {
  static const String _override = String.fromEnvironment('SENTRY_DSN');

  // DSN do projeto no Sentry (Settings -> Projects -> Client Keys). Ele só
  // permite enviar erros, não lê nada, então pode ficar no código. Vazio
  // desliga o envio. Para usar outro projeto: --dart-define=SENTRY_DSN=...
  static const String _padrao =
      'https://eefe309b749773e4b41984575ea69e8b@o4512218646970368.ingest.us.sentry.io/4512218659487744';

  static String get dsn => _override.isNotEmpty ? _override : _padrao;
}
