# Previu

Início do aplicativo de previsão do tempo em Flutter, baseado no wireframe e na documentação do projeto.

## Esta primeira etapa

- Tela **Hoje** com Curitiba, PR como localidade fixa, seguindo o novo wireframe em tons de cinza.
- Cabeçalho compacto, cartão de temperatura e ícones de contorno desenhados localmente.
- Cartões de umidade e vento em km/h; pressão, visibilidade e horários solares em **Mais detalhes de hoje**.
- Consulta real à Current Weather API, atualização manual e cache em memória por 10 minutos.
- Carregamento com blocos de espera, erro com nova tentativa e cartão dos últimos dados se a atualização falhar.
- Layout para celular; na web em telas maiores, a interface permanece centralizada.
- Navegação **Hoje / 7 dias / Cidades**. Busca e previsão de sete dias aparecem como indisponíveis nesta etapa. Ainda não há GPS, consulta One Call, detalhes diários, boas-vindas ou cache persistente.

## Executar

Requer Flutter 3.44.4 / Dart 3.12.2 ou versões compatíveis.

```sh
flutter pub get
flutter run -d edge --dart-define-from-file=env/local.json
```

A chave fornecida está configurada em `env/local.json`, ignorado pelo Git. Em outra máquina, copie `env/example.json` para `env/local.json` e preencha `OPENWEATHER_API_KEY`.

O Edge está disponível nesta máquina. No VS Code, abra esta pasta, escolha **Previu · tempo real (Edge)** em **Executar e Depurar** e pressione F5.

Para Android, inicie um emulador ou conecte um aparelho, consulte `flutter devices` e substitua `edge` pelo ID. A estrutura de iOS está incluída, mas sua compilação requer macOS e Xcode. Esta primeira etapa não inclui a plataforma Windows desktop; execute no navegador ou em Android/iOS.

Para visualizar o layout sem chamadas à API:

```sh
flutter run -d edge --dart-define=DEMO_MODE=true
```

Esse modo exibe **PRÉVIA · DADOS ILUSTRATIVOS**. No modo real, uma falha nunca é substituída silenciosamente por dados inventados. As configurações de execução também estão disponíveis no VS Code.

As duas linhas de previsão do wireframe são mostradas apenas nesse modo ilustrativo. A execução com a API real mostra **Em breve** até a integração da previsão diária.

## Organização

```text
lib/
  main.dart
  features/weather/
    domain/current_weather.dart
    data/weather_service.dart
    data/weather_repository.dart
    presentation/current_weather_page.dart
    presentation/widgets/weather_icon.dart
```

O serviço monta a URL HTTPS, faz o GET e converte erros em mensagens. O modelo preserva valores ausentes e números sem arredondamento. O repositório controla o cache da sessão. A tela converte vento e visibilidade apenas na apresentação. Os horários atuais usam o deslocamento UTC fornecido pela API, sem depender do fuso do aparelho.

## Verificação

```sh
flutter analyze
flutter test
flutter build web --dart-define=DEMO_MODE=true
```

Os testes cobrem leitura de números e campos ausentes, horários locais, requisições, falha de autenticação sem repetição automática, cache após falha, recuperação da tela e layout estreito com texto ampliado.

## Chave e integração

O arquivo local evita versionar a chave; `dart-define` não esconde credenciais dentro de um aplicativo distribuído. Antes da publicação, a integração deve passar por um backend, conforme a documentação. Esta etapa consulta somente `/data/2.5/weather`, sem utilizar o produto One Call.

Referências: [Current Weather / OpenWeather](https://openweathermap.org/api/current) e [requisições HTTP no Flutter](https://docs.flutter.dev/cookbook/networking/fetch-data).
