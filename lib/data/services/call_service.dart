import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class CallService {
  static supabase.SupabaseClient get _client =>
      supabase.Supabase.instance.client;

  /// Logs a call start and returns the created call id (uuid as String).
  /// Requires the RPC `public.log_call` to be present in the database.
  static Future<String> logCall({
    required String phone,
    required String direction, // 'outbound' | 'inbound'
    String? leadId,
    String? customerId,
    String? initiatedByName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final dynamic res = await _client.rpc(
        'log_call',
        params: <String, dynamic>{
          '_phone': phone,
          '_direction': direction,
          '_status': 'initiated',
          if (leadId != null) '_lead_id': leadId,
          if (customerId != null) '_customer_id': customerId,
          if (initiatedByName != null) '_initiated_by_name': initiatedByName,
          if (metadata != null) '_metadata': metadata,
        },
      );
      if (res == null) {
        throw Exception('log_call returned null id');
      }
      return res as String;
    } catch (e) {
      throw Exception('Failed to log call: $e');
    }
  }

  /// Ends a call and optionally attaches a recording URL.
  /// Requires the RPC `public.end_call_with_recording` to be present in the database.
  static Future<void> endCallWithRecording({
    required String callId,
    String status = 'completed',
    String? recordingUrl,
    DateTime? endedAt,
  }) async {
    try {
      await _client.rpc(
        'end_call_with_recording',
        params: <String, dynamic>{
          '_call_id': callId,
          '_status': status,
          if (recordingUrl != null) '_recording_url': recordingUrl,
          if (endedAt != null) '_ended_at': endedAt.toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to end call: $e');
    }
  }

  /// Marks a call as connected (OFFHOOK observed).
  /// Tries RPC `public.mark_call_connected` first; if missing, falls back to a direct update.
  static Future<void> markCallConnected({required String callId}) async {
    try {
      await _client.rpc(
        'mark_call_connected',
        params: <String, dynamic>{'_call_id': callId},
      );
      return;
    } catch (_) {
      // Fallback: attempt direct update on calls table if RPC not available
      try {
        await _client
            .from('calls')
            .update(<String, dynamic>{
              'status': 'connected',
              'connected_at': DateTime.now().toIso8601String(),
            })
            .eq('id', callId);
      } catch (e) {
        throw Exception('Failed to mark call connected: $e');
      }
    }
  }
}
