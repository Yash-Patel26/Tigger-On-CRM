import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://tyntmzyinafmuwzirifb.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5bnRtenlpbmFmbXV3emlyaWZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzODgxMTQsImV4cCI6MjA3NTk2NDExNH0.DMSdKcF-d17qS4u2bCUhNrsf7rExAehrug7waRTFlvc';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Set to false in production
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}
