import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'features/weather/data/weather_repository.dart';
import 'features/weather/data/weather_service.dart';
import 'features/previu/previu_flow.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: bgTop,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  const weatherApiKey = 'f2abe19f599a1909254107123426632f';

  runApp(
    PreviuApp(
      repository: WeatherRepository(
        service: WeatherService(
          apiKey: weatherApiKey,
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
          primary: accentStrong,
          onPrimary: Colors.white,
          primaryContainer: accentSoft,
          onPrimaryContainer: accentInk,
          secondary: accentStrong,
          onSecondary: Colors.white,
          secondaryContainer: accentSoft,
          onSecondaryContainer: accentInk,
          surface: bgTop,
          onSurface: ink,
          onSurfaceVariant: muted,
          outline: accentStrong,
          outlineVariant: line,
        ),
        scaffoldBackgroundColor: bgTop,
        fontFamily: 'Roboto',
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: ink,
          displayColor: ink,
        ),
        iconTheme: const IconThemeData(color: accentStrong),
        appBarTheme: const AppBarTheme(
          foregroundColor: accentStrong,
          iconTheme: IconThemeData(color: accentStrong),
          actionsIconTheme: IconThemeData(color: accentStrong),
        ),
        listTileTheme: const ListTileThemeData(iconColor: accentStrong),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: accentSoft,
          iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? accentStrong : muted,
          )),
          labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
            color: states.contains(WidgetState.selected) ? accentStrong : muted,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          )),
        ),
        inputDecorationTheme: InputDecorationTheme(
          prefixIconColor: accentStrong,
          suffixIconColor: accentStrong,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accentStrong, width: 2),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: accentStrong,
            side: const BorderSide(color: accentStrong),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: accent,
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
