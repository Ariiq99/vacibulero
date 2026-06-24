# Vacibulero 🏴

> **AI-Powered English Vocabulary Learning App**  
> Flutter MVVM Architecture Assignment — Sesi 7

---

## 📋 Overview

Vacibulero is a mobile application for learning English vocabulary, built using Flutter with the **MVVM (Model-View-ViewModel)** architectural design pattern. The app features three core modules:

- 🏴 **Word Treasury** — Personal vocabulary bank with CRUD operations
- 🗺️ **Word Expedition** — Themed vocabulary exploration with flip cards
- ✅ **Treasure Check!** — Adaptive quiz system to test retention

---

## 🏗️ MVVM Pattern Overview

MVVM separates the application into three distinct layers:

```
┌─────────────────────────────────────────────────────────┐
│                        VIEW                             │
│  (Flutter Widgets — Consumer<ViewModel>)                │
│  treasury_screen · expedition_screen · quiz_screen      │
└───────────────────┬────────────────────┬────────────────┘
                    │ watch/read         │ notifyListeners()
┌───────────────────▼────────────────────▼────────────────┐
│                     VIEWMODEL                           │
│  (ChangeNotifier — manages state & business logic)      │
│  TreasuryViewModel · ExpeditionViewModel · QuizViewModel│
└───────────────────┬─────────────────────────────────────┘
                    │ calls
┌───────────────────▼─────────────────────────────────────┐
│                      MODEL                              │
│  (Entity classes + Repository — data operations)        │
│  WordItem · ExpeditionTheme · QuizSession               │
│  WordRepository · DictionaryRepository · QuizRepository │
└─────────────────────────────────────────────────────────┘
```

### Components

| Layer | Role | Files |
|---|---|---|
| **Model** | Data classes and CRUD operations | `lib/models/`, `lib/repositories/` |
| **ViewModel** | State management with `ChangeNotifier` | `lib/viewmodels/` |
| **View** | UI widgets using `Consumer<VM>` | `lib/views/screens/` |

### Key Concepts

- **`ChangeNotifier`** — ViewModel base class; calls `notifyListeners()` when state changes
- **`Consumer<VM>`** — View widget that rebuilds when the ViewModel notifies
- **`MultiProvider`** — Provides all ViewModels to the entire widget tree
- **`context.read<VM>()`** — Call ViewModel methods without subscribing to changes
- **`context.watch<VM>()`** — Subscribe to ViewModel changes in build method

---

## 📁 Project Structure

```
lib/
├── main.dart                        # Entry point + MultiProvider setup
├── router/
│   └── app_router.dart              # GoRouter configuration
├── models/
│   ├── word_item.dart               # WordItem entity + WordType enum
│   ├── expedition_models.dart       # ExpeditionTheme, Level, Progress
│   └── quiz_models.dart             # QuizQuestion, QuizAnswer, QuizSession
├── repositories/
│   ├── word_repository.dart         # CRUD — SharedPreferences
│   ├── dictionary_repository.dart   # Free Dictionary API + MyMemory API
│   ├── expedition_repository.dart   # JSON asset loader + progress storage
│   └── quiz_repository.dart         # Quiz generation + evaluation
├── viewmodels/
│   ├── treasury_viewmodel.dart      # State for Word Treasury
│   ├── add_word_viewmodel.dart      # State for Add Word screen
│   ├── expedition_viewmodel.dart    # State for Word Expedition
│   └── quiz_viewmodel.dart          # State for Treasure Check!
└── views/
    └── screens/
        ├── home_screen.dart         # Bottom nav hub
        ├── treasury_screen.dart     # Word Treasury UI
        ├── add_word_screen.dart     # Search & save new word
        ├── expedition_screen.dart   # Theme & level list
        ├── flip_card_screen.dart    # Flip card session
        ├── quiz_screen.dart         # Quiz questions
        └── quiz_result_screen.dart  # Session summary
assets/
└── data/
    └── expedition_content.json      # Local word content (3 themes × 3 levels)
```

---

## 🚀 How to Run

### Prerequisites
- Flutter SDK ≥ 3.0.0 — [Install Flutter](https://docs.flutter.dev/get-started/install)
- Android emulator, iOS simulator, or physical device

### Steps

```bash
# 1. Clone this repository
git clone https://github.com/<your-username>/vacibulero.git
cd vacibulero

# 2. Install dependencies
flutter pub get

# 3. Run the application
flutter run
```

### Build for release

```bash
# Android APK
flutter build apk --release

# iOS (requires macOS + Xcode)
flutter build ios --release
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.2 | State management (MVVM ChangeNotifier) |
| `go_router` | ^13.2.0 | Declarative navigation |
| `http` | ^1.2.1 | HTTP requests to Dictionary & Translation APIs |
| `shared_preferences` | ^2.2.3 | Local data persistence |

---

## 🔌 External APIs

| API | Endpoint | Purpose |
|---|---|---|
| Free Dictionary | `https://api.dictionaryapi.dev/api/v2/entries/en/{word}` | English definitions, phonetics, examples |
| MyMemory | `https://api.mymemory.translated.net/get?q={word}&langpair=en\|id` | English → Indonesian translation |

Both APIs are **free** and require no API key.

---

## 💡 Reflection

Working on this assignment gave me a deep understanding of why architectural patterns like MVVM matter in real-world mobile development.

Before this, I wrote all logic directly inside Flutter widgets, which made the code messy and hard to maintain. With MVVM, I learned how to cleanly separate concerns: the **Model** layer handles raw data and persistence through repositories, the **ViewModel** layer manages state and business logic independently of the UI, and the **View** layer simply observes and reacts to changes through `Consumer` widgets.

The most challenging part was understanding the `ChangeNotifier` lifecycle — specifically when to call `notifyListeners()` and how to avoid unnecessary rebuilds by using `context.read` for actions and `context.watch` or `Consumer` for state subscriptions. Another challenge was managing async operations correctly in ViewModels while keeping loading and error states in sync with the UI.

The biggest takeaway is that MVVM makes code testable and scalable. Each ViewModel can be tested independently without the UI, which is a huge advantage as the app grows. I also appreciated how Provider's `MultiProvider` made dependency injection clean and explicit.

---

## 👨‍💻 Author

- **Name:** Muhammad Ariiq Ariadanang
- **Student ID:** 0706012414004
- **Course:** Mobile Application Development
- **Institution:** Ciputra University

---
