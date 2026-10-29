import '../models/conteudo_educativo.dart';

// Palavra-chave do título (minúsculo, sem acento) → arquivo em
// assets/conteudos/. A ordem importa: "descart" vem antes de "lixo eletr"
// porque o conteúdo de descarte também fala de lixo eletrônico.
const List<(String, String)> _porPalavraChave = [
  ('recicl', 'reciclar.jpg'),
  ('reutiliz', 'reutilizar.jpg'),
  ('reduz', 'reduzir.jpg'),
  ('repar', 'reparar.jpg'),
  ('componente', 'componentes.jpg'),
  ('descart', 'descarte.jpg'),
  ('lixo eletr', 'lixo_eletronico.jpg'),
];

const Map<String, String> _semAcento = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'é': 'e', 'ê': 'e', 'í': 'i', //
  'ó': 'o', 'ô': 'o', 'õ': 'o', 'ú': 'u', 'ü': 'u', 'ç': 'c',
};

String _normalizar(String texto) =>
    texto.toLowerCase().split('').map((c) => _semAcento[c] ?? c).join();

/// Arquivo em assets/conteudos/ correspondente ao título, ou null.
String? ilustracaoPorTitulo(String titulo) {
  final normalizado = _normalizar(titulo);
  for (final (palavra, arquivo) in _porPalavraChave) {
    if (normalizado.contains(palavra)) return arquivo;
  }
  return null;
}

/// Ilustração do conteúdo, escolhida pelo título. Sem correspondência, usa o
/// `imagemSugerida` do backend (que pode ser nulo).
String? ilustracaoDoConteudo(ConteudoEducativo conteudo) =>
    ilustracaoPorTitulo(conteudo.titulo) ?? conteudo.imagemSugerida;
