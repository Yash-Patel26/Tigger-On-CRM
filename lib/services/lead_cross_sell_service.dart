import '../config/supabase_config.dart';
import '../models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeadCrossSellService {
  static SupabaseClient get _client => SupabaseConfig.client;

  static Future<List<LeadCrossSell>> getLeadCrossSells({
    required String leadId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final int from = (page - 1) * limit;
      final int to = from + limit - 1;
      final response = await _client
          .from('lead_cross_sells')
          .select('*')
          .eq('lead_id', leadId)
          .order('created_at', ascending: false)
          .range(from, to);

      return (response as List)
          .map((json) => LeadCrossSell.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch lead cross sells: $e');
    }
  }

  static Future<LeadCrossSell> createLeadCrossSell({
    required String leadId,
    String? category,
    String? propertyType,
    String? projectId,
    String? projectName,
    String? allocatedToName,
    String? allocatedTo,
    String? description,
    String? linkedLeadId,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'lead_id': leadId,
        if (category != null && category.isNotEmpty) 'category': category,
        if (propertyType != null && propertyType.isNotEmpty)
          'property_type': propertyType,
        if (projectId != null && projectId.isNotEmpty) 'project_id': projectId,
        if (projectName != null && projectName.isNotEmpty)
          'project_name': projectName,
        if (allocatedToName != null && allocatedToName.isNotEmpty)
          'allocated_to_name': allocatedToName,
        if (allocatedTo != null && allocatedTo.isNotEmpty)
          'allocated_to': allocatedTo,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (linkedLeadId != null && linkedLeadId.isNotEmpty)
          'linked_lead_id': linkedLeadId,
      };

      final response = await _client
          .from('lead_cross_sells')
          .insert(payload)
          .select()
          .single();

      return LeadCrossSell.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create lead cross sell: $e');
    }
  }

  static Future<LeadCrossSell> updateLeadCrossSell(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _client
          .from('lead_cross_sells')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return LeadCrossSell.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update lead cross sell: $e');
    }
  }

  static Future<void> deleteLeadCrossSell(String id) async {
    try {
      await _client.from('lead_cross_sells').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete lead cross sell: $e');
    }
  }
}
