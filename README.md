# Previu

Aplicativo Flutter com as oito telas das referências, fundo branco e navegação funcional. A interface ocupa toda a janela, sem moldura de celular, bordas externas cinza ou barra de status simulada. No celular, o teclado e as barras do sistema são nativos.

## Abrir no VS Code

Abra esta pasta. Em Executar e Depurar, selecione **Previu · prévia do layout (Edge)** e pressione **F5**. O modo de demonstração também é o padrão ao executar sem parâmetros.

```sh
flutter pub get
flutter run -d edge --dart-define=DEMO_MODE=true
```

## As oito páginas

Os arquivos ficam em `lib/features/previu/pages/`:

1. `welcome_page.dart`: boas-vindas, localização e busca.
2. `today_page.dart`: tempo atual, umidade, vento e resumo dos próximos dias.
3. `week_page.dart`: previsão dos sete dias; toque em um dia para abrir detalhes.
4. `search_city_page.dart`: busca de cidades com teclado nativo e seleção.
5. `day_detail_page.dart`: temperaturas ao longo do dia, chuva, vento e horários solares.
6. `loading_page.dart`: estrutura de espera durante o carregamento.
7. `offline_page.dart`: erro, nova tentativa e últimos dados da sessão.
8. `city_not_found_page.dart`: busca sem resultados, limpar busca e localização.

`previu_flow.dart` controla navegação, consulta e estados. `ui.dart` reúne cartões, botões, linhas de previsão e cores. Os ícones meteorológicos são desenhados localmente em `lib/features/weather/presentation/widgets/weather_icon.dart`.

## Explorar

Da tela inicial, escolha **Buscar cidade** ou **Usar minha localização**. Use as abas **Hoje**, **7 dias** e **Cidades**. Em **7 dias**, toque em uma linha. Procure `Abcxyz` para abrir Cidade não encontrada. O botão de três pontos no cabeçalho da demonstração permite abrir qualquer uma das oito telas, inclusive Carregando e Sem conexão. Carregando aberto pelo menu permanece visível para inspeção; use uma aba para sair.

## Dados de demonstração e integração real

A demonstração reproduz os valores e datas das imagens. A busca filtra uma lista local de cidades e aceita nomes sem acentos. A localização usa Curitiba na demonstração e informa isso ao usuário; GPS não está integrado. A previsão diária e os detalhes são ilustrativos.

A integração existente com OpenWeather foi preservada: consulta real para Curitiba, atualização, tratamento de falhas e cache em memória de dez minutos. Para usar, selecione **Previu · tempo real (Edge)** no VS Code. Essa configuração utiliza a chave em `env/local.json`, ignorada pelo Git, e desativa explicitamente a demonstração.

```sh
flutter run -d edge --dart-define-from-file=env/local.json --dart-define=DEMO_MODE=false
```

No modo real, a interface não apresenta previsão diária inventada. A busca de outras cidades e GPS ainda precisam de integração. Em outra máquina, configure uma chave em `env/local.json` conforme `env/example.json`. Não publique a chave.

## Verificar

```sh
flutter analyze
flutter test
flutter build web --dart-define=DEMO_MODE=true
```

Os testes verificam consulta e cache, recuperação após falha, navegação da busca até detalhes, limpeza de busca sem resultados, preenchimento da janela com fundo branco e layout de 320 pixels com texto ampliado.
