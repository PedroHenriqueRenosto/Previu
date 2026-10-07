class ForecastPeriod {
  const ForecastPeriod(this.label, this.temperature);
  final String label;
  final double temperature;
}

class ForecastDay {
  const ForecastDay(
    this.name,
    this.date,
    this.condition,
    this.rain,
    this.min,
    this.max, {
    this.description,
    this.temperature,
    this.wind,
    this.periods = const [],
    this.localDate,
  });
  final String name, date;
  final int condition, rain, min, max;
  final String? description;
  final double? temperature, wind;
  final List<ForecastPeriod> periods;
  final DateTime? localDate;
  static const demo = [
    ForecastDay('Hoje', 'Qua, 30 set', 802, 40, 18, 27),
    ForecastDay('Amanhã', 'Qui, 01 out', 500, 70, 17, 26),
    ForecastDay('Sexta', '02 out', 803, 56, 18, 24),
    ForecastDay('Sábado', '03 out', 800, 10, 16, 28),
    ForecastDay('Domingo', '04 out', 800, 10, 18, 29),
    ForecastDay('Segunda', '05 out', 802, 28, 19, 27),
    ForecastDay('Terça', '06 out', 500, 80, 17, 23),
  ];

  static List<ForecastDay> fromOpenWeather(
    Map<String, dynamic> json, {
    DateTime? nowUtc,
  }) {
    final offset = (json['city']['timezone'] as num).toInt();
    final localNow = (nowUtc ?? DateTime.now().toUtc()).add(
      Duration(seconds: offset),
    );
    final today = DateTime.utc(localNow.year, localNow.month, localNow.day);
    final groups = <DateTime, List<Map<String, dynamic>>>{};
    for (final raw in json['list'] as List) {
      final entry = raw as Map<String, dynamic>;
      final local = DateTime.fromMillisecondsSinceEpoch(
        (entry['dt'] as num).toInt() * 1000,
        isUtc: true,
      ).add(Duration(seconds: offset));
      final date = DateTime.utc(local.year, local.month, local.day);
      if (date.isBefore(today)) continue;
      groups.putIfAbsent(date, () => []).add({...entry, '_hour': local.hour});
    }
    final dates = groups.keys.toList()..sort();
    const days = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];
    const months = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];
    return dates.map((date) {
      final entries = groups[date]!;
      final representative = entries.reduce(
        (a, b) =>
            ((a['_hour'] as int) - 12).abs() <= ((b['_hour'] as int) - 12).abs()
            ? a
            : b,
      );
      final condition =
          (representative['weather'] as List).first as Map<String, dynamic>;
      double low = double.infinity, high = double.negativeInfinity, rain = 0;
      for (final entry in entries) {
        final main = entry['main'] as Map<String, dynamic>;
        final min = (main['temp_min'] as num? ?? main['temp'] as num)
            .toDouble();
        final max = (main['temp_max'] as num? ?? main['temp'] as num)
            .toDouble();
        if (min < low) low = min;
        if (max > high) high = max;
        final probability = (entry['pop'] as num? ?? 0).toDouble();
        if (probability > rain) rain = probability;
      }
      final periods = <ForecastPeriod>[];
      for (final period in [
        ('Manhã', 6, 12),
        ('Dia', 12, 15),
        ('Tarde', 15, 18),
        ('Noite', 18, 24),
      ]) {
        final slots = entries
            .where(
              (e) =>
                  (e['_hour'] as int) >= period.$2 &&
                  (e['_hour'] as int) < period.$3,
            )
            .toList();
        if (slots.isNotEmpty)
          periods.add(
            ForecastPeriod(
              period.$1,
              (slots.first['main']['temp'] as num).toDouble(),
            ),
          );
      }
      final diff = date.difference(today).inDays;
      return ForecastDay(
        diff == 0
            ? 'Hoje'
            : diff == 1
            ? 'Amanhã'
            : days[date.weekday - 1],
        '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}',
        (condition['id'] as num).toInt(),
        (rain * 100).round(),
        low.round(),
        high.round(),
        description: condition['description'] as String?,
        temperature: (representative['main']['temp'] as num).toDouble(),
        wind: (representative['wind']?['speed'] as num?)?.toDouble(),
        periods: periods,
        localDate: date,
      );
    }).toList();
  }
}
