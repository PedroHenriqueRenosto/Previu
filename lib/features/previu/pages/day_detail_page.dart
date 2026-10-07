import 'package:flutter/material.dart';
import '../ui.dart';

class DayDetailPage extends StatelessWidget {
  const DayDetailPage({super.key, required this.day, required this.city});
  final ForecastDay day;
  final String city;
  @override
  Widget build(BuildContext context) {
    final rain = day.condition < 600;
    final periods = [
      ('Manhã', day.min),
      ('Dia', day.max - 2),
      ('Tarde', day.max - 4),
      ('Noite', day.min + 2),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          day.name == 'Amanhã' ? 'Quinta-feira' : day.name,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        Caption('${day.date} · $city'),
        const SizedBox(height: 20),
        TemperatureCard(
          detail: true,
          temperature: '${day.max - 2}°',
          description: rain ? 'Chuva leve' : 'Parcialmente nublado',
          condition: day.condition,
          subtitle: 'Mín. ${day.min}° · Máx. ${day.max}°',
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
        Metrics(rain: true, humidity: '${day.rain}%', wind: '16 km/h'),
        const SizedBox(height: 16),
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
        const Caption('Dados de demonstração'),
      ],
    );
  }
}
