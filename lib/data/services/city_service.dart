import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../models/city_model.dart';

class CityService {
  static SupabaseClient get _client => SupabaseConfig.client;

  static Future<List<City>> getCities({
    String? search,
    String? stateId,
    bool? isActive,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      var query = _client.from('cities').select('''
        *,
        states!inner(name)
      ''');

      // Apply filters
      if (search != null && search.isNotEmpty) {
        query = query.or('name.ilike.%$search%');
      }

      if (stateId != null) {
        query = query.eq('state_id', stateId);
      }

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      // Apply pagination
      final int from = (page - 1) * limit;
      final int to = from + limit - 1;
      final response = await query
          .order('name', ascending: true)
          .range(from, to);

      return (response as List).map((json) {
        // Add state name from the joined states table
        final Map<String, dynamic> cityJson = json as Map<String, dynamic>;
        if (cityJson['states'] != null) {
          cityJson['state_name'] = cityJson['states']['name'];
        }
        return City.fromJson(cityJson);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch cities: $e');
    }
  }

  static Future<City?> getCityById(String id) async {
    try {
      final response = await _client
          .from('cities')
          .select('''
            *,
            states!inner(name)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      // Add state name from the joined states table
      final Map<String, dynamic> cityJson = response;
      if (cityJson['states'] != null) {
        cityJson['state_name'] = cityJson['states']['name'];
      }

      return City.fromJson(cityJson);
    } catch (e) {
      throw Exception('Failed to fetch city: $e');
    }
  }

  static Future<Map<String, dynamic>> getCityStats() async {
    try {
      // Get total cities count
      final totalCities = await _client.from('cities').select('id');

      // Get active cities count
      final activeCities = await _client
          .from('cities')
          .select('id')
          .eq('is_active', true);

      return {
        'total': (totalCities as List).length,
        'active': (activeCities as List).length,
        'inactive':
            (totalCities as List).length - (activeCities as List).length,
      };
    } catch (e) {
      throw Exception('Failed to fetch city stats: $e');
    }
  }
}
