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
    this.forecast = const [],
    this.forecastError,
  });
  final String city;
  final CurrentWeather weather;
  final bool demo;
  final VoidCallback onWeek, onRefresh;
  final ValueChanged<ForecastDay> onDay;
  final List<ForecastDay> forecast;
  final String? forecastError;
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
          Expanded(
            child: Text(
              demo ? 'Próximos 7 dias' : 'Próximos dias',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
            ),
          ),
          TextButton(onPressed: onWeek, child: const Text('Ver todos')),
        ],
      ),
      if (demo || forecast.isNotEmpty)
        ...(demo ? ForecastDay.demo : forecast)
            .take(2)
            .map(
              (day) => ForecastRow(
                day: day,
                selected: day == ForecastDay.demo.first,
                onTap: () => onDay(day),
              ),
            )
      else
        Caption(forecastError ?? 'Carregando previsão dos próximos dias…'),
      if (!demo) ...[
        const SizedBox(height: 16),
        Panel(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Caption('Nascer do sol'),
                    Text(weather.localTime(weather.sunriseUtc)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Caption('Pôr do sol'),
                    Text(weather.localTime(weather.sunsetUtc)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 20),
      Caption(demo ? 'PRÉVIA · DADOS ILUSTRATIVOS' : 'Fonte: OpenWeather'),
      if (!demo) const Caption('Atualização automática a cada 5 minutos enquanto esta tela estiver aberta. O horário acima corresponde à medição recebida da API.'),
      if (forecast.isNotEmpty && forecastError != null) Caption(forecastError!),
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
