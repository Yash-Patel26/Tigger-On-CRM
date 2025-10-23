import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../data/services/auth_service.dart';
import '../utils/connectivity_helper.dart';

/// Manages authentication state and session persistence
class AuthStateManager extends ChangeNotifier {
  static final supabase.SupabaseClient _supabase =
      supabase.Supabase.instance.client;

  bool _isInitialized = false;
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _error;
  supabase.User? _currentUser;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  supabase.User? get currentUser => _currentUser;

  /// Initialize authentication state by checking for existing session
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setLoading(true);
      _setError(null);

      // Check internet connectivity
      final bool hasInternet = await ConnectivityHelper.hasInternetConnection();
      if (!hasInternet) {
        _setError('No internet connection');
        _setLoading(false);
        _isInitialized = true;
        return;
      }

      // Check for existing session
      final supabase.Session? session = _supabase.auth.currentSession;
      final supabase.User? user = _supabase.auth.currentUser;

      if (session != null && user != null) {
        // Check if session is still valid
        if (session.expiresAt != null &&
            DateTime.fromMillisecondsSinceEpoch(
              session.expiresAt! * 1000,
            ).isAfter(DateTime.now())) {
          _isAuthenticated = true;
          _currentUser = user;
          debugPrint('User session restored: ${user.email}');
        } else {
          // Session expired, try to refresh
          try {
            final supabase.AuthResponse response = await _supabase.auth
                .refreshSession();
            if (response.session != null && response.user != null) {
              _isAuthenticated = true;
              _currentUser = response.user;
              debugPrint('Session refreshed for: ${response.user!.email}');
            } else {
              _isAuthenticated = false;
              _currentUser = null;
              debugPrint('Session refresh failed');
            }
          } catch (e) {
            _isAuthenticated = false;
            _currentUser = null;
            debugPrint('Session refresh error: $e');
          }
        }
      } else {
        _isAuthenticated = false;
        _currentUser = null;
        debugPrint('No existing session found');
      }

      // Listen to auth state changes
      _supabase.auth.onAuthStateChange.listen(_onAuthStateChange);
    } catch (e) {
      _setError('Authentication initialization failed: $e');
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _setLoading(false);
      _isInitialized = true;
    }
  }

  /// Handle authentication state changes
  void _onAuthStateChange(supabase.AuthState data) {
    final supabase.Session? session = data.session;
    final supabase.User? user = _supabase.auth.currentUser;

    _isAuthenticated = session != null && user != null;
    _currentUser = user;

    if (_isAuthenticated) {
      debugPrint('User authenticated: ${user!.email}');
    } else {
      debugPrint('User signed out');
    }

    notifyListeners();
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Check internet connectivity
      final bool hasInternet = await ConnectivityHelper.hasInternetConnection();
      if (!hasInternet) {
        _setError('Please connect to the internet');
        _setLoading(false);
        return false;
      }

      final bool success = await AuthService.signInWithEmailStatic(
        email: email,
        password: password,
      );

      if (success) {
        _isAuthenticated = true;
        _currentUser = _supabase.auth.currentUser;
        debugPrint('Sign in successful: ${_currentUser?.email}');
      } else {
        _setError('Sign in failed');
      }

      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Sign in error: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await AuthService.signOut();
      _isAuthenticated = false;
      _currentUser = null;
      debugPrint('User signed out');
    } catch (e) {
      _setError('Sign out error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh current session
  Future<bool> refreshSession() async {
    try {
      _setLoading(true);
      _setError(null);

      final supabase.AuthResponse response = await _supabase.auth
          .refreshSession();

      if (response.session != null && response.user != null) {
        _isAuthenticated = true;
        _currentUser = response.user;
        debugPrint('Session refreshed successfully');
        return true;
      } else {
        _isAuthenticated = false;
        _currentUser = null;
        debugPrint('Session refresh failed');
        return false;
      }
    } catch (e) {
      _setError('Session refresh error: $e');
      _isAuthenticated = false;
      _currentUser = null;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
