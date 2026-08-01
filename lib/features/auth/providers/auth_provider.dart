import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages authentication state using Supabase Auth.
///
/// Loads session on init, listens to auth state stream, and provides
/// methods for sign-in, sign-up, password reset, and sign-out.
class AuthProvider with ChangeNotifier {
  final SupabaseClient? _client;
  User? _user;
  bool _loading = true;
  bool _hasError = false;
  String? _errorMessage;

  /// Demo mode — used when Supabase env vars are not configured (debug builds).
  ///
  /// Skips the auth stream, immediately finishes loading, and exposes
  /// [demoMode] so screens can show a hint instead of failing.
  factory AuthProvider.demo() => AuthProvider._demo();

  AuthProvider._demo() : _client = null {
    _loading = false;
    _user = null;
  }

  /// True when running without Supabase (no env vars) in debug builds.
  bool get demoMode => _client == null;

  /// Loading state while checking initial session
  bool get loading => _loading;

  /// Currently authenticated user (null if not logged in)
  User? get user => _user;

  /// True when an error has occurred during an auth operation
  bool get hasError => _hasError;

  /// Human-readable error message (for UI display)
  String? get errorMessage => _errorMessage;

  AuthProvider(SupabaseClient client) : _client = client {
    init();
  }

  /// Initialize: load existing session from storage and set up state stream.
  void init() {
    final client = _client;
    if (client == null) return;
    _loading = true;
    notifyListeners();

    // Load initial user
    _user = client.auth.currentUser;

    // Listen for auth state changes (sign-in, sign-out, token refresh, etc.)
    client.auth.onAuthStateChange.listen((AuthState state) {
      _user = state.session?.user;
      _loading = false;
      _hasError = false;
      _errorMessage = null;

      // Check if email needs verification
      final user = state.session?.user;
      _emailVerified = user != null && user.emailConfirmedAt != null;

      notifyListeners();
    }).onError((error) {
      _hasError = true;
      _errorMessage = 'Auth stream error: $error';
      _loading = false;
      notifyListeners();
    });

    // Finalize loading state after this event loop tick
    Future.microtask(() {
      if (_loading) {
        _loading = false;
        notifyListeners();
      }
    });
  }

  /// Sign up a new user with email and password
  Future<void> signUp({required String email, required String password}) async {
    final client = _client;
    if (client == null) return _demoAction();
    _resetErrorState();
    _loading = true;
    notifyListeners();

    try {
      await client.auth.signUp(
        email: email,
        password: password,
      );
      _user = client.auth.currentUser;
    } catch (e) {
      _handleSupabaseError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Existing user signs in with email/password
  Future<void> signIn({required String email, required String password}) async {
    final client = _client;
    if (client == null) return _demoAction();
    _resetErrorState();
    _loading = true;
    notifyListeners();

    try {
      await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _user = client.auth.currentUser;
    } catch (e) {
      _handleSupabaseError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Signs out the current user and clears secure storage
  Future<void> signOut() async {
    final client = _client;
    if (client == null) return _demoAction();
    _resetErrorState();
    _loading = true;
    notifyListeners();

    try {
      await client.auth.signOut();
      _user = null;
    } catch (e) {
      _user = null;
      _handleSupabaseError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Sends a password reset link to the provided email
  Future<void> forgotPassword(String email) async {
    final client = _client;
    if (client == null) return _demoAction();
    _resetErrorState();
    _loading = true;
    notifyListeners();

    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      _handleSupabaseError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Resets the user's password using a token from the reset email.
  ///
  /// **IMPORTANT**: This method requires the OTP token extracted from the
  /// reset email deep link (e.g., https://app.golfie.app/reset?token=xyz).
  /// The flow should be:
  ///   1. User clicks reset link in app → app opens with token in URL
  ///   2. Token extracted and passed to this method
  ///   3. First sign in with OTP: `_client.auth.signInWithOtp(token)`
  ///   4. Then update password: `_client.auth.updateUser(UserAttributes(password:))`
  Future<void> resetPassword({required String email, required String newPassword, required String token}) async {
    final client = _client;
    if (client == null) return _demoAction();
    _resetErrorState();
    _loading = true;
    notifyListeners();

    try {
      // Step 1: Verify the OTP token from the reset link
      await client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );

      // Step 2: Update password after successful verification
      final userUpdate = UserAttributes(password: newPassword);
      await client.auth.updateUser(userUpdate);

      _user = client.auth.currentUser;
    } catch (e) {
      _handleSupabaseError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Demo-mode no-op for auth actions when Supabase is unavailable.
  Future<void> _demoAction() async {
    _errorMessage = 'Auth unavailable — set SUPABASE_URL and SUPABASE_ANON_KEY to enable.';
    _hasError = true;
    notifyListeners();
  }

  /// Internal method to convert Supabase errors into user-friendly messages
  void _handleSupabaseError(dynamic e) {
    _hasError = true;

    if (e is AuthException) {
      switch (e.code) {
        case 'invalid_credentials':
          _errorMessage = 'Invalid email or password.';
          break;
        case 'email_exists':
          _errorMessage = 'Account with this email already exists.';
          break;
        case 'not_found':
          _errorMessage = 'No account with this email found.';
          break;
        case 'weak_password':
          _errorMessage = 'Password is too weak. Try something longer and more complex.';
          break;
        case 'rate_limit_exceeded':
          _errorMessage = 'Too many requests. Please try again later.';
          break;
        default:
          _errorMessage ??= e.message;
      }
    } else if (e is String) {
      _errorMessage = e;
    } else {
      _errorMessage = 'Network error. Please check your connection and try again.';
    }
  }

  /// Clears any previous error state before a new operation
  void _resetErrorState() {
    _hasError = false;
    _errorMessage = null;
  }

  /// Checks if the user is currently authenticated
  bool get isAuthenticated => _user != null;

  /// Checks if the user's email is set
  bool get isEmailVerified => _user?.email != null;

  /// Checks if the user's email has been confirmed via verification link
  bool get emailConfirmed => _emailVerified;

  /// Private state for email confirmation tracking
  bool _emailVerified = false;
}