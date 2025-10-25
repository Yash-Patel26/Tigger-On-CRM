import '../../core/config/supabase_config.dart';
import '../models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeadQuestionService {
  static SupabaseClient get _client => SupabaseConfig.client;

  static Future<List<LeadQuestion>> getLeadQuestions({
    required String leadId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final int from = (page - 1) * limit;
      final int to = from + limit - 1;
      final response = await _client
          .from('lead_questions')
          .select('*')
          .eq('lead_id', leadId)
          .order('created_at', ascending: false)
          .range(from, to);

      return (response as List)
          .map((json) => LeadQuestion.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch lead questions: $e');
    }
  }

  static Future<LeadQuestion> createLeadQuestion({
    required String leadId,
    required String title,
    String? notes,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'lead_id': leadId,
        'title': title,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final response = await _client
          .from('lead_questions')
          .insert(payload)
          .select()
          .single();

      return LeadQuestion.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create lead question: $e');
    }
  }

  static Future<LeadQuestion> updateLeadQuestion(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _client
          .from('lead_questions')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return LeadQuestion.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update lead question: $e');
    }
  }

  static Future<void> deleteLeadQuestion(String id) async {
    try {
      await _client.from('lead_questions').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete lead question: $e');
    }
  }
}
