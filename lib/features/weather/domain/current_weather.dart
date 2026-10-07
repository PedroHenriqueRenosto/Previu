class CurrentWeather {
  const CurrentWeather({
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.conditionId,
    required this.isNight,
    required this.updatedAtUtc,
    required this.utcOffsetSeconds,
    this.humidity,
    this.windSpeed,
    this.pressure,
    this.visibility,
    this.sunriseUtc,
    this.sunsetUtc,
    this.minimum,
    this.maximum,
  });

  final double temperature;
  final double feelsLike;
  final String description;
  final int conditionId;
  final bool isNight;
  final DateTime updatedAtUtc;
  final int utcOffsetSeconds;
  final int? humidity;
  final double? windSpeed;
  final double? pressure;
  final double? visibility;
  final DateTime? sunriseUtc;
  final DateTime? sunsetUtc;
  final double? minimum, maximum;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final conditions = json['weather'] as List<dynamic>? ?? [];
    final condition = conditions.isEmpty
        ? <String, dynamic>{}
        : conditions.first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>?;
    final sys = json['sys'] as Map<String, dynamic>?;
    return CurrentWeather(
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      minimum: (main['temp_min'] as num?)?.toDouble(),
      maximum: (main['temp_max'] as num?)?.toDouble(),
      description: condition['description'] as String? ?? 'Não informado',
      conditionId: (condition['id'] as num?)?.toInt() ?? 0,
      isNight: (condition['icon'] as String? ?? '').endsWith('n'),
      updatedAtUtc: _instant(json['dt'] as num)!,
      utcOffsetSeconds: (json['timezone'] as num).toInt(),
      humidity: (main['humidity'] as num?)?.toInt(),
      windSpeed: (wind?['speed'] as num?)?.toDouble(),
      pressure: (main['pressure'] as num?)?.toDouble(),
      visibility: (json['visibility'] as num?)?.toDouble(),
      sunriseUtc: _instant(sys?['sunrise'] as num?),
      sunsetUtc: _instant(sys?['sunset'] as num?),
    );
  }

  static DateTime? _instant(num? value) => value == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000, isUtc: true);

  // The current response provides the offset for these instants. Forecasts
  // will need a named timezone to handle future daylight-saving transitions.
  String localTime(DateTime? instant) {
    if (instant == null) return 'Não informado';
    final local = instant.toUtc().add(Duration(seconds: utcOffsetSeconds));
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  static CurrentWeather preview() => CurrentWeather(
    temperature: 24,
    feelsLike: 25,
    description: 'Parcialmente nublado',
    conditionId: 802,
    isNight: false,
    updatedAtUtc: DateTime.utc(2026, 10, 5, 12, 40),
    utcOffsetSeconds: -10800,
    humidity: 68,
    windSpeed: 12 / 3.6,
    pressure: 1015,
    visibility: 10000,
    sunriseUtc: DateTime.utc(2026, 10, 5, 9, 2),
    sunsetUtc: DateTime.utc(2026, 10, 5, 21, 21),
  );
}
