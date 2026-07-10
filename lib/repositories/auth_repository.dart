import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  // Constructor menerima SupabaseClient seperti di main.dart
  AuthRepository(this._supabase);

  // ── Login dengan positional parameters ──
  Future<User?> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }

  // ── Register dengan positional parameters ──
  Future<User?> signUp(String email, String password) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    return response.user;
  }

  // ── Logout ──
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ── Get current user ──
  User? get currentUser => _supabase.auth.currentUser;
}
