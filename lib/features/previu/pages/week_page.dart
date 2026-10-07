import 'package:flutter/material.dart';
import '../ui.dart';

class WeekPage extends StatelessWidget {
  const WeekPage({
    super.key,
    required this.city,
    required this.demo,
    required this.onDay,
    this.forecast = const [],
    this.error,
  });
  final String city;
  final bool demo;
  final ValueChanged<ForecastDay> onDay;
  final List<ForecastDay> forecast;
  final String? error;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        demo ? 'Próximos 7 dias' : 'Próximos dias',
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 16),
          const SizedBox(width: 4),
          Expanded(child: Caption(city)),
        ],
      ),
      const SizedBox(height: 12),
      Panel(
        padding: 10,
        child: Caption(
          demo
              ? 'Hoje + os próximos 6 dias'
              : 'Previsão disponível para as próximas 120 horas',
        ),
      ),
      const SizedBox(height: 20),
      const Row(
        children: [
          Expanded(child: Caption('DIA')),
          Expanded(child: Caption('CHUVA')),
          Expanded(child: Caption('MÍN. / MÁX.')),
        ],
      ),
      const SizedBox(height: 8),
      if (demo || forecast.isNotEmpty)
        ...(demo ? ForecastDay.demo : forecast).map(
          (day) => ForecastRow(
            day: day,
            selected: day == ForecastDay.demo.first,
            onTap: () => onDay(day),
          ),
        )
      else
        Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Caption(error ?? 'Carregando previsão dos próximos dias…'),
        ),
      const SizedBox(height: 20),
      const Text(
        'Toque em um dia para ver os detalhes.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: muted),
      ),
      if (demo) const Center(child: Caption('Previsão de demonstração')),
      if (forecast.isNotEmpty && error != null) Caption(error!),
      if (!demo)
        const Caption(
          'Fonte: OpenWeather · previsão de 5 dias em intervalos de 3 horas. As mínimas e máximas resumem os horários disponíveis; o primeiro e o último dia podem estar incompletos.',
        ),
    ],
  );
}
