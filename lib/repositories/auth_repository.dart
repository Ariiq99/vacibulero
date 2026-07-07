import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

// ── REPOSITORY: AuthRepository ─────────────────────────────────
// Mengelola semua operasi autentikasi menggunakan Supabase Auth.
// Login, Register, Logout, dan stream status auth.
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  // ── Cek user yang sedang login ──
  AppUser? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
    );
  }

  bool get isLoggedIn => _client.auth.currentUser != null;

  // ── Stream perubahan status auth ──
  Stream<AuthState> get authStateStream => _client.auth.onAuthStateChange;

  // ── REGISTER: daftar dengan email + password ──
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );

    if (res.user == null) {
      throw Exception('Pendaftaran gagal. Silakan coba lagi.');
    }

    return AppUser(
      id: res.user!.id,
      email: res.user!.email ?? email,
      displayName: displayName,
    );
  }

  // ── LOGIN: masuk dengan email + password ──
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.user == null) {
      throw Exception('Email atau password salah.');
    }

    return AppUser(
      id: res.user!.id,
      email: res.user!.email ?? email,
      displayName: res.user!.userMetadata?['display_name'] as String?,
    );
  }

  // ── LOGOUT ──
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ── RESET PASSWORD ──
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
}
