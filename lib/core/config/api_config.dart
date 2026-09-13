abstract class ApiConfig {
  static const String _override = String.fromEnvironment('API_BASE_URL');

  static const String apiPrefix = '/api/v1';

  // Backend publicado no Render. Para apontar para um backend local durante o
  // desenvolvimento, rode com --dart-define=API_BASE_URL=http://10.0.2.2:8080
  // (emulador Android) ou http://localhost:8080 (demais plataformas).
  static const String _padrao = 'https://ecocycle-backend-ptar.onrender.com';

  static String get baseUrl => _override.isNotEmpty ? _override : _padrao;

  static String get apiBaseUrl => '$baseUrl$apiPrefix';
}
