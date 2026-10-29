// Componentes que o Scanner IA pode reconhecer. Cada um está ligado a uma
// figurinha do tipo SCAN. Quais o app reconhece de fato depende do modelo
// instalado: veja ClassificadorComponente.componentesReconhecidos.
enum IdentificadorComponente {
  pilha('PILHA', 'FIG-08', 'Pilha'),
  mouse('MOUSE', 'FIG-09', 'Mouse'),
  ferroPassar('FERRO_PASSAR', 'FIG-10', 'Ferro de passar'),
  celular('CELULAR', 'FIG-11', 'Celular'),
  monitor('MONITOR', 'FIG-12', 'Monitor'),
  teclado('TECLADO', 'FIG-13', 'Teclado'),
  notebook('NOTEBOOK', 'FIG-14', 'Notebook'),
  placaCircuito('PLACA_CIRCUITO', 'FIG-15', 'Placa de circuito'),
  hd('HD', 'FIG-16', 'HD');

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
