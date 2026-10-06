import '../domain/current_weather.dart';
import 'weather_service.dart';

class WeatherRepository {
  WeatherRepository({required this.service, this.demo = false});

  final WeatherService service;
  final bool demo;
  CurrentWeather? _cached;
  DateTime? _fetchedAt;

  Future<CurrentWeather> current({bool refresh = false}) async {
    if (demo) return CurrentWeather.preview();
    if (!refresh &&
        _cached != null &&
        DateTime.now().difference(_fetchedAt!) < const Duration(minutes: 10)) {
      return _cached!;
    }
    final weather = await service.fetchCurrent();
    _cached = weather;
    _fetchedAt = DateTime.now();
    return weather;
  }

  void dispose() => service.dispose();
}
