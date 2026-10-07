import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'features/weather/data/weather_repository.dart';
import 'features/weather/data/weather_service.dart';
import 'features/previu/previu_flow.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    PreviuApp(
      repository: WeatherRepository(
        service: WeatherService(
          apiKey: const String.fromEnvironment('OPENWEATHER_API_KEY'),
        ),
        demo: const bool.fromEnvironment('DEMO_MODE'),
      ),
    ),
  );
}

class PreviuApp extends StatelessWidget {
  const PreviuApp({super.key, required this.repository});

  final WeatherRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Previu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF27292C),
          onPrimary: Colors.white,
          secondary: Color(0xFF696D74),
          surface: Colors.white,
          onSurface: Color(0xFF27292C),
          outline: Color(0xFFDDE0E4),
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: const Color(0xFF27292C),
          displayColor: const Color(0xFF27292C),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF27292C),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: PreviuFlow(repository: repository),
    );
  }
}
