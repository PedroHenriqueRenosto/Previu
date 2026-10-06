import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/current_weather.dart';

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

  Future<CurrentWeather> fetchCurrent() async {
    if (apiKey.trim().isEmpty) {
      throw const WeatherException(
        'O serviço de clima ainda não está configurado.',
      );
    }
    final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'lat': '-25.43',
      'lon': '-49.27',
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
          401 => 'O serviço de clima não autorizou a consulta.',
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
}
