import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  static const String _ipApiUrl = 'http://ip-api.com/json';
  static const String _ipifyApiUrl = 'https://api.ipify.org?format=json';

  /// Get device location using GPS with highest practical accuracy and fallbacks
  static Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Try to prompt user to enable location services
        try {
          await Geolocator.openLocationSettings();
        } catch (_) {}
        // Re-check after prompt
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Location permissions are denied
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Location permissions are permanently denied
        return null;
      }

      // Try high-accuracy first with a reasonable timeout
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (_) {
        // If high-accuracy fails (e.g., GPS cold start), fall back to last known
        position = await Geolocator.getLastKnownPosition();
        // As a secondary attempt, request a quick, lower-accuracy fix
        position ??= await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      }

      final Position pos = position;

      return {
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'accuracy': pos.accuracy,
        'altitude': pos.altitude,
        'heading': pos.heading,
        'speed': pos.speed,
        'timestamp': pos.timestamp.toIso8601String(),
      };
    } catch (e) {
      // Error getting location: $e
      return null;
    }
  }

  /// Returns a short human-readable location string, e.g. "City, Country"
  static Future<String?> getLocationString() async {
    try {
      final gps = await getCurrentLocation();
      final ipLoc = await getLocationFromIP();

      final String? city = ipLoc != null ? ipLoc['city'] as String? : null;
      final String? country = ipLoc != null
          ? ipLoc['country'] as String?
          : null;

      if (city != null && country != null) {
        return '$city, $country';
      }

      if (gps != null) {
        final lat = gps['latitude'];
        final lon = gps['longitude'];
        if (lat != null && lon != null) {
          return '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
        }
      }
    } catch (_) {}
    return null;
  }

  /// Whether any location source is available (GPS service or IP-based)
  static Future<bool> isLocationAvailable() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) return true;

      final ipLoc = await getLocationFromIP();
      return ipLoc != null;
    } catch (_) {
      return false;
    }
  }

  /// Get location information from IP address
  static Future<Map<String, dynamic>?> getLocationFromIP() async {
    try {
      final response = await http
          .get(Uri.parse(_ipApiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'ip': data['query'],
          'country': data['country'],
          'countryCode': data['countryCode'],
          'region': data['region'],
          'regionName': data['regionName'],
          'city': data['city'],
          'zip': data['zip'],
          'latitude': data['lat'],
          'longitude': data['lon'],
          'timezone': data['timezone'],
          'isp': data['isp'],
          'org': data['org'],
          'as': data['as'],
        };
      }
    } catch (e) {
      // Error getting IP location: $e
    }
    return null;
  }

  /// Get public IP address
  static Future<String?> getPublicIP() async {
    try {
      final response = await http
          .get(Uri.parse(_ipifyApiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ip'];
      }
    } catch (e) {
      // Error getting public IP: $e
    }
    return null;
  }

  /// Get device information
  static Map<String, String> getDeviceInfo() {
    return {
      'deviceType': _getDeviceType(),
      'deviceOs': _getDeviceOS(),
      'browser': _getBrowser(),
      'userAgent': _getUserAgent(),
    };
  }

  static String _getDeviceType() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid || Platform.isIOS) {
      return 'mobile';
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return 'desktop';
    }
    return 'unknown';
  }

  static String _getDeviceOS() {
    if (kIsWeb) {
      return 'Web';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    }
    return 'Unknown';
  }

  static String _getBrowser() {
    if (kIsWeb) {
      // This would need to be implemented with a web-specific package
      return 'Web Browser';
    }
    return 'Unknown';
  }

  static String _getUserAgent() {
    if (kIsWeb) {
      // This would need to be implemented with a web-specific package
      return 'Web User Agent';
    }
    return 'Unknown';
  }

  /// Get comprehensive location data for login tracking
  static Future<Map<String, dynamic>> getLoginLocationData() async {
    final Map<String, dynamic> locationData = {};

    // Get device info
    locationData.addAll(getDeviceInfo());

    // Try to get GPS location first
    final gpsLocation = await getCurrentLocation();
    if (gpsLocation != null) {
      locationData['latitude'] = gpsLocation['latitude'];
      locationData['longitude'] = gpsLocation['longitude'];
      locationData['locationSource'] = 'gps';
    }

    // Get IP-based location as fallback or additional info
    final ipLocation = await getLocationFromIP();
    if (ipLocation != null) {
      locationData['ipAddress'] = ipLocation['ip'];
      locationData['country'] = ipLocation['country'];
      locationData['countryCode'] = ipLocation['countryCode'];
      locationData['state'] = ipLocation['regionName'];
      locationData['city'] = ipLocation['city'];
      locationData['timezone'] = ipLocation['timezone'];

      // Use IP location if GPS is not available
      if (gpsLocation == null) {
        locationData['latitude'] = ipLocation['latitude'];
        locationData['longitude'] = ipLocation['longitude'];
        locationData['locationSource'] = 'ip';
      }
    }

    // Get public IP if not already available
    if (locationData['ipAddress'] == null) {
      locationData['ipAddress'] = await getPublicIP();
    }

    return locationData;
  }

  /// Check if location permissions are granted
  static Future<bool> hasLocationPermission() async {
    if (kIsWeb) {
      return true; // Web doesn't need explicit permission for IP-based location
    }

    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Request location permissions
  static Future<bool> requestLocationPermission() async {
    if (kIsWeb) {
      return true; // Web doesn't need explicit permission
    }

    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }
}
