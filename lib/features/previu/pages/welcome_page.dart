import 'package:flutter/material.dart';
import '../ui.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
    required this.onSearch,
    required this.onLocation,
  });
  final VoidCallback onSearch, onLocation;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: size.maxHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const WeatherIcon(size: 32),
              const SizedBox(height: 72),
              const Text(
                'Previu',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Veja o tempo\nna sua cidade.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 20),
              const Caption(
                'A temperatura de agora e a previsão\ndos próximos dias, em um só lugar.',
              ),
              const SizedBox(height: 44),
              LocationButton(onPressed: onLocation),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onSearch,
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Buscar cidade'),
              ),
              const SizedBox(height: 32),
              const Text(
                'Você também pode escolher uma cidade\nsem permitir acesso à localização.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
