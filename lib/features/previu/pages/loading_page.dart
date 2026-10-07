import 'package:flutter/material.dart';
import '../ui.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});
  Widget bar(double width, double height) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: line,
        borderRadius: BorderRadius.circular(6),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: 'Carregando previsão',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        bar(160, 16),
        const SizedBox(height: 12),
        bar(220, 12),
        const SizedBox(height: 24),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bar(70, 12),
              const SizedBox(height: 24),
              bar(110, 68),
              const SizedBox(height: 24),
              bar(210, 15),
              const SizedBox(height: 10),
              bar(150, 12),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: Panel(child: bar(80, 45))),
            const SizedBox(width: 12),
            Expanded(child: Panel(child: bar(80, 45))),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Center(child: Caption('Carregando previsão…')),
        ),
        Panel(child: bar(230, 15)),
        const SizedBox(height: 12),
        Panel(child: bar(230, 15)),
      ],
    ),
  );
}
