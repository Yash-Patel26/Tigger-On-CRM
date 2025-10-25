import '../../core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeadDuplicateService {
  static SupabaseClient get _client => SupabaseConfig.client;

  // Check if a lead with the same contact number already exists
  static Future<Map<String, dynamic>?> checkDuplicateLead(
    String contactNumber,
  ) async {
    try {
      // Normalize phone number for comparison
      String normalizePhone(String phone) {
        // Remove all non-digit characters except +
        String cleaned = phone.replaceAll(RegExp(r"[^0-9+]"), "");
        // Remove leading + if present
        if (cleaned.startsWith('+')) {
          cleaned = cleaned.substring(1);
        }
        // Remove leading country code if it's 91 (India)
        if (cleaned.startsWith('91') && cleaned.length > 10) {
          cleaned = cleaned.substring(2);
        }
        return cleaned;
      }

      final String normalizedPhone = normalizePhone(contactNumber);

      // Search for existing lead with the same phone number
      final response = await _client
          .from('leads')
          .select(
            'id, lead_id, customer_name, phone, assigned_to_name, created_at',
          )
          .or(
            'phone.eq.$contactNumber,phone.eq.$normalizedPhone,phone.eq.+$normalizedPhone,phone.eq.+91$normalizedPhone',
          )
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return {
          'exists': true,
          'lead_id': response['lead_id'],
          'customer_name': response['customer_name'],
          'assigned_to_name': response['assigned_to_name'],
          'created_at': response['created_at'],
        };
      }

      return {'exists': false};
    } catch (e) {
      print('Error checking duplicate lead: $e');
      return null;
    }
  }

  // Get lead details by contact number
  static Future<Map<String, dynamic>?> getLeadByContactNumber(
    String contactNumber,
  ) async {
    try {
      // Normalize phone number for comparison
      String normalizePhone(String phone) {
        String cleaned = phone.replaceAll(RegExp(r"[^0-9+]"), "");
        if (cleaned.startsWith('+')) {
          cleaned = cleaned.substring(1);
        }
        if (cleaned.startsWith('91') && cleaned.length > 10) {
          cleaned = cleaned.substring(2);
        }
        return cleaned;
      }

      final String normalizedPhone = normalizePhone(contactNumber);

      final response = await _client
          .from('leads')
          .select('*')
          .or(
            'phone.eq.$contactNumber,phone.eq.$normalizedPhone,phone.eq.+$normalizedPhone,phone.eq.+91$normalizedPhone',
          )
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error getting lead by contact number: $e');
      return null;
    }
  }
}
