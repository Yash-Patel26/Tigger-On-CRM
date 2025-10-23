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
    // First try to get from users table (primary source)
    final userResponse = await client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (userResponse != null) {
      return userResponse;
    }

    // Fallback to profiles table if not found in users
    final profileResponse = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return profileResponse;
  }

  static Future<void> updateProfile({
    required String userId,
    String? username,
    String? fullName,
    String? website,
    String? avatarUrl,
    String? phone,
    String? designation,
    String? department,
    String? role,
    Map<String, dynamic>? metadata,
  }) async {
    // Update users table first
    await client
        .from('users')
        .update({
          'name': fullName,
          'phone': phone,
          'designation': designation,
          'role': role,
          'profile_image_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);

    // Also update profiles table for backward compatibility with proper validation
    try {
      // Prepare profile data with proper validation
      final profileData = <String, dynamic>{
        'id': userId,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'website': website,
        'metadata': metadata ?? {},
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Only add username if it's valid (3+ characters)
      if (username != null && username.length >= 3) {
        profileData['username'] = username;
      }

      // Note: profiles table only has: id, updated_at, username, full_name, avatar_url, website, metadata
      // Additional fields like phone, designation, department, role are stored in the users table

      await client.from('profiles').upsert(profileData);
    } catch (e) {
      // If profiles table update fails, at least the users table is updated
      print('Warning: Failed to update profiles table: $e');
      // Don't rethrow to avoid breaking the users table update
    }
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

  // Safe profile creation method to handle 400 errors
  // Note: profiles table schema: id, updated_at, username, full_name, avatar_url, website, metadata
  // Additional user fields (phone, designation, department, role) are stored in users table
  static Future<void> createProfileSafely({
    required String userId,
    String? username,
    String? fullName,
    String? website,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Ensure username meets requirements (3+ characters, unique)
      String finalUsername = username ?? 'user_${userId.substring(0, 8)}';
      if (finalUsername.length < 3) {
        finalUsername = 'user_${userId.substring(0, 8)}';
      }

      // Prepare data with all required fields
      final profileData = {
        'id': userId,
        'username': finalUsername,
        'full_name': fullName ?? 'User',
        'avatar_url': avatarUrl,
        'website': website,
        'metadata': metadata ?? {},
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Use upsert to handle conflicts
      await client.from('profiles').upsert(profileData);
    } catch (e) {
      print('Error creating profile safely: $e');
      // Don't rethrow to avoid breaking the app
    }
  }
}
