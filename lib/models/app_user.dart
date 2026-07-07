// ── MODEL: AppUser ─────────────────────────────────────────────
// Merepresentasikan data pengguna yang sudah login.
// Dibuat terpisah dari Supabase User agar tidak tightly coupled.
class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;

  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
  });

  // ── Inisial untuk avatar ──
  String get initials {
    final name = displayName ?? email;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // ── Nama tampilan ──
  String get nameOrEmail => displayName ?? email.split('@').first;

  factory AppUser.fromSupabase(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'] as String,
      email: data['email'] as String,
      displayName: data['display_name'] as String?,
      avatarUrl: data['avatar_url'] as String?,
    );
  }
}
