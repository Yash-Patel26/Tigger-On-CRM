import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'location_service.dart';
import 'login_location_service.dart';
import '../../shared/utils/connectivity_helper.dart';

class AuthService extends ChangeNotifier {
  static final supabase.SupabaseClient _supabase =
      supabase.Supabase.instance.client;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Sign in with email and password (for Provider usage)
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Check internet connectivity first
      final bool hasInternet = await ConnectivityHelper.hasInternetConnection();
      if (!hasInternet) {
        _setError('Please connect to the internet');
        _setLoading(false);
        return false;
      }

      final response = await signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _setLoading(false);
        return true;
      } else {
        _setError('Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Static method for sign in with email and password
  static Future<bool> signInWithEmailStatic({
    required String email,
    required String password,
  }) async {
    try {
      // Check internet connectivity first
      final bool hasInternet = await ConnectivityHelper.hasInternetConnection();
      if (!hasInternet) {
        return false;
      }

      final response = await signInWithPassword(
        email: email,
        password: password,
      );

      return response.user != null;
    } catch (e) {
      return false;
    }
  }

  /// Sign in with email and password, tracking location
  static Future<supabase.AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Attempt login
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Track successful login
        await LoginLocationService.trackLoginLocation(
          userId: response.user!.id,
          isSuccessful: true,
          sessionId: response.session?.accessToken,
        );
      }

      return response;
    } catch (e) {
      // Track failed login attempt
      try {
        // Get user ID if available (for existing users)
        final user = await _supabase.auth.getUser();
        if (user.user != null) {
          await LoginLocationService.trackLoginLocation(
            userId: user.user!.id,
            isSuccessful: false,
            failureReason: e.toString(),
          );
        }
      } catch (error) {
        // If we can't get user ID, we can't track the failed login
        // Could not track failed login: $error
      }

      rethrow;
    }
  }

  /// Sign up with email and password, tracking location
  static Future<supabase.AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: data,
      );

      if (response.user != null) {
        // Track successful signup
        await LoginLocationService.trackLoginLocation(
          userId: response.user!.id,
          isSuccessful: true,
          sessionId: response.session?.accessToken,
        );
      }

      return response;
    } catch (e) {
      // Track failed signup attempt
      try {
        final user = await _supabase.auth.getUser();
        if (user.user != null) {
          await LoginLocationService.trackLoginLocation(
            userId: user.user!.id,
            isSuccessful: false,
            failureReason: e.toString(),
          );
        }
      } catch (error) {
        // Could not track failed signup: $error
      }

      rethrow;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Get current user
  static supabase.User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  /// Get current session
  static supabase.Session? getCurrentSession() {
    return _supabase.auth.currentSession;
  }

  /// Check if user is signed in
  static bool isSignedIn() {
    return _supabase.auth.currentUser != null;
  }

  /// Get user login history
  static Future<List<UserLoginLocation>> getUserLoginHistory({
    int? limit,
    int? offset,
  }) async {
    final user = getCurrentUser();
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return await LoginLocationService.getUserLoginHistory(
      userId: user.id,
      limit: limit,
      offset: offset,
    );
  }

  /// Get user login statistics
  static Future<Map<String, dynamic>> getUserLoginStats() async {
    final user = getCurrentUser();
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return await LoginLocationService.getUserLoginStats(user.id);
  }

  /// Get all login locations (admin only)
  static Future<List<UserLoginLocation>> getAllLoginLocations({
    int? limit,
    int? offset,
    String? userId,
    String? country,
    String? city,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await LoginLocationService.getAllLoginLocations(
      limit: limit,
      offset: offset,
      userId: userId,
      country: country,
      city: city,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get login analytics (admin only)
  static Future<Map<String, dynamic>> getLoginAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await LoginLocationService.getLoginAnalytics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Check location permissions
  static Future<bool> hasLocationPermission() async {
    return await LocationService.hasLocationPermission();
  }

  /// Request location permissions
  static Future<bool> requestLocationPermission() async {
    return await LocationService.requestLocationPermission();
  }
}
