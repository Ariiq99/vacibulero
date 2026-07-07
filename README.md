# Vacibulero 🏴

> **English Vocabulary Learning App — v2**
> Flutter MVVM + Authentication + Indonesian Definitions + Redesigned UI

---

## 📋 Overview

Vacibulero adalah aplikasi mobile belajar kosakata bahasa Inggris yang
berpusat pada *self-improvement* pengguna, dibangun dengan Flutter
menggunakan arsitektur **MVVM (Model-View-ViewModel)**.

### Fitur Utama
- 🏴 **Word Treasury** — bank kosakata pribadi dengan CRUD
- 🗺️ **Word Expedition** — eksplorasi kata bertema dengan flip card
- ✅ **Treasure Check!** — kuis adaptif untuk menguji hafalan
- 🔐 **Autentikasi** — login & register dengan Supabase Auth *(baru di v2)*

---

## 🆕 Apa yang Baru di v2

Update ini merupakan respons langsung terhadap catatan review dosen pada
tahap pengembangan sebelumnya:

| Catatan Dosen | Implementasi |
|---|---|
| Definisi kata masih Bahasa Inggris | `DictionaryRepository` kini menerjemahkan definisi & contoh kalimat ke Bahasa Indonesia via MyMemory API |
| Tambahkan sistem auth | Supabase Auth terintegrasi penuh — Login, Register, Auth Gate |
| Interface terlalu sederhana | Redesign total terinspirasi Duolingo — biru dominan, minimalist namun interaktif |

### Detail Perubahan

**1. Definisi Bahasa Indonesia**
`DictionaryRepository.lookup()` kini mengirim 3 request paralel ke MyMemory API:
terjemahan kata, terjemahan definisi, dan terjemahan contoh kalimat. Model
`WordItem` diperluas dengan field `definitionEN`, `definitionID`, dan
`exampleID`, dengan getter `definition` yang otomatis fallback ke versi
Inggris jika terjemahan tidak tersedia.

**2. Sistem Autentikasi**
Ditambahkan layer auth lengkap: `AppUser` (model), `AuthRepository`
(operasi Supabase Auth), `AuthViewModel` (state management), serta tiga
layar baru — `AuthGate` (penjaga rute), `LoginScreen`, dan `RegisterScreen`.
`AuthGate` dipasang sebagai halaman pertama di GoRouter dan secara otomatis
menampilkan Login atau Home tergantung status sesi pengguna.

**3. Redesign UI/UX**
Dibangun design system baru di `services/app_theme.dart` (`VaciColors`,
`VaciTheme`, `VaciCard`, `VaciButton`, `WordTypeBadge`) dengan palet biru
dominan + aksen gold, rounded card dengan shadow halus, custom bottom
navigation, `SliverAppBar` dengan greeting personalisasi, dan empty state
bertema treasure yang lebih ekspresif.

---

## 🏗️ MVVM Pattern Overview

```
┌─────────────────────────────────────────────────────────┐
│                        VIEW                              │
│  (Flutter Widgets — Consumer<ViewModel>)                 │
│  login_screen · treasury_screen · expedition_screen ...  │
└───────────────────┬────────────────────┬─────────────────┘
                     │ watch/read         │ notifyListeners()
┌────────────────────▼────────────────────▼─────────────────┐
│                     VIEWMODEL                              │
│  (ChangeNotifier — state & business logic)                 │
│  AuthViewModel · TreasuryViewModel · ExpeditionViewModel ..│
└────────────────────┬────────────────────────────────────────┘
                     │ calls
┌────────────────────▼────────────────────────────────────────┐
│                      MODEL                                   │
│  AppUser · WordItem · ExpeditionTheme · QuizSession           │
│  AuthRepository · WordRepository · DictionaryRepository ...  │
└────────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
lib/
├── main.dart                          # Entry point + Supabase init + MultiProvider
├── router/
│   └── app_router.dart                # GoRouter — AuthGate sebagai initial route
├── services/
│   └── app_theme.dart                 # Design system (colors, theme, reusable widgets)
├── models/
│   ├── app_user.dart                  # [BARU] Model user terautentikasi
│   ├── word_item.dart                 # [UPDATE] + definitionEN/ID, exampleID
│   ├── expedition_models.dart
│   └── quiz_models.dart
├── repositories/
│   ├── auth_repository.dart           # [BARU] Operasi Supabase Auth
│   ├── dictionary_repository.dart     # [UPDATE] Terjemahan definisi ke ID
│   ├── word_repository.dart
│   ├── expedition_repository.dart
│   └── quiz_repository.dart
├── viewmodels/
│   ├── auth_viewmodel.dart            # [BARU] State autentikasi
│   ├── treasury_viewmodel.dart
│   ├── add_word_viewmodel.dart        # [UPDATE] buildWordItem() field baru
│   ├── expedition_viewmodel.dart      # [UPDATE] WordItem field baru
│   └── quiz_viewmodel.dart
└── views/
    └── screens/
        ├── auth_gate.dart             # [BARU] Penjaga rute login/home
        ├── login_screen.dart          # [BARU]
        ├── register_screen.dart       # [BARU]
        ├── home_screen.dart           # [REDESIGN] SliverAppBar, stats, nav baru
        ├── treasury_screen.dart       # [REDESIGN] Header biru, stats, card baru
        ├── add_word_screen.dart       # [REDESIGN] Tampilan definisi EN/ID terpisah
        ├── expedition_screen.dart
        ├── flip_card_screen.dart
        ├── quiz_screen.dart
        └── quiz_result_screen.dart
test/
├── quiz_repository_test.dart          # 19 test cases
└── word_item_test.dart                # [UPDATE] 25 test cases (+ field baru, backward compat)
assets/
└── data/
    └── expedition_content.json
SUPABASE_SETUP.md                       # [BARU] Panduan setup Supabase
```

---

## 🚀 How to Run

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Akun Supabase (gratis) — lihat `SUPABASE_SETUP.md` untuk panduan lengkap

### Steps

```bash
# 1. Clone repository
git clone https://github.com/Ariiq99/vacibulero.git
cd vacibulero

# 2. Install dependencies
flutter pub get

# 3. Setup Supabase — ikuti SUPABASE_SETUP.md
#    lalu isi _supabaseUrl dan _supabaseAnonKey di lib/main.dart

# 4. Run the application
flutter run

# 5. Jalankan unit test
flutter test --reporter expanded
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.2 | State management (MVVM) |
| `go_router` | ^13.2.0 | Navigation |
| `http` | ^1.2.1 | Dictionary & Translation API |
| `shared_preferences` | ^2.2.3 | Local persistence (Word Treasury, Expedition progress) |
| `supabase_flutter` | ^2.5.6 | **[BARU]** Autentikasi (Login/Register) |

---

## 🔌 External APIs

| API | Endpoint | Purpose |
|---|---|---|
| Free Dictionary | `api.dictionaryapi.dev` | Definisi EN, fonetik, jenis kata |
| MyMemory | `api.mymemory.translated.net` | Terjemahan kata, **definisi**, dan **contoh kalimat** ke ID |
| Supabase Auth | *(self-hosted via project)* | Login, Register, session management |

---

## 💡 Reflection

Iterasi kedua proyek ini diarahkan langsung oleh masukan dosen pembimbing,
yang memberikan pengalaman berharga tentang bagaimana feedback eksternal
membentuk arah pengembangan produk secara nyata.

Tantangan teknis terbesar adalah memastikan perubahan struktur `WordItem`
(memecah `definition` menjadi `definitionEN` dan `definitionID`) tidak
merusak kode yang sudah ada di berbagai layer — mulai dari repository,
ViewModel, hingga unit test. Hal ini menegaskan pentingnya arsitektur MVVM:
karena setiap layer terisolasi dengan baik, perubahan pada Model bisa
ditelusuri secara sistematis ke semua tempat yang bergantung padanya, tanpa
menimbulkan efek samping yang tidak terduga di UI.

Implementasi auth juga mengajarkan pentingnya pola *Auth Gate* — sebuah
widget sederhana yang mendengarkan status autentikasi dan secara otomatis
mengarahkan pengguna ke halaman yang sesuai, tanpa perlu logika kondisional
yang tersebar di banyak tempat.

---

## Author

- **Name:** Muhammad Ariiq Ariadanang
- **Student ID:** 0706012414004
- **Course:** Mobile Application Development
- **Institution:** Universitas Ciputra

---
