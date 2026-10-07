import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/current_weather.dart';
import '../domain/weather_city.dart';

class WeatherException implements Exception {
  const WeatherException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
}

class WeatherService {
  WeatherService({required this.apiKey, http.Client? client})
    : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;

  Future<CurrentWeather> fetchCurrent({
    WeatherCity city = WeatherCity.curitiba,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const WeatherException(
        'O serviço de clima ainda não está configurado.',
      );
    }
    final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'lat': city.latitude.toString(),
      'lon': city.longitude.toString(),
      'units': 'metric',
      'lang': 'pt_br',
      'appid': apiKey,
    });
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw WeatherException(switch (response.statusCode) {
          400 => 'Não foi possível consultar esta localidade.',
          401 => 'A chave OpenWeather foi recusada. Confira se ela está ativa em env/local.json e reinicie o aplicativo.',
          404 => 'Localidade não encontrada.',
          429 => 'Muitas consultas por agora. Aguarde um pouco para atualizar.',
          _ =>
            'O serviço de clima está indisponível. Tente novamente mais tarde.',
        }, statusCode: response.statusCode);
      }
      return CurrentWeather.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } on WeatherException {
      rethrow;
    } on TimeoutException {
      throw const WeatherException(
        'A consulta demorou demais. Tente novamente.',
      );
    } on http.ClientException {
      throw const WeatherException(
        'Sem conexão. Verifique sua internet e tente novamente.',
      );
    } on FormatException {
      throw const WeatherException('Não foi possível ler os dados do tempo.');
    } on TypeError {
      throw const WeatherException('O serviço retornou dados incompletos.');
    }
  }

  void dispose() => _client.close();

  Future<dynamic> _get(String path, Map<String, String> parameters) async {
    if (apiKey.trim().isEmpty) {
      throw const WeatherException(
        'Configure sua chave OpenWeather para consultar o tempo.',
      );
    }
    try {
      final response = await _client
          .get(
            Uri.https('api.openweathermap.org', path, {
              ...parameters,
              'appid': apiKey,
            }),
          )
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw WeatherException(switch (response.statusCode) {
          401 => 'Chave OpenWeather inválida ou ainda não ativada.',
          429 => 'Limite de consultas atingido. Aguarde e tente novamente.',
          _ => 'Não foi possível consultar o OpenWeather. Tente novamente.',
        }, statusCode: response.statusCode);
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on WeatherException {
      rethrow;
    } on TimeoutException {
      throw const WeatherException(
        'A consulta demorou demais. Tente novamente.',
      );
    } on http.ClientException {
      throw const WeatherException('Sem conexão. Confira sua internet.');
    } on FormatException {
      throw const WeatherException(
        'Não foi possível ler a resposta do OpenWeather.',
      );
    }
  }

  Future<List<WeatherCity>> searchCities(String query) async {
    if (query.trim().isEmpty) return [];
    final json = await _get('/geo/1.0/direct', {
      'q': query.trim(),
      'limit': '5',
    });
    try {
      return (json as List)
          .map((entry) => WeatherCity.fromJson(entry as Map<String, dynamic>))
          .toList();
    } on TypeError {
      throw const WeatherException('Resposta de cidades incompleta.');
    }
  }

  Future<Map<String, dynamic>> fetchForecast(WeatherCity city) async {
    final json = await _get('/data/2.5/forecast', {
      'lat': city.latitude.toString(),
      'lon': city.longitude.toString(),
      'units': 'metric',
      'lang': 'pt_br',
    });
    if (json is! Map<String, dynamic>) {
      throw const WeatherException('Resposta de previsão incompleta.');
    }
    return json;
  }
}
