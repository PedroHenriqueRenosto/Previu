import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:previu/features/weather/data/weather_repository.dart';
import 'package:previu/features/weather/data/weather_service.dart';
import 'package:previu/main.dart';

import 'weather_test.dart' show responseData;

void main() {
  testWidgets('fits a narrow phone with larger accessibility text', (
    tester,
  ) async {
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
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Usar minha localização'));
    await tester.tap(find.text('Usar minha localização'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('24°'), findsOneWidget);
    expect(find.text('PRÉVIA · DADOS ILUSTRATIVOS'), findsOneWidget);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -450),
    );
    await tester.pumpAndSettle();
  });

  testWidgets(
    'retry recovers from an error and a failed refresh keeps real data',
    (tester) async {
      var calls = 0;
      final repository = WeatherRepository(
        service: WeatherService(
          apiKey: 'test-key',
          client: MockClient((request) async {
            if (request.url.path == '/geo/1.0/direct') { return http.Response(jsonEncode([{'name': 'Curitiba', 'state': 'PR', 'country': 'BR', 'lat': -25.43, 'lon': -49.27}]), 200); }
            if (request.url.path == '/data/2.5/forecast') { return http.Response('', 503); }
            calls++;
            return calls == 2
                ? http.Response(jsonEncode(responseData()), 200)
                : http.Response('', 503);
          }),
        ),
      );
      await tester.pumpWidget(PreviuApp(repository: repository));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Buscar cidade'));
      await tester.tap(find.text('Buscar cidade'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Curitiba');
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Curitiba, PR'));
      await tester.pumpAndSettle();
      expect(find.text('Tentar novamente'), findsOneWidget);
      expect(find.text('24°'), findsNothing);
      await tester.ensureVisible(find.text('Tentar novamente'));
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(find.text('24°'), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('Atualizar tempo'));
      await tester.tap(find.byTooltip('Atualizar tempo'));
      await tester.pumpAndSettle();
      expect(find.text('24°'), findsOneWidget);
      expect(find.textContaining('Últimos dados disponíveis'), findsOneWidget);
      expect(find.text('PRÉVIA · DADOS ILUSTRATIVOS'), findsNothing);
      expect(calls, 3);
    },
  );
}
