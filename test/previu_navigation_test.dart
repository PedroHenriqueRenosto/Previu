import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:previu/features/weather/data/weather_repository.dart';
import 'package:previu/features/weather/data/weather_service.dart';
import 'package:previu/main.dart';

void main() {
  testWidgets(
    'search, day details, back navigation and error recovery on a narrow phone',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        PreviuApp(
          repository: WeatherRepository(
            service: WeatherService(apiKey: ''),
            demo: true,
          ),
        ),
      );
      await tester.ensureVisible(find.text('Buscar cidade'));
      await tester.tap(find.text('Buscar cidade'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Abcxyz');
      await tester.pumpAndSettle();
      expect(find.text('Cidade não\nencontrada'), findsOneWidget);
      await tester.ensureVisible(find.text('Limpar busca'));
      await tester.tap(find.text('Limpar busca'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'curitiba');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Curitiba, PR'));
      await tester.pump();
      expect(find.text('Carregando previsão…'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('7 dias'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Amanhã'));
      await tester.tap(find.text('Amanhã'));
      await tester.pumpAndSettle();
      expect(find.text('Quinta-feira'), findsOneWidget);
      expect(find.text('Chuva leve'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      expect(find.text('Próximos 7 dias'), findsOneWidget);
      await tester.tap(find.byTooltip('Explorar as 8 telas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('07 Sem conexão'));
      await tester.pumpAndSettle();
      expect(find.text('Não conseguimos\natualizar o tempo.'), findsOneWidget);
      await tester.ensureVisible(find.text('Tentar novamente'));
      await tester.tap(find.text('Tentar novamente'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('24°'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('the app fills a desktop viewport with a white background', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      PreviuApp(
        repository: WeatherRepository(
          service: WeatherService(apiKey: ''),
          demo: true,
        ),
      ),
    );
    expect(tester.getSize(find.byType(Scaffold)), const Size(1440, 900));
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      Colors.white,
    );
  });
}
