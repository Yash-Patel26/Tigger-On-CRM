import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class SupabaseService {
  static supabase.SupabaseClient get client =>
      supabase.Supabase.instance.client;

  // Authentication methods
  static Future<supabase.AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static supabase.User? get currentUser => client.auth.currentUser;

  static supabase.Session? get currentSession => client.auth.currentSession;

  // Profile methods
  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }

  static Future<void> updateProfile({
    required String userId,
    String? username,
    String? fullName,
    String? website,
    String? avatarUrl,
  }) async {
    await client.from('profiles').upsert({
      'id': userId,
      'username': username,
      'full_name': fullName,
      'website': website,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Auth state stream
  static Stream<supabase.AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  // Upload recording to Supabase Storage
  static Future<String> uploadRecording({
    required String bucket,
    required String filePath,
    required String destFolder,
  }) async {
    final file = File(filePath);
    final fileName = filePath.split('/').last;
    final fullPath = '$destFolder/$fileName';

    await client.storage.from(bucket).upload(fullPath, file);

    final publicUrl = client.storage.from(bucket).getPublicUrl(fullPath);
    return publicUrl;
  }
}
