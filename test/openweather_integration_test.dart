import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:previu/features/weather/data/weather_repository.dart';
import 'package:previu/features/weather/data/weather_service.dart';
import 'package:previu/features/weather/domain/weather_city.dart';
import 'package:previu/features/weather/domain/forecast_day.dart';
import 'weather_test.dart' show responseData;

void main() {
  test('geocoding returns API coordinates and current cache is separated by city', () async {
    var currentCalls = 0;
    final service = WeatherService(apiKey: 'test-key', client: MockClient((request) async {
      if (request.url.path == '/geo/1.0/direct') {
        expect(request.url.queryParameters['q'], 'Florianópolis');
        return http.Response(jsonEncode([{'name':'Florianópolis', 'lat':-27.59, 'lon':-48.55, 'state':'SC', 'country':'BR'}]), 200, encoding: utf8);
      }
      currentCalls++;
      final json = responseData();
      json['main']['temp'] = request.url.queryParameters['lat'] == '-27.59' ? 19 : 24;
      return http.Response(jsonEncode(json), 200);
    }));
    final repo = WeatherRepository(service: service);
    addTearDown(repo.dispose);
    expect((await repo.current()).temperature, 24);
    final found = await service.searchCities('Florianópolis');
    expect(found.single.longitude, -48.55);
    expect((await repo.current(city: found.single)).temperature, 19);
    expect((await repo.current(city: found.single)).temperature, 19);
    expect(currentCalls, 2);
  });

  test('forecast aggregates available slots using city time and never invents days', () {
    Map<String,dynamic> slot(int hour, int temp, double rain) => {
      'dt':DateTime.utc(2026,10,7,hour).millisecondsSinceEpoch ~/ 1000,
      'main': {'temp':temp,'temp_min':temp-1,'temp_max':temp+1},
      'weather':[{'id':500,'description':'chuva leve'}], 'wind':{'speed':2.5}, 'pop':rain,
    };
    final data = {'city':{'timezone':-10800}, 'list':[slot(0,20,0.1),slot(12,22,0.6),slot(15,25,0.3)]};
    final days = ForecastDay.fromOpenWeather(data, nowUtc:DateTime.utc(2026,10,6,12));
    expect(days.length, 2);
    expect(days.first.name,'Hoje');
    expect(days.last.name,'Amanhã');
    expect(days.last.rain,60);
    expect(days.last.min,21);
    expect(days.last.max,26);
    expect(days.last.temperature,25);
    expect(days.first.periods.single.label,'Noite');
    expect(days.last.periods.map((p)=>p.label), ['Manhã','Dia']);
    expect(days.last.wind,2.5);
  });

  test('empty geocoding results are distinct from authentication failures', () async {
    final empty = WeatherService(apiKey:'test-key',client:MockClient((_)async=>http.Response('[]',200)));
    addTearDown(empty.dispose);
    expect(await empty.searchCities('Abcxyz'),isEmpty);
    final denied = WeatherService(apiKey:'bad-key',client:MockClient((_)async=>http.Response('private body',401)));
    addTearDown(denied.dispose);
    await expectLater(denied.searchCities('Curitiba'), throwsA(isA<WeatherException>().having((e)=>e.statusCode,'status',401)));
  });

  test('forecast requests the same selected coordinates as current weather', () async {
    final service = WeatherService(apiKey:'test-key',client:MockClient((request)async {
      expect(request.url.path,'/data/2.5/forecast');
      expect(request.url.queryParameters['lat'],'-25.43');
      expect(request.url.queryParameters['units'],'metric');
      expect(request.url.queryParameters['lang'],'pt_br');
      return http.Response('{"city":{"timezone":-10800},"list":[]}',200);
    }));
    addTearDown(service.dispose);
    expect((await service.fetchForecast(WeatherCity.curitiba))['list'],isEmpty);
  });
}
