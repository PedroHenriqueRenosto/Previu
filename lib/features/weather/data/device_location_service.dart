import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'weather_service.dart';

class DeviceLocationService {
  Future<Position> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const WeatherException('Ative a localização do dispositivo ou busque uma cidade.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const WeatherException('Permita a localização nas configurações do navegador ou do aplicativo. Você também pode buscar uma cidade.');
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 25),
        ),
      );
    } on TimeoutException {
      throw const WeatherException('Não conseguimos obter sua localização a tempo. Tente novamente ou busque uma cidade.');
    } on PermissionDeniedException {
      throw const WeatherException('A localização foi bloqueada. Permita o acesso ou busque uma cidade.');
    } on LocationServiceDisabledException {
      throw const WeatherException('Ative a localização do dispositivo ou busque uma cidade.');
    }
  }
}
