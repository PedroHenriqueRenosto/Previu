import 'package:flutter/material.dart';
import '../../weather/domain/current_weather.dart';
import '../ui.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({
    super.key,
    required this.city,
    required this.weather,
    required this.demo,
    required this.onWeek,
    required this.onDay,
    required this.onRefresh,
  });
  final String city;
  final CurrentWeather weather;
  final bool demo;
  final VoidCallback onWeek, onRefresh;
  final ValueChanged<ForecastDay> onDay;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 20),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              city,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
            ),
          ),
          IconButton(
            tooltip: 'Atualizar tempo',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, size: 20),
          ),
        ],
      ),
      Caption(demo ? 'Quarta-feira, 30 de setembro' : _weatherDate(weather)),
      const SizedBox(height: 20),
      TemperatureCard(
        temperature: '${weather.temperature.round()}°',
        description: weather.description,
        condition: weather.conditionId,
        updated: demo ? '09:40' : weather.localTime(weather.updatedAtUtc),
        subtitle:
            'Sensação ${weather.feelsLike.round()}°${demo ? ' · Mín. 18° · Máx. 27°' : ''}',
      ),
      const SizedBox(height: 12),
      Metrics(
        humidity: weather.humidity == null ? '—' : '${weather.humidity}%',
        wind: weather.windSpeed == null
            ? '—'
            : '${(weather.windSpeed! * 3.6).round()} km/h',
      ),
      const SizedBox(height: 18),
      Row(
        children: [
          const Expanded(
            child: Text(
              'Próximos 7 dias',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
            ),
          ),
          TextButton(onPressed: onWeek, child: const Text('Ver todos')),
        ],
      ),
      if (demo)
        ...ForecastDay.demo
            .take(2)
            .map(
              (day) => ForecastRow(
                day: day,
                selected: day == ForecastDay.demo.first,
                onTap: () => onDay(day),
              ),
            )
      else
        const Caption(
          'A previsão diária está disponível no modo de demonstração.',
        ),
      const SizedBox(height: 20),
      Caption(demo ? 'PRÉVIA · DADOS ILUSTRATIVOS' : 'Fonte: OpenWeather'),
    ],
  );
}

String _weatherDate(CurrentWeather weather) {
  final date = weather.updatedAtUtc.add(
    Duration(seconds: weather.utcOffsetSeconds),
  );
  const days = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];
  const months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];
  return '${days[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
}
