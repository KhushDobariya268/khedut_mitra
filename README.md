# Khedut Mitra (ખેડૂત મિત્ર)

A static, 4-screen bilingual (Gujarati / English) demo of a farmer assistant
app, built in Flutter. All data (market prices, weather, chatbot reply) is
hardcoded — there is no backend or API call — so it runs immediately with
no setup beyond the Flutter SDK.

## Screens

1. **Welcome / Language Select** — pick ગુજરાતી or English, saved for the session.
2. **Home Dashboard** — weather summary card + 6-feature grid, with a
   language-switch pill in the top-right app bar that instantly re-renders
   every string on screen (no restart).
3. **Market Prices** — a static list of 5 crops (Cotton, Groundnut, Wheat,
   Bajra, Onion) with min/max/average price and day-over-day change.
4. **AI Farmer Assistant** — a static chat screen; tapping the input loads
   a sample bilingual Q&A (whitefly-in-cotton example from the spec).

## Project structure

```
khedut_mitra/
├── pubspec.yaml
└── lib/
    ├── main.dart                     # Theme + app entry point
    ├── data/
    │   ├── translations.dart         # gu/en string lookup table
    │   └── app_state.dart            # Language state (ChangeNotifier + InheritedNotifier)
    └── screens/
        ├── welcome_screen.dart
        ├── home_screen.dart
        ├── market_prices_screen.dart
        └── ai_assistant_screen.dart
```

## How to run

1. Install the Flutter SDK: https://docs.flutter.dev/get-started/install
2. Unzip this project, then from the project root:
   ```bash
   flutter pub get
   flutter run
   ```
   (Pick a connected device/emulator, or `flutter run -d chrome` to try it
   in a browser.)

## Building an APK

```bash
flutter build apk --release
```
The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## Notes on how the language switch works

There's no external i18n package — `translations.dart` is a plain
`Map<String, Map<String, String>>` keyed by `'gu'` / `'en'`. `AppState`
(a `ChangeNotifier`) holds the current language and is exposed app-wide
via an `InheritedNotifier` (`AppScope`). Every screen wraps its body in
`AnimatedBuilder(animation: app, ...)`, so calling `app.toggle()` or
`app.setLanguage(...)` anywhere rebuilds every visible string instantly.

This keeps the demo dependency-free. To extend it into the full spec
(live market/weather APIs, a real AI backend, Firebase, ARB-based
`flutter_localizations`), swap the static data sources in
`market_prices_screen.dart`, `home_screen.dart`, and
`ai_assistant_screen.dart` for real API/service calls — the language
system itself won't need to change.
