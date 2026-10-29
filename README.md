# EcoCycle — App

Aplicativo mobile do **EcoCycle**: um app gamificado de educação e descarte responsável de lixo eletrônico. A pessoa aprende sobre os 4 R's e os riscos do lixo eletrônico, identifica aparelhos com a câmera usando **IA rodando no próprio celular**, encontra pontos de coleta próximos e completa um **álbum de figurinhas**.

> Back-end (API Spring Boot): [MarinaMts/ecocycle-backend](https://github.com/MarinaMts/ecocycle-backend) · Documentação da API: [Swagger](https://ecocycle-backend-ptar.onrender.com/swagger-ui/index.html)

---

## Funcionalidades

| Área | O que faz |
|---|---|
| **Início** | Saudação com avatar e XP, atalho para o Scanner, "Continue aprendendo" com o próximo módulo, progresso do álbum e curiosidades. |
| **Aprender** | Duas trilhas (*Os 4 R's* e *Lixo Eletrônico*) com módulos em texto ilustrado e um quiz por módulo. Cada quiz concluído libera uma figurinha e XP. |
| **Scanner IA** | Tira uma foto e classifica o aparelho **on-device** com um modelo TensorFlow Lite. Só o resultado (componente + confiança) vai para o back-end; a imagem nunca sai do celular. Tem lanterna e moldura de enquadramento. |
| **Mapa** | Pontos de coleta no Google Maps, busca por CEP, ordenação por distância, filtros (celulares, baterias) e rota até o ponto. |
| **Álbum** | 16 figurinhas em ordem (7 de quiz e 9 do Scanner), com dica de como conseguir cada uma. Cada figurinha tem ficha com o que tem dentro, risco ambiental e como descartar. |
| **Descarte seguro** | Para HD, notebook e celular, a figurinha mostra como proteger os dados antes do descarte. HD e notebook têm um guia passo a passo com checklist. |
| **Perfil** | Avatar (6 mascotes), estatísticas, sair da conta e excluir conta. |
| **Conta** | Cadastro e login com e-mail e senha (JWT guardado no armazenamento seguro do aparelho). |

### O que o Scanner reconhece
O app conhece 9 componentes — pilha, mouse, ferro de passar, celular, monitor, teclado, notebook, placa de circuito e HD —, mas reconhece de fato **só as classes do modelo instalado**. A tela do Scanner mostra essa lista ("A IA reconhece N aparelhos"). Veja [Trocar o modelo de IA](#trocar-o-modelo-de-ia).

---

## Tecnologias

- **Flutter** (Dart `^3.11`) — alvo principal: Android
- **provider** — estado global (sessão, progresso, trilhas, figurinhas)
- **dio** — cliente HTTP, com interceptors de autenticação e de erro
- **flutter_secure_storage** — token JWT
- **tflite_flutter** + **image** — classificação de imagens on-device (modelo YOLO11-cls exportado pelo Ultralytics)
- **camera** / **image_picker** — câmera do Scanner
- **google_maps_flutter**, **geolocator**, **geocoding**, **url_launcher** — mapa, localização, CEP e rotas
- **flutter_markdown_plus** — conteúdo dos módulos
- **sentry_flutter** — monitoramento de erros (desligado por padrão)
- **flutter_launcher_icons** / **flutter_native_splash** — ícone e splash

---

## Estrutura do projeto

```
lib/
├── main.dart                     # inicialização, providers e rota inicial (logado ou não)
├── core/
│   ├── config/                   # URL da API e DSN do Sentry
│   ├── data/                     # catálogos locais: figurinhas, trilhas, ilustrações
│   ├── ia/                       # classificador TFLite (e stub para a web)
│   ├── models/                   # modelos da API e requests
│   ├── network/                  # cliente dio, interceptors, ApiException
│   ├── providers/                # SessionController, Progresso, Trilhas, Figurinhas
│   ├── services/                 # chamadas à API por recurso
│   ├── theme/                    # cores e tema
│   └── widgets/                  # componentes compartilhados (layout_eco, formulario_eco,
│                                 #   cartao_figurinha, avatar_usuario, barra de navegação...)
└── features/                     # uma pasta por tela/fluxo
    ├── introducao/  login/  cadastro/
    ├── home/  aprender/  scanner/  mapa/  album/  perfil/

assets/
├── avatares/     # 6 mascotes usados como foto de perfil
├── conteudos/    # ilustrações dos módulos (escolhidas pelo título do conteúdo)
├── logo/         # símbolo da logo
├── branding/     # ícone e splash (usados pelas ferramentas de geração)
└── ia/           # ecocycle_scanner.tflite
```

**Onde ficam os textos das figurinhas:** nome e descrição vêm da API; ícone, cores, raridade, ficha (o que tem dentro, risco, descarte) e os passos de proteção de dados ficam em `lib/core/data/figurinha_presentation_catalog.dart`, indexados pelo código (`FIG-01` … `FIG-16`).

---

## Como rodar

### Pré-requisitos
- Flutter SDK compatível com Dart 3.11 (`flutter doctor` sem erros)
- Android Studio / SDK do Android e um aparelho ou emulador
- Uma chave do **Google Maps SDK for Android**

### 1. Instalar as dependências
```bash
flutter pub get
```

### 2. Configurar a chave do Google Maps
A chave **não é versionada**. Crie (ou edite) `android/local.properties` e adicione:
```properties
MAPS_API_KEY=sua_chave_aqui
```
Sem ela, o app abre normalmente, mas o mapa fica em branco.

### 3. Rodar
```bash
flutter run
```
Por padrão o app usa a API publicada no Render. Para apontar para um back-end local:
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```
(`10.0.2.2` é o `localhost` do computador visto de dentro do emulador Android.)

### Variáveis de build (`--dart-define`)

| Variável | Padrão | Para que serve |
|---|---|---|
| `API_BASE_URL` | `https://ecocycle-backend-ptar.onrender.com` | Endereço do back-end (o app acrescenta `/api/v1`). |
| `SENTRY_DSN` | vazio (desligado) | DSN do projeto no Sentry para enviar erros. |

---

## Gerar o APK

```bash
flutter build apk --release
```
O arquivo sai em `build/app/outputs/flutter-apk/app-release.apk`. Para instalar com o celular conectado:
```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```
APKs menores, um por arquitetura (o `arm64-v8a` serve para quase todos os celulares atuais):
```bash
flutter build apk --release --split-per-abi
```

> O release está assinado com a chave de debug (serve para instalar direto e distribuir para testes). Para publicar na Play Store é preciso configurar uma chave de release em `android/app/build.gradle.kts`.

---

## Trocar o modelo de IA

1. **Substitua** `assets/ia/ecocycle_scanner.tflite` pelo modelo novo, com o mesmo nome. Ele precisa ser o export padrão do Ultralytics (`format=tflite`): entrada float32 com imagem quadrada de 3 canais e saída float32 com uma posição por classe.
2. **Confira a ordem das classes** no metadata embutido no arquivo:
   ```bash
   unzip -p assets/ia/ecocycle_scanner.tflite metadata.json
   ```
   O campo `"names"` traz a ordem (o Ultralytics ordena pelo nome das pastas do dataset).
3. **Atualize a lista `_classes`** em `lib/core/ia/classificador_componente_tflite.dart` **na mesma ordem**. Os nomes de pasta esperados são `celular`, `ferro_passar`, `hd`, `monitor`, `mouse`, `notebook`, `pilha`, `placa_circuito` e `teclado`.
   - Quantidade de classes diferente → o modelo não carrega (erro visível).
   - Mesma quantidade, ordem errada → o app troca os itens **sem avisar**. Sempre confira.
4. **Gere o APK de novo** (rode `flutter clean` antes para não ficar com o modelo antigo em cache).

Para um componente **novo** (fora dos 9), além do modelo é preciso: um valor novo em `lib/core/models/identificador_componente.dart`, a ficha em `figurinha_presentation_catalog.dart` e a figurinha correspondente no back-end (migration + seed), com o mesmo `identificador_scan`.

> O back-end só aceita leituras com confiança a partir de **90%** (`SCANNER_LIMIAR_CONFIANCA`).

---

## Ícone e splash
As imagens ficam em `assets/branding/`. Depois de trocá-las:
```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## Qualidade

```bash
flutter analyze
flutter test
```

---

## Problemas comuns

- **Primeira abertura demora / "erro de conexão":** a API fica no plano gratuito do Render e "dorme" sem uso. A primeira requisição pode levar até ~1 minuto; tente de novo.
- **Mapa em branco:** falta `MAPS_API_KEY` em `android/local.properties`, ou a chave não tem o *Maps SDK for Android* ativo.
- **Scanner diz "não identificado" para tudo:** confira se a lista `_classes` bate com o modelo (ver acima) e se o objeto está entre os itens que o modelo reconhece.
- **Busca por CEP não funciona na web:** usa o geocoder nativo do Android/iOS; na versão web o app avisa que não está disponível.
- **Câmera no emulador:** mostra uma cena virtual ou um padrão de teste; para testar a IA de verdade, use um celular.
