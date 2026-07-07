# Panduan Setup Supabase untuk Vacibulero v2

Dokumen ini menjelaskan langkah-langkah menyiapkan Supabase agar fitur
autentikasi (Login & Register) berfungsi.

---

## 1. Buat Project Supabase

1. Buka [supabase.com](https://supabase.com) dan login/daftar
2. Klik **New Project**
3. Isi nama project (misal: `vacibulero`), buat password database, pilih region terdekat (Singapore)
4. Tunggu beberapa menit sampai project selesai dibuat

---

## 2. Ambil URL dan Anon Key

1. Di dashboard project, buka **Project Settings** (ikon gear) → **API**
2. Salin dua nilai berikut:
   - **Project URL** → contoh: `https://xxxxxxxxxxxx.supabase.co`
   - **anon public** key → string panjang di bagian "Project API keys"

---

## 3. Masukkan ke `main.dart`

Buka `lib/main.dart`, cari baris berikut dan ganti dengan nilai kamu:

```dart
const _supabaseUrl     = 'https://YOUR_PROJECT_ID.supabase.co';
const _supabaseAnonKey = 'YOUR_ANON_KEY';
```

Menjadi (contoh):

```dart
const _supabaseUrl     = 'https://xxxxxxxxxxxx.supabase.co';
const _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

> ⚠️ **Catatan keamanan:** Anon key aman untuk disimpan di kode client karena
> dirancang untuk itu — akses sebenarnya dikontrol lewat Row Level Security (RLS).
> Namun untuk repository publik, sebaiknya gunakan environment variable
> (`--dart-define`) agar key tidak ter-expose langsung di GitHub.

---

## 4. Aktifkan Email Auth

1. Di dashboard Supabase, buka **Authentication** → **Providers**
2. Pastikan **Email** dalam keadaan **Enabled** (biasanya sudah aktif secara default)
3. (Opsional) Matikan **Confirm Email** di **Authentication → Settings** jika
   ingin testing lebih cepat tanpa perlu verifikasi email:
   - Authentication → Settings → scroll ke "Email Auth" → matikan "Enable email confirmations"

---

## 5. (Opsional) Setup Tabel Tambahan

Untuk saat ini, autentikasi sudah cukup menggunakan fitur bawaan Supabase Auth
(`auth.users`). Jika ke depannya ingin menyimpan data Word Treasury langsung
di Supabase (bukan SharedPreferences lokal), buat tabel berikut lewat
**SQL Editor**:

```sql
-- Tabel word_treasury (opsional, untuk migrasi dari local storage ke cloud)
create table word_treasury (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  word text not null,
  translation text not null,
  word_type text not null,
  definition_en text,
  definition_id text,
  example text,
  example_id text,
  phonetic text,
  added_at timestamptz default now()
);

-- Row Level Security: setiap user hanya bisa akses datanya sendiri
alter table word_treasury enable row level security;

create policy "Users can view their own words"
  on word_treasury for select
  using (auth.uid() = user_id);

create policy "Users can insert their own words"
  on word_treasury for insert
  with check (auth.uid() = user_id);

create policy "Users can delete their own words"
  on word_treasury for delete
  using (auth.uid() = user_id);
```

> Saat ini implementasi masih menggunakan **SharedPreferences lokal** untuk
> Word Treasury — auth hanya digunakan untuk login/register dan personalisasi
> tampilan (nama pengguna). Migrasi penuh ke Supabase Database bisa menjadi
> pengembangan lanjutan.

---

## 6. Jalankan Aplikasi

```bash
flutter pub get
flutter run
```

Coba daftar akun baru lewat halaman Register — jika berhasil, kamu akan
otomatis diarahkan ke Home Screen dan bisa cek user baru di
**Authentication → Users** di dashboard Supabase.

---

## Troubleshooting

| Masalah | Solusi |
|---|---|
| `AuthException: Invalid login credentials` | Pastikan email & password benar, atau cek apakah user sudah terdaftar |
| App stuck di loading screen | Cek apakah `_supabaseUrl` dan `_supabaseAnonKey` sudah diisi dengan benar |
| Error saat register: email belum dikonfirmasi | Matikan "Enable email confirmations" di Authentication Settings (lihat langkah 4) |