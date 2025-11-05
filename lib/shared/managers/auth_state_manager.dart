import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../data/services/auth_service.dart';
import '../utils/connectivity_helper.dart';
import 'notification_manager.dart';

/// Manages authentication state and session persistence
class AuthStateManager extends ChangeNotifier {
  static final supabase.SupabaseClient _supabase =
      supabase.Supabase.instance.client;

  bool _isInitialized = false;
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _error;
  supabase.User? _currentUser;
  String? _userRole;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  supabase.User? get currentUser => _currentUser;
  String? get userRole => _userRole;
  bool get isAdmin => _userRole == 'admin';
  bool get isHead => _userRole == 'head';
  bool get isAdminOrHead => isAdmin || isHead;

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
          await _loadUserRole(user.id);
          debugPrint('User session restored: ${user.email}');
        } else {
          // Session expired, try to refresh
          try {
            final supabase.AuthResponse response = await _supabase.auth
                .refreshSession();
            if (response.session != null && response.user != null) {
              _isAuthenticated = true;
              _currentUser = response.user;
              await _loadUserRole(response.user!.id);
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
      _loadUserRole(user.id);
    } else {
      debugPrint('User signed out');
      _userRole = null;
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
        // Get the current user and session after successful login
        final supabase.User? user = _supabase.auth.currentUser;
        final supabase.Session? session = _supabase.auth.currentSession;

        debugPrint(
          'Sign in successful - user: ${user?.email}, session: ${session != null}',
        );

        if (user != null && session != null) {
          _isAuthenticated = true;
          _currentUser = user;
          await _loadUserRole(user.id);
          debugPrint('Setting _isAuthenticated = true and notifying listeners');
          // Notify listeners immediately after successful login
          notifyListeners();
        } else {
          debugPrint('Sign in failed: No user session');
          _setError('Sign in failed: No user session');
        }
      } else {
        debugPrint('Sign in failed: success = false');
        _setError('Sign in failed');
      }

      debugPrint('Setting loading to false');
      _setLoading(false);
      debugPrint(
        'Final state - isAuthenticated: $_isAuthenticated, isLoading: $_isLoading',
      );
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
      // Immediately clear local state first
      _isAuthenticated = false;
      _currentUser = null;
      _userRole = null;
      // Notify listeners immediately to trigger UI update
      notifyListeners();

      // Clear session from Supabase
      await AuthService.signOut();

      // Clear notification manager state if user was logged in
      try {
        final notificationManager = NotificationManager();
        notificationManager.dispose();
        notificationManager.clearCache();
      } catch (_) {
        // Ignore notification cleanup errors
      }

      debugPrint('User signed out and session cleared');
    } catch (e) {
      _setError('Sign out error: $e');
      // Even if signOut fails, ensure local state is cleared
      _isAuthenticated = false;
      _currentUser = null;
      _userRole = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserRole(String userId) async {
    try {
      final roleResp = await supabase.Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id', userId)
          .eq('is_active', true)
          .maybeSingle();
      _userRole = roleResp?['role'] as String?;
    } catch (_) {
      _userRole = null;
    }
    notifyListeners();
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
}
