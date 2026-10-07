import 'package:flutter/material.dart';
import '../ui.dart';
import '../../weather/domain/current_weather.dart';

class DayDetailPage extends StatelessWidget {
  const DayDetailPage({
    super.key,
    required this.day,
    required this.city,
    this.demo = true,
    this.currentWeather,
    this.onChangeCity,
  });
  final ForecastDay day;
  final String city;
  final bool demo;
  final CurrentWeather? currentWeather;
  final VoidCallback? onChangeCity;
  @override
  Widget build(BuildContext context) {
    final rain = day.condition < 600;
    final periods = demo
        ? [
            ('Manhã', day.min),
            ('Dia', day.max - 2),
            ('Tarde', day.max - 4),
            ('Noite', day.min + 2),
          ]
        : day.periods.map((p) => (
            p.hour == null ? p.label : '${p.hour.toString().padLeft(2, '0')}:00',
            p.temperature.round())).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          demo && day.name == 'Amanhã' ? 'Quinta-feira' :
              demo ? day.name : 'Previsão · ${day.name}',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        Caption('${day.date} · $city'),
        if (onChangeCity != null)
          Align(alignment: Alignment.centerLeft, child: TextButton.icon(
            onPressed: onChangeCity, icon: const Icon(Icons.search),
            label: const Text('Buscar outra cidade'))),
        const SizedBox(height: 20),
        if (currentWeather != null) ...[
          TemperatureCard(
            temperature: '${currentWeather!.temperature.round()}°',
            description: currentWeather!.description,
            condition: currentWeather!.conditionId,
            updated: currentWeather!.localTime(currentWeather!.updatedAtUtc),
            subtitle: 'Sensação ${currentWeather!.feelsLike.round()}°',
          ),
          const SizedBox(height: 16),
        ],
        TemperatureCard(
          detail: true,
          temperature:
              '${demo ? day.max - 2 : day.temperature?.round() ?? day.max}°',
          description: demo
              ? (rain ? 'Chuva leve' : 'Parcialmente nublado')
              : day.description ?? 'Não informado',
          condition: day.condition,
          subtitle: '${!demo && day.forecastHour != null ?
              'Previsto para ${day.forecastHour.toString().padLeft(2, '0')}:00 · ' : ''}'
              'Mín. ${day.min}° · Máx. ${day.max}°',
        ),
        const SizedBox(height: 24),
        const Text(
          'Ao longo do dia',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: periods
              .map(
                (p) => Container(
                  width: 76,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: line),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Caption(p.$1),
                      Text(
                        '${p.$2}°',
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        Metrics(
          rain: true,
          humidity: '${day.rain}%',
          wind: demo
              ? '16 km/h'
              : day.wind == null
              ? '—'
              : '${(day.wind! * 3.6).round()} km/h',
        ),
        const SizedBox(height: 16),
        if (demo)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.wb_twilight_outlined, size: 24),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Caption('Nascer do sol'), Text('06:02')],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Caption('Pôr do sol'), Text('18:20')],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Caption(
          demo
              ? 'Dados de demonstração'
              : 'Fonte: OpenWeather · temperaturas e chuva previstas para os horários disponíveis. A chance de chuva é a maior entre esses horários; as mínimas e máximas podem cobrir apenas parte do dia.',
        ),
      ],
    );
  }
}
