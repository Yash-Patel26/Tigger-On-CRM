import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user_login_location_model.dart';
import 'location_service.dart';

class LoginLocationService {
  static final supabase.SupabaseClient _supabase =
      supabase.Supabase.instance.client;

  /// Track user login location
  static Future<void> trackLoginLocation({
    required String userId,
    required bool isSuccessful,
    String? failureReason,
    String? sessionId,
  }) async {
    try {
      // Get location data
      final locationData = await LocationService.getLoginLocationData();

      // Helper function to truncate strings to 255 characters
      String? _truncateString(dynamic value, {int maxLength = 255}) {
        if (value == null) return null;
        final str = value.toString();
        return str.length > maxLength ? str.substring(0, maxLength) : str;
      }

      // Create login location record (omit id to let database auto-generate)
      final loginLocationData = {
        'user_id': userId,
        'login_timestamp': DateTime.now().toIso8601String(),
        'ip_address': _truncateString(locationData['ipAddress']),
        'country': _truncateString(locationData['country']),
        'country_code': _truncateString(
          locationData['countryCode'],
          maxLength: 10,
        ),
        'state': _truncateString(locationData['state']),
        'city': _truncateString(locationData['city']),
        'latitude': locationData['latitude']?.toDouble(),
        'longitude': locationData['longitude']?.toDouble(),
        'timezone': _truncateString(locationData['timezone']),
        'device_type': _truncateString(locationData['deviceType']),
        'device_os': _truncateString(locationData['deviceOs']),
        'browser': _truncateString(locationData['browser']),
        'user_agent': _truncateString(locationData['userAgent']),
        'is_successful': isSuccessful,
        'failure_reason': _truncateString(failureReason),
        'session_id': _truncateString(sessionId),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Insert into database
      await _supabase.from('user_login_locations').insert(loginLocationData);

      print('Login location tracked successfully for user: $userId');
    } catch (e) {
      print('Error tracking login location: $e');
      // Don't throw error to avoid breaking login flow
    }
  }

  /// Get user's login history
  static Future<List<UserLoginLocation>> getUserLoginHistory({
    required String userId,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _supabase
          .from('user_login_locations')
          .select()
          .eq('user_id', userId)
          .order('login_timestamp', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;

      return (response as List)
          .map((json) => UserLoginLocation.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting user login history: $e');
      return [];
    }
  }

  /// Get login statistics for a user
  static Future<Map<String, dynamic>> getUserLoginStats(String userId) async {
    try {
      final response = await _supabase
          .from('user_login_locations')
          .select('country, city, device_type, login_timestamp, is_successful')
          .eq('user_id', userId);

      final loginData = response as List;

      // Calculate statistics
      final totalLogins = loginData.length;
      final successfulLogins = loginData
          .where((login) => login['is_successful'] == true)
          .length;
      final failedLogins = totalLogins - successfulLogins;

      // Get unique countries
      final countries = loginData
          .map((login) => login['country'])
          .where((country) => country != null)
          .toSet()
          .toList();

      // Get unique cities
      final cities = loginData
          .map((login) => login['city'])
          .where((city) => city != null)
          .toSet()
          .toList();

      // Get device types
      final deviceTypes = loginData
          .map((login) => login['device_type'])
          .where((device) => device != null)
          .toSet()
          .toList();

      // Get last login
      final lastLogin = loginData.isNotEmpty
          ? DateTime.parse(loginData.first['login_timestamp'])
          : null;

      return {
        'totalLogins': totalLogins,
        'successfulLogins': successfulLogins,
        'failedLogins': failedLogins,
        'successRate': totalLogins > 0
            ? (successfulLogins / totalLogins * 100).round()
            : 0,
        'countries': countries,
        'cities': cities,
        'deviceTypes': deviceTypes,
        'lastLogin': lastLogin?.toIso8601String(),
      };
    } catch (e) {
      print('Error getting user login stats: $e');
      return {};
    }
  }

  /// Get all login locations (admin only)
  static Future<List<UserLoginLocation>> getAllLoginLocations({
    int? limit,
    int? offset,
    String? userId,
    String? country,
    String? city,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase.from('user_login_locations').select();

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      if (country != null) {
        query = query.eq('country', country);
      }

      if (city != null) {
        query = query.eq('city', city);
      }

      if (startDate != null) {
        query = query.gte('login_timestamp', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('login_timestamp', endDate.toIso8601String());
      }

      // Apply ordering after filters; switch to a transform builder
      var orderedQuery = query.order('login_timestamp', ascending: false);

      if (limit != null) {
        orderedQuery = orderedQuery.limit(limit);
      }

      if (offset != null) {
        orderedQuery = orderedQuery.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await orderedQuery;

      return (response as List)
          .map((json) => UserLoginLocation.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting all login locations: $e');
      return [];
    }
  }

  /// Get login analytics (admin only)
  static Future<Map<String, dynamic>> getLoginAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('user_login_locations')
          .select(
            'country, city, device_type, login_timestamp, is_successful, user_id',
          );

      if (startDate != null) {
        query = query.gte('login_timestamp', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('login_timestamp', endDate.toIso8601String());
      }

      final response = await query;
      final loginData = response as List;

      // Calculate analytics
      final totalLogins = loginData.length;
      final successfulLogins = loginData
          .where((login) => login['is_successful'] == true)
          .length;
      final uniqueUsers = loginData
          .map((login) => login['user_id'])
          .toSet()
          .length;

      // Top countries
      final countryCounts = <String, int>{};
      for (final login in loginData) {
        final country = login['country'];
        if (country != null) {
          countryCounts[country] = (countryCounts[country] ?? 0) + 1;
        }
      }
      final topCountries = countryCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Top cities
      final cityCounts = <String, int>{};
      for (final login in loginData) {
        final city = login['city'];
        if (city != null) {
          cityCounts[city] = (cityCounts[city] ?? 0) + 1;
        }
      }
      final topCities = cityCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Device types
      final deviceCounts = <String, int>{};
      for (final login in loginData) {
        final device = login['device_type'];
        if (device != null) {
          deviceCounts[device] = (deviceCounts[device] ?? 0) + 1;
        }
      }

      return {
        'totalLogins': totalLogins,
        'successfulLogins': successfulLogins,
        'failedLogins': totalLogins - successfulLogins,
        'successRate': totalLogins > 0
            ? (successfulLogins / totalLogins * 100).round()
            : 0,
        'uniqueUsers': uniqueUsers,
        'topCountries': topCountries
            .take(10)
            .map((e) => {'country': e.key, 'count': e.value})
            .toList(),
        'topCities': topCities
            .take(10)
            .map((e) => {'city': e.key, 'count': e.value})
            .toList(),
        'deviceTypes': deviceCounts,
      };
    } catch (e) {
      print('Error getting login analytics: $e');
      return {};
    }
  }
}
