import 'package:flutter/material.dart';
import '../weather/presentation/widgets/weather_icon.dart';
export '../weather/presentation/widgets/weather_icon.dart';

const ink = Color(0xFF27292C);
const muted = Color(0xFF757A82);
const panel = Color(0xFFF3F3F4);
const line = Color(0xFFE3E5E8);

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = 20});
  final Widget child;
  final double padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
}

class Caption extends StatelessWidget {
  const Caption(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(color: muted, fontSize: 12, height: 1.5),
  );
}

class LocationButton extends StatelessWidget {
  const LocationButton({
    super.key,
    required this.onPressed,
    this.outlined = false,
  });
  final VoidCallback onPressed;
  final bool outlined;
  @override
  Widget build(BuildContext context) => outlined
      ? OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.my_location, size: 18),
          label: const Text('Usar minha localização'),
        )
      : FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.my_location, size: 18),
          label: const Text('Usar minha localização'),
        );
}

class ForecastDay {
  const ForecastDay(
    this.name,
    this.date,
    this.condition,
    this.rain,
    this.min,
    this.max,
  );
  final String name, date;
  final int condition, rain, min, max;
  static const demo = [
    ForecastDay('Hoje', 'Qua, 30 set', 802, 40, 18, 27),
    ForecastDay('Amanhã', 'Qui, 01 out', 500, 70, 17, 26),
    ForecastDay('Sexta', '02 out', 803, 56, 18, 24),
    ForecastDay('Sábado', '03 out', 800, 10, 16, 28),
    ForecastDay('Domingo', '04 out', 800, 10, 18, 29),
    ForecastDay('Segunda', '05 out', 802, 28, 19, 27),
    ForecastDay('Terça', '06 out', 500, 80, 17, 23),
  ];
}

class ForecastRow extends StatelessWidget {
  const ForecastRow({
    super.key,
    required this.day,
    required this.onTap,
    this.selected = false,
  });
  final ForecastDay day;
  final VoidCallback onTap;
  final bool selected;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? panel : Colors.white,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Caption(day.date),
                ],
              ),
            ),
            WeatherIcon(conditionId: day.condition, size: 24),
            Expanded(
              flex: 2,
              child: Text(
                '${day.rain}%',
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ),
            Text(
              '${day.min}° / ${day.max}°',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    ),
  );
}

class Metrics extends StatelessWidget {
  const Metrics({
    super.key,
    this.humidity = '68%',
    this.wind = '14 km/h',
    this.rain = false,
  });
  final String humidity, wind;
  final bool rain;
  Widget metric(IconData icon, String label, String value) => Expanded(
    child: Panel(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: muted),
              const SizedBox(width: 5),
              Flexible(child: Caption(label)),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => Row(
    children: [
      metric(
        Icons.water_drop_outlined,
        rain ? 'Chance de chuva' : 'Umidade',
        humidity,
      ),
      const SizedBox(width: 12),
      metric(Icons.air, 'Vento', wind),
    ],
  );
}

class TemperatureCard extends StatelessWidget {
  const TemperatureCard({
    super.key,
    this.temperature = '24°',
    this.description = 'Parcialmente nublado',
    this.condition = 802,
    this.detail = false,
    this.subtitle = 'Sensação 25° · Mín. 18° · Máx. 27°',
    this.updated = '09:40',
  });
  final String temperature, description, subtitle, updated;
  final int condition;
  final bool detail;
  @override
  Widget build(BuildContext context) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Caption(detail ? 'PREVISÃO DO DIA' : 'AGORA'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                temperature,
                style: const TextStyle(
                  fontSize: 64,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -2,
                ),
              ),
            ),
            WeatherIcon(conditionId: condition, size: 34),
            const SizedBox(width: 18),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Caption(subtitle),
        if (!detail) Caption('Atualizado às $updated'),
      ],
    ),
  );
}
