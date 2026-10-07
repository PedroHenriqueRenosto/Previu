import '../domain/current_weather.dart';
import '../domain/weather_city.dart';
import 'weather_service.dart';

class WeatherRepository {
  WeatherRepository({required this.service, this.demo = false});

  final WeatherService service;
  final bool demo;
  CurrentWeather? _cached;
  DateTime? _fetchedAt;
  String? _cachedCity;

  Future<CurrentWeather> current({
    bool refresh = false,
    WeatherCity city = WeatherCity.curitiba,
  }) async {
    if (demo) return CurrentWeather.preview();
    if (!refresh &&
        _cached != null &&
        _cachedCity == city.cacheKey &&
        DateTime.now().difference(_fetchedAt!) < const Duration(minutes: 10)) {
      return _cached!;
    }
    final weather = await service.fetchCurrent(city: city);
    _cached = weather;
    _fetchedAt = DateTime.now();
    _cachedCity = city.cacheKey;
    return weather;
  }

  void dispose() => service.dispose();
}
