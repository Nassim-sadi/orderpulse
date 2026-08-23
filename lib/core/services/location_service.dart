import 'package:geolocator/geolocator.dart';

class GpsFix {
  const GpsFix({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
}

class GpsPermissionException implements Exception {
  GpsPermissionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GpsServiceDisabledException implements Exception {
  @override
  String toString() => 'Location services are disabled. Enable GPS and retry.';
}

class LocationService {
  Future<GpsFix> getCurrentPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw GpsPermissionException('Location permission was denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw GpsPermissionException(
          'Location permission is permanently denied. Enable it from settings.');
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw GpsServiceDisabledException();
    }
    final Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } catch (_) {
      throw GpsServiceDisabledException();
    }
    return GpsFix(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
    );
  }
}
