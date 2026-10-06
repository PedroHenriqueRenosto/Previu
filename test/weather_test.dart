import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:previu/features/weather/data/weather_repository.dart';
import 'package:previu/features/weather/data/weather_service.dart';
import 'package:previu/features/weather/domain/current_weather.dart';

Map<String, dynamic> responseData() => {
  'main': {'temp': 24, 'feels_like': 25.3, 'humidity': 68, 'pressure': 1015},
  'weather': [
    {'id': 802, 'description': 'parcialmente nublado', 'icon': '03d'},
  ],
  'dt': 1791204000,
  'timezone': -10800,
  'wind': {'speed': 3.3},
  'visibility': 10000,
  'sys': {'sunrise': 1791190920, 'sunset': 1791235260},
};

void main() {
  test(
    'accepts integer and decimal JSON numbers and preserves missing data',
    () {
      final json = responseData()
        ..remove('wind')
        ..remove('visibility')
        ..remove('sys');
      final weather = CurrentWeather.fromJson(json);
      expect(weather.temperature, 24.0);
      expect(weather.feelsLike, 25.3);
      expect(weather.windSpeed, isNull);
      expect(weather.visibility, isNull);
      expect(weather.sunriseUtc, isNull);
      expect(weather.localTime(null), 'Não informado');
    },
  );

  test('uses the location offset instead of the device timezone', () {
    final weather = CurrentWeather.fromJson(responseData());
    expect(weather.updatedAtUtc.isUtc, isTrue);
    expect(weather.localTime(DateTime.utc(2026, 10, 5, 2, 5)), '23:05');
  });

  test(
    'requests coordinates, metric units and Portuguese over HTTPS',
    () async {
      final service = WeatherService(
        apiKey: 'test-key',
        client: MockClient((request) async {
          expect(request.url.scheme, 'https');
          expect(request.url.host, 'api.openweathermap.org');
          expect(request.url.path, '/data/2.5/weather');
          expect(request.url.queryParameters['units'], 'metric');
          expect(request.url.queryParameters['lang'], 'pt_br');
          expect(request.url.queryParameters['lat'], '-25.43');
          expect(request.url.queryParameters['appid'], 'test-key');
          return http.Response(jsonEncode(responseData()), 200);
        }),
      );
      addTearDown(service.dispose);
      expect((await service.fetchCurrent()).temperature, 24);
    },
  );

  test(
    'does not automatically retry an unauthorized request or expose its body',
    () async {
      var calls = 0;
      final service = WeatherService(
        apiKey: 'test-key',
        client: MockClient((_) async {
          calls++;
          return http.Response('private server response', 401);
        }),
      );
      addTearDown(service.dispose);
      await expectLater(
        service.fetchCurrent(),
        throwsA(
          isA<WeatherException>()
              .having((e) => e.statusCode, 'status', 401)
              .having(
                (e) => e.message,
                'safe message',
                isNot(contains('private')),
              ),
        ),
      );
      expect(calls, 1);
    },
  );

  test('keeps the last successful cache when refreshing fails', () async {
    var calls = 0;
    final repository = WeatherRepository(
      service: WeatherService(
        apiKey: 'test-key',
        client: MockClient((_) async {
          calls++;
          return calls == 1
              ? http.Response(jsonEncode(responseData()), 200)
              : http.Response('', 503);
        }),
      ),
    );
    addTearDown(repository.dispose);
    final first = await repository.current();
    expect(await repository.current(), same(first));
    expect(calls, 1);
    await expectLater(
      repository.current(refresh: true),
      throwsA(isA<WeatherException>()),
    );
    expect(await repository.current(), same(first));
    expect(calls, 2);
  });
}
