import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final dynamic _repo;

  AuthViewModel(this._repo) {
    _checkInitialAuth();
    _initAuthStream();
  }

  AuthStatus _status = AuthStatus.initial;
  AppUser? _user;
  String? _error;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // PERBAIKAN UTAMA: Proteksi berlapis terhadap object null di web compiler
  void _initAuthStream() {
    try {
      if (_repo != null) {
        final dynamic stream = _repo.authStateStream ?? _repo.onAuthStateChange;
        if (stream != null) {
          stream.listen((dynamic state) => _checkInitialAuth());
        }
      }
    } catch (_) {}
  }

  void _checkInitialAuth() {
    try {
      if (_repo == null) {
        _status = AuthStatus.unauthenticated;
        return;
      }
      final dynamic currentUserData = _repo.currentUser;
      if (currentUserData != null) {
        _user = AppUser(
          id: currentUserData.id?.toString() ?? '',
          email: currentUserData.email?.toString() ?? '',
          displayName:
              currentUserData.userMetadata?['display_name']?.toString(),
        );
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading();
    try {
      // PERBAIKAN: Mengubah named arguments menjadi positional arguments sesuai struktur AuthRepository
      final dynamic result = await _repo.signUp(
        email,
        password,
      );

      if (result != null) {
        _user = AppUser(
          id: result.id?.toString() ?? '',
          email: result.email?.toString() ?? email,
          displayName: displayName,
        );
      }

      _status = AuthStatus.authenticated;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _localizeAuthError(e);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      // PERBAIKAN: Mengubah named arguments menjadi positional arguments sesuai struktur AuthRepository
      final dynamic result = await _repo.signIn(
        email,
        password,
      );

      if (result != null) {
        _user = AppUser(
          id: result.id?.toString() ?? '',
          email: result.email?.toString() ?? email,
          displayName: result.userMetadata?['display_name']?.toString(),
        );
      }

      _status = AuthStatus.authenticated;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _localizeAuthError(e);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _repo.signOut();
    } catch (_) {}
    _user = null;
    _status = AuthStatus.unauthenticated;
    _error = null;
    notifyListeners();
  }

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

  String _localizeAuthError(Object e) {
    final errorStr = e.toString().toLowerCase();
    if (errorStr.contains('invalid login credentials')) {
      return 'Email atau password salah. Silakan periksa kembali.';
    } else if (errorStr.contains('already in use') ||
        errorStr.contains('already exists')) {
      return 'Email sudah terdaftar. Silakan gunakan email lain atau langsung login.';
    } else if (errorStr.contains('at least 6 characters')) {
      return 'Password terlalu pendek. Minimal terdiri dari 6 karakter.';
    } else if (errorStr.contains('invalid email') ||
        errorStr.contains('bad email')) {
      return 'Format penulisan email tidak valid.';
    }
    return e
        .toString()
        .replaceAll('Exception: ', '')
        .replaceAll('AuthException: ', '');
  }
}
