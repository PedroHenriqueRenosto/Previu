import 'package:flutter/material.dart';
import '../ui.dart';

class WeekPage extends StatelessWidget {
  const WeekPage({
    super.key,
    required this.city,
    required this.demo,
    required this.onDay,
  });
  final String city;
  final bool demo;
  final ValueChanged<ForecastDay> onDay;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Próximos 7 dias',
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
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
      const Panel(padding: 10, child: Caption('Hoje + os próximos 6 dias')),
      const SizedBox(height: 20),
      const Row(
        children: [
          Expanded(child: Caption('DIA')),
          Expanded(child: Caption('CHUVA')),
          Expanded(child: Caption('MÍN. / MÁX.')),
        ],
      ),
      const SizedBox(height: 8),
      if (demo)
        ...ForecastDay.demo.map(
          (day) => ForecastRow(
            day: day,
            selected: day == ForecastDay.demo.first,
            onTap: () => onDay(day),
          ),
        )
      else
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Caption(
            'A integração de previsão diária ainda não está configurada. Use a prévia do layout no VS Code para explorar esta tela.',
          ),
        ),
      const SizedBox(height: 20),
      const Text(
        'Toque em um dia para ver os detalhes.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: muted),
      ),
      if (demo) const Center(child: Caption('Previsão de demonstração')),
    ],
  );
}
