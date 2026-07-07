import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart' hide AppUser;

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

// ── VIEWMODEL: AuthViewModel ───────────────────────────────────
// Mengelola state autentikasi untuk seluruh aplikasi.
// Dipasang di root MultiProvider agar bisa diakses dari mana saja.
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo;

  AuthViewModel(this._repo) {
    // Cek status login saat app pertama dibuka
    _checkInitialAuth();
    // Listen perubahan status auth dari Supabase
    _repo.authStateStream.listen(_onAuthStateChange);
  }

  // ── State ──
  AuthStatus _status = AuthStatus.initial;
  AppUser? _user;
  String? _error;

  // ── Getters ──
  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // ── Cek auth saat init ──
  void _checkInitialAuth() {
    final user = _repo.currentUser;
    if (user != null) {
      _user = user;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Listen stream auth dari Supabase ──
  void _onAuthStateChange(dynamic state) {
    _checkInitialAuth();
  }

  // ── REGISTER ──
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading();
    try {
      _user = await _repo.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      _status = AuthStatus.authenticated;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── LOGIN ──
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      _user = await _repo.signIn(email: email, password: password);
      _status = AuthStatus.authenticated;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── LOGOUT ──
  Future<void> signOut() async {
    await _repo.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _error = null;
    notifyListeners();
  }

  // ── Reset error ──
  void clearError() {
    _error = null;
    _status =
        _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
  }
}
