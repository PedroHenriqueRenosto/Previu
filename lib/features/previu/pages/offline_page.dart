import 'package:flutter/material.dart';
import '../../weather/domain/current_weather.dart';
import '../ui.dart';

class OfflinePage extends StatelessWidget {
  const OfflinePage({
    super.key,
    required this.onRetry,
    required this.city,
    this.weather,
    this.message,
  });
  final VoidCallback onRetry;
  final String city;
  final CurrentWeather? weather;
  final String? message;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 68),
      const Icon(Icons.wifi_off_outlined, size: 28),
      const SizedBox(height: 48),
      const Text(
        'Não conseguimos\natualizar o tempo.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 25,
          height: 1.3,
        ),
      ),
      const SizedBox(height: 20),
      Text(
        message ?? 'Confira sua conexão\ne tente novamente.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, color: muted, height: 1.5),
      ),
      const SizedBox(height: 24),
      Center(
        child: FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Tentar novamente'),
        ),
      ),
      const SizedBox(height: 32),
      if (weather != null)
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Caption('Últimos dados disponíveis'),
              const SizedBox(height: 8),
              Text(city, style: const TextStyle(fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${weather!.temperature.round()}°',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  WeatherIcon(conditionId: weather!.conditionId),
                ],
              ),
              Caption(
                'Atualizado às ${weather!.localTime(weather!.updatedAtUtc)}',
              ),
            ],
          ),
        ),
      const SizedBox(height: 24),
      const Text(
        'A previsão será atualizada\nquando houver conexão.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: muted, height: 1.5),
      ),
    ],
  );
}
