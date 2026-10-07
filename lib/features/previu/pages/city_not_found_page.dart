import 'package:flutter/material.dart';
import '../ui.dart';

class CityNotFoundPage extends StatelessWidget {
  const CityNotFoundPage({
    super.key,
    required this.onClear,
    required this.onLocation,
  });
  final VoidCallback onClear, onLocation;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 75),
      const Icon(Icons.search, size: 28),
      const SizedBox(height: 54),
      const Text(
        'Cidade não\nencontrada',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
      ),
      const SizedBox(height: 20),
      const Text(
        'Confira o nome ou procure\numa cidade próxima.',
        textAlign: TextAlign.center,
        style: TextStyle(color: muted, fontSize: 14, height: 1.5),
      ),
      const SizedBox(height: 40),
      Align(
        alignment: Alignment.centerLeft,
        child: FilledButton(
          onPressed: onClear,
          child: const Text('Limpar busca'),
        ),
      ),
      const SizedBox(height: 12),
      Align(
        alignment: Alignment.centerLeft,
        child: LocationButton(onPressed: onLocation, outlined: true),
      ),
    ],
  );
}
