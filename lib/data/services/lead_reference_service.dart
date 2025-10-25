import '../../core/config/supabase_config.dart';
import '../models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeadReferenceService {
  static SupabaseClient get _client => SupabaseConfig.client;

  static Future<List<LeadReference>> getLeadReferences({
    required String leadId,
    String? direction, // 'to' or 'by'
    int page = 1,
    int limit = 20,
  }) async {
    try {
      var query = _client
          .from('lead_references')
          .select('*')
          .eq('lead_id', leadId);

      if (direction != null) {
        query = query.eq('direction', direction);
      }

      final int from = (page - 1) * limit;
      final int to = from + limit - 1;
      final response = await query
          .order('created_at', ascending: false)
          .range(from, to);

      return (response as List)
          .map((json) => LeadReference.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch lead references: $e');
    }
  }

  static Future<LeadReference> createLeadReference({
    required String leadId,
    required String direction, // 'to' or 'by'
    required String firstName,
    String? middleName,
    required String lastName,
    required String contact,
    required String email,
    String? note,
    String? linkedLeadId,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'lead_id': leadId,
        'direction': direction,
        'first_name': firstName,
        if (middleName != null) 'middle_name': middleName,
        'last_name': lastName,
        'contact': contact,
        'email': email,
        if (note != null && note.isNotEmpty) 'note': note,
        if (linkedLeadId != null && linkedLeadId.isNotEmpty)
          'linked_lead_id': linkedLeadId,
      };

      final response = await _client
          .from('lead_references')
          .insert(payload)
          .select()
          .single();

      return LeadReference.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create lead reference: $e');
    }
  }

  static Future<LeadReference> updateLeadReference(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _client
          .from('lead_references')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return LeadReference.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update lead reference: $e');
    }
  }

  static Future<void> deleteLeadReference(String id) async {
    try {
      await _client.from('lead_references').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete lead reference: $e');
    }
  }
}
