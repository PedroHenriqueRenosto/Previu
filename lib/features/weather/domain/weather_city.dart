class WeatherCity {
  const WeatherCity({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.state = '',
    this.country = 'BR',
  });
  final String name, state, country;
  final double latitude, longitude;
  String get label => state.isEmpty ? '$name, $country' : '$name, $state';
  String get cacheKey => '$latitude,$longitude';
  static const curitiba = WeatherCity(
    name: 'Curitiba',
    state: 'PR',
    latitude: -25.43,
    longitude: -49.27,
  );
  factory WeatherCity.fromJson(Map<String, dynamic> json) => WeatherCity(
    name:
        (json['local_names'] as Map<String, dynamic>?)?['pt'] as String? ??
        json['name'] as String,
    state: json['state'] as String? ?? '',
    country: json['country'] as String? ?? '',
    latitude: (json['lat'] as num).toDouble(),
    longitude: (json['lon'] as num).toDouble(),
  );
}
