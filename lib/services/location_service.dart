import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static bool _isLocationServiceEnabled = false;
  static LocationPermission? _permission;

  /// Check if location services are enabled and permissions are granted
  static Future<bool> isLocationAvailable() async {
    try {
      // Check if location services are enabled
      _isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_isLocationServiceEnabled) {
        return false;
      }

      // Check location permissions
      _permission = await Geolocator.checkPermission();
      if (_permission == LocationPermission.denied) {
        _permission = await Geolocator.requestPermission();
        if (_permission == LocationPermission.denied) {
          return false;
        }
      }

      if (_permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      print('[LocationService] Error checking location availability: $e');
      return false;
    }
  }

  /// Get current position
  static Future<Position?> getCurrentPosition() async {
    try {
      final bool isAvailable = await isLocationAvailable();
      if (!isAvailable) {
        print('[LocationService] Location not available');
        return null;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print(
        '[LocationService] Current position: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      print('[LocationService] Error getting current position: $e');
      return null;
    }
  }

  /// Get location coordinates as a formatted string
  static Future<String?> getLocationString() async {
    try {
      final Position? position = await getCurrentPosition();
      if (position != null) {
        return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      }
      return null;
    } catch (e) {
      print('[LocationService] Error getting location string: $e');
      return null;
    }
  }

  /// Request location permissions
  static Future<bool> requestLocationPermission() async {
    try {
      final Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.locationWhenInUse,
      ].request();

      final bool locationGranted =
          statuses[Permission.location]?.isGranted ?? false;
      final bool locationWhenInUseGranted =
          statuses[Permission.locationWhenInUse]?.isGranted ?? false;

      return locationGranted || locationWhenInUseGranted;
    } catch (e) {
      print('[LocationService] Error requesting location permission: $e');
      return false;
    }
  }

  /// Get distance between two coordinates in kilometers
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert to kilometers
  }

  /// Check if location services are enabled
  static bool get isLocationServiceEnabled => _isLocationServiceEnabled;

  /// Get current permission status
  static LocationPermission? get permission => _permission;
}
