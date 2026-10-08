// Componentes reconhecidos pelo Scanner IA. Cada um está ligado a uma
// figurinha do tipo SCAN; o mesmo mapeamento é usado pela busca manual.
enum IdentificadorComponente {
  pilha('PILHA', 'FIG-08', 'Pilha'),
  mouse('MOUSE', 'FIG-09', 'Mouse'),
  ferroPassar('FERRO_PASSAR', 'FIG-10', 'Ferro de passar');

  final String valor;
  final String codigoFigurinha;
  final String rotulo;
  const IdentificadorComponente(this.valor, this.codigoFigurinha, this.rotulo);

  static IdentificadorComponente? daFigurinha(String codigo) {
    for (final identificador in values) {
      if (identificador.codigoFigurinha == codigo) return identificador;
    }
    return null;
  }
}
