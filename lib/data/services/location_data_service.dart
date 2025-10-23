import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class LocationDataService {
  static supabase.SupabaseClient get client =>
      supabase.Supabase.instance.client;

  /// Fetch all countries from the database
  static Future<List<Map<String, dynamic>>> getCountries() async {
    try {
      final response = await client
          .from('countries')
          .select('id, name, code')
          .eq('is_active', true)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // If countries table doesn't exist, return default countries
      return _getDefaultCountries();
    }
  }

  /// Fetch states by country ID
  static Future<List<Map<String, dynamic>>> getStatesByCountry(
    String countryId,
  ) async {
    try {
      final response = await client
          .from('states')
          .select('id, name, country_id')
          .eq('country_id', countryId)
          .eq('is_active', true)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // If states table doesn't exist, return default states for India
      return _getDefaultStates();
    }
  }

  /// Fetch cities by state ID
  static Future<List<Map<String, dynamic>>> getCitiesByState(
    String stateId,
  ) async {
    try {
      final response = await client
          .from('cities')
          .select('id, name, state_id')
          .eq('state_id', stateId)
          .eq('is_active', true)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // If cities table doesn't exist, return default cities
      return _getDefaultCities();
    }
  }

  /// Fetch pincodes by city ID
  static Future<List<Map<String, dynamic>>> getPincodesByCity(
    String cityId,
  ) async {
    try {
      final response = await client
          .from('pincodes')
          .select('id, pincode, city_id')
          .eq('city_id', cityId)
          .eq('is_active', true)
          .order('pincode');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // If pincodes table doesn't exist, return empty list
      return [];
    }
  }

  /// Fetch all projects from the database
  static Future<List<Map<String, dynamic>>> getProjects() async {
    try {
      final response = await client
          .from('projects')
          .select('id, name, city, state, developer_name')
          .eq('is_active', true)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching projects: $e');
      return [];
    }
  }

  /// Fetch projects by city
  static Future<List<Map<String, dynamic>>> getProjectsByCity(
    String city,
  ) async {
    try {
      final response = await client
          .from('projects')
          .select('id, name, city, state, developer_name')
          .eq('city', city)
          .eq('is_active', true)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching projects by city: $e');
      return [];
    }
  }

  /// Check if Aadhar number is unique
  static Future<bool> isAadharUnique(
    String aadhar, {
    String? excludeUserId,
  }) async {
    try {
      // Check only in profiles table metadata (users table doesn't have metadata column)
      var query = client.from('profiles').select('id').contains('metadata', {
        'aadhar': aadhar,
      });

      if (excludeUserId != null) {
        query = query.neq('id', excludeUserId);
      }

      final response = await query;

      return response.isEmpty;
    } catch (e) {
      print('Error checking Aadhar uniqueness: $e');
      return true; // Return true to allow saving if check fails
    }
  }

  /// Check if PAN number is unique
  static Future<bool> isPANUnique(String pan, {String? excludeUserId}) async {
    try {
      // Check only in profiles table metadata (users table doesn't have metadata column)
      var query = client.from('profiles').select('id').contains('metadata', {
        'pan': pan.toUpperCase(),
      });

      if (excludeUserId != null) {
        query = query.neq('id', excludeUserId);
      }

      final response = await query;

      return response.isEmpty;
    } catch (e) {
      print('Error checking PAN uniqueness: $e');
      return true; // Return true to allow saving if check fails
    }
  }

  /// Get default countries (fallback when database table doesn't exist)
  static List<Map<String, dynamic>> _getDefaultCountries() {
    return [
      {'id': '1', 'name': 'India', 'code': 'IN'},
      {'id': '2', 'name': 'United States', 'code': 'US'},
      {'id': '3', 'name': 'United Kingdom', 'code': 'GB'},
      {'id': '4', 'name': 'Canada', 'code': 'CA'},
      {'id': '5', 'name': 'Australia', 'code': 'AU'},
    ];
  }

  /// Get default states for India (fallback when database table doesn't exist)
  static List<Map<String, dynamic>> _getDefaultStates() {
    return [
      {'id': '1', 'name': 'Maharashtra', 'country_id': '1'},
      {'id': '2', 'name': 'Karnataka', 'country_id': '1'},
      {'id': '3', 'name': 'Tamil Nadu', 'country_id': '1'},
      {'id': '4', 'name': 'Delhi', 'country_id': '1'},
      {'id': '5', 'name': 'Gujarat', 'country_id': '1'},
      {'id': '6', 'name': 'Rajasthan', 'country_id': '1'},
      {'id': '7', 'name': 'Uttar Pradesh', 'country_id': '1'},
      {'id': '8', 'name': 'West Bengal', 'country_id': '1'},
      {'id': '9', 'name': 'Punjab', 'country_id': '1'},
      {'id': '10', 'name': 'Haryana', 'country_id': '1'},
    ];
  }

  /// Get default cities (fallback when database table doesn't exist)
  static List<Map<String, dynamic>> _getDefaultCities() {
    return [
      {'id': '1', 'name': 'Mumbai', 'state_id': '1'},
      {'id': '2', 'name': 'Pune', 'state_id': '1'},
      {'id': '3', 'name': 'Nagpur', 'state_id': '1'},
      {'id': '4', 'name': 'Bangalore', 'state_id': '2'},
      {'id': '5', 'name': 'Mysore', 'state_id': '2'},
      {'id': '6', 'name': 'Chennai', 'state_id': '3'},
      {'id': '7', 'name': 'Coimbatore', 'state_id': '3'},
      {'id': '8', 'name': 'New Delhi', 'state_id': '4'},
      {'id': '9', 'name': 'Ahmedabad', 'state_id': '5'},
      {'id': '10', 'name': 'Surat', 'state_id': '5'},
    ];
  }
}
