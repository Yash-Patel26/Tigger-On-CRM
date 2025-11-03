import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'location_data_service.dart';

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
    // First try to get from profiles table (has metadata with all profile details)
    final profileResponse = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (profileResponse != null) {
      // Get additional data from users table and merge
      final userResponse = await client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (userResponse != null) {
        // Merge user data with profile data, prioritizing profile data for metadata
        return {
          ...userResponse,
          ...profileResponse,
          // Ensure metadata comes from profiles table
          'metadata': profileResponse['metadata'],
        };
      }
      return profileResponse;
    }

    // Fallback to users table if not found in profiles
    final userResponse = await client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return userResponse;
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
    // Validate Aadhar and PAN uniqueness if provided
    if (metadata != null) {
      if (metadata['aadhar'] != null) {
        final isAadharUnique = await LocationDataService.isAadharUnique(
          metadata['aadhar'],
          excludeUserId: userId,
        );
        if (!isAadharUnique) {
          throw Exception('Aadhar number already exists');
        }
      }

      if (metadata['pan'] != null) {
        final isPANUnique = await LocationDataService.isPANUnique(
          metadata['pan'],
          excludeUserId: userId,
        );
        if (!isPANUnique) {
          throw Exception('PAN number already exists');
        }
      }
    }

    // Update users table first (without metadata since it doesn't exist in users table)
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
    try {
      // Verify user is authenticated before upload
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to upload recordings');
      }

      // Verify session is valid
      final session = client.auth.currentSession;
      if (session == null) {
        throw Exception('No active session found. Please log in again.');
      }

      print('User authenticated: ${currentUser.id}, uploading recording...');

      final file = File(filePath);

      if (!await file.exists()) {
        throw Exception('Recording file does not exist: $filePath');
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('Recording file is empty: $filePath');
      }

      print('Preparing to upload recording: $filePath ($fileSize bytes)');

      final fileName = filePath.split('/').last;
      // Use timestamp and UUID to ensure unique file names
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';
      final fullPath = '$destFolder/$uniqueFileName';

      print('Reading file bytes...');
      final Uint8List bytes = await file.readAsBytes();
      print('File bytes read: ${bytes.length} bytes');

      print('Uploading to Supabase Storage bucket: $bucket, path: $fullPath');
      print('Using authenticated session for user: ${currentUser.id}');

      // Upload with explicit content type
      await client.storage
          .from(bucket)
          .uploadBinary(
            fullPath,
            bytes,
            fileOptions: supabase.FileOptions(
              contentType: 'audio/mp4', // M4A files use mp4 mime type
              upsert: true,
              cacheControl: '3600',
            ),
          );

      print('Upload successful. Getting public URL...');
      final publicUrl = client.storage.from(bucket).getPublicUrl(fullPath);
      print('Public URL obtained: $publicUrl');

      return publicUrl;
    } catch (e, stackTrace) {
      print('Error in uploadRecording: $e');
      print('Stack trace: $stackTrace');

      // Provide more specific error messages
      if (e.toString().contains('row-level security') ||
          e.toString().contains('403') ||
          e.toString().contains('Unauthorized')) {
        final currentUser = client.auth.currentUser;
        final session = client.auth.currentSession;
        print('RLS Error Details:');
        print('  - Current User: ${currentUser?.id ?? "null"}');
        print('  - Has Session: ${session != null}');
        print('  - Session Expires At: ${session?.expiresAt}');

        if (session != null && session.expiresAt != null) {
          final expiresAt = DateTime.fromMillisecondsSinceEpoch(
            session.expiresAt! * 1000,
          );
          final now = DateTime.now();
          if (expiresAt.isBefore(now)) {
            print('  - WARNING: Session has expired!');
            throw Exception('Session expired. Please log in again.');
          }
        }

        throw Exception(
          'Upload failed due to permissions. User may not be authenticated or session expired.',
        );
      }

      rethrow;
    }
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
