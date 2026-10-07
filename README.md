# Previu

Aplicativo Flutter com oito telas e dados reais do OpenWeather. Fundo branco em toda a janela, conteúdo limitado a 760 pixels para leitura no navegador e layout adaptado ao celular.

## Executar no VS Code

Abra esta pasta. Selecione **Previu · tempo real (Chrome)** em Executar e Depurar e pressione F5. Pare a execução anterior antes de reiniciar: alterações na chave exigem reinício completo.

```sh
flutter run -d chrome --dart-define-from-file=env/local.json --dart-define=DEMO_MODE=false
```

A chave fica em `env/local.json`, ignorado pelo Git. Em outra máquina, copie `env/example.json` e configure `OPENWEATHER_API_KEY`.

## Dados reais

- Tempo atual: `https://api.openweathermap.org/data/2.5/weather`, com coordenadas da cidade selecionada, Celsius e português.
- Busca: `https://api.openweathermap.org/geo/1.0/direct`, com até cinco resultados e respectivas coordenadas.
- Previsão: `https://api.openweathermap.org/data/2.5/forecast`, com intervalos de três horas nas próximas 120 horas. A interface informa que são cinco dias; não inventa dois dias adicionais.
- Detalhes: temperaturas, chuva e vento dos horários fornecidos pela previsão. Os períodos sem resposta não aparecem. As mínimas e máximas resumem os intervalos disponíveis e podem cobrir dias parciais.
- Horários solares: dados da consulta atual, exibidos na tela Hoje.
- Atualização manual pelo botão Atualizar tempo; automática a cada cinco minutos enquanto Hoje estiver aberta. O horário exibido é o da medição da API.
- Cache por coordenadas durante dez minutos; atualização manual e automática forçam nova consulta. Falhas mantêm os últimos dados da sessão com indicação de erro.

O modo real é o padrão. Nenhuma falha da API é substituída por previsão de demonstração.

## Páginas e navegação

Os oito arquivos ficam em `lib/features/previu/pages/`: boas-vindas, hoje, próximos dias, busca de cidade, detalhes do dia, carregando, sem conexão e cidade não encontrada.

Na tela inicial, escolha Buscar cidade. Digite o nome, selecione o resultado e consulte o tempo. Use as abas Hoje, Próximos dias e Cidades. Toque em um dia da previsão para ver seus detalhes. A localização do dispositivo ainda não está integrada; esse botão informa a limitação e abre a busca no modo real.

`previu_flow.dart` controla navegação e estados, `ui.dart` reúne componentes e `features/weather/` contém modelos, serviço HTTP e cache.

## Demonstração opcional

Somente para comparação com os valores das imagens:

```sh
flutter run -d chrome --dart-define=DEMO_MODE=true
```

## Verificação

```sh
flutter analyze
flutter test
flutter build web --dart-define-from-file=env/local.json --dart-define=DEMO_MODE=false
```

Os testes abrangem cache separado por cidade, unidades e idioma, erros de autenticação, busca sem resultados, agregação da previsão no fuso da cidade, navegação e telas estreitas com texto ampliado.
