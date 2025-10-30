import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class NotificationSoundService {
  NotificationSoundService._();
  static final NotificationSoundService instance = NotificationSoundService._();

  final AudioPlayer _player = AudioPlayer();
  String? _cachedDefaultUrl;
  DateTime? _lastFetchedAt;

  Future<void> play({String? soundUrl}) async {
    try {
      final String? url = soundUrl ?? await _getDefaultSoundUrl();
      if (url == null || url.isEmpty) {
        return; // No custom sound configured
      }
      // Ensure a short, non-looping playback at reasonable volume
      await _player.stop();
      await _player.setSourceUrl(url);
      await _player.setVolume(1.0);
      await _player.resume();
    } catch (_) {
      // Silently ignore audio failures to avoid blocking the app
    }
  }

  Future<String?> _getDefaultSoundUrl() async {
    // Cache for 60 seconds to avoid excessive reads
    if (_cachedDefaultUrl != null &&
        _lastFetchedAt != null &&
        DateTime.now().difference(_lastFetchedAt!) <
            const Duration(seconds: 60)) {
      return _cachedDefaultUrl;
    }

    try {
      final client = supabase.Supabase.instance.client;
      // Try app_settings table first
      final row = await client
          .from('app_settings')
          .select('notification_sound_url')
          .maybeSingle();
      final String? url = (row != null)
          ? row['notification_sound_url'] as String?
          : null;

      _cachedDefaultUrl = url;
      _lastFetchedAt = DateTime.now();
      return _cachedDefaultUrl;
    } catch (_) {
      // As a fallback, try settings table with key/value
      try {
        final client = supabase.Supabase.instance.client;
        final rows = await client
            .from('settings')
            .select('key,value')
            .eq('key', 'notification_sound_url');
        if (rows.isNotEmpty) {
          final val = rows.first['value'];
          _cachedDefaultUrl = val is String ? val : null;
          _lastFetchedAt = DateTime.now();
          return _cachedDefaultUrl;
        }
      } catch (_) {}
      return null;
    }
  }
}
