import 'package:ecocycle/core/config/termos_config.dart';
import 'package:ecocycle/core/models/requests/register_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('o cadastro envia o aceite e a versão dos termos', () {
    final json = const RegisterRequest(
      email: 'a@b.com',
      apelido: 'ana',
      senha: 'senha123',
      aceitouTermos: true,
    ).toJson();

    expect(json['aceitouTermos'], isTrue);
    expect(json['versaoTermos'], TermosConfig.versao);
  });
}
