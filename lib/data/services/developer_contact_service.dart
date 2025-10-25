import '../../core/config/supabase_config.dart';
import '../models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeveloperContactService {
  static SupabaseClient get _client => SupabaseConfig.client;

  static Future<List<DeveloperContact>> getDeveloperContacts({
    String? developerId,
    bool? isPrimary,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      var query = _client.from('developer_contacts').select('*');

      if (developerId != null) {
        query = query.eq('developer_id', developerId);
      }

      if (isPrimary != null) {
        query = query.eq('is_primary', isPrimary);
      }

      final int from = (page - 1) * limit;
      final int to = from + limit - 1;
      final response = await query
          .order('created_at', ascending: false)
          .range(from, to);

      return (response as List)
          .map((json) => DeveloperContact.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch developer contacts: $e');
    }
  }

  static Future<DeveloperContact> createDeveloperContact({
    required String developerId,
    required String name,
    required String mobile,
    required String designation,
    required String email,
    bool isPrimary = false,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'developer_id': developerId,
        'name': name,
        'mobile': mobile,
        'designation': designation,
        'email': email,
        'is_primary': isPrimary,
      };

      final response = await _client
          .from('developer_contacts')
          .insert(payload)
          .select()
          .single();

      return DeveloperContact.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create developer contact: $e');
    }
  }

  static Future<DeveloperContact> updateDeveloperContact(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _client
          .from('developer_contacts')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return DeveloperContact.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update developer contact: $e');
    }
  }

  static Future<void> deleteDeveloperContact(String id) async {
    try {
      await _client.from('developer_contacts').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete developer contact: $e');
    }
  }
}
