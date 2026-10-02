import 'package:flutter/material.dart';
import 'translations.dart';

/// Holds the currently selected language ('gu' or 'en') and notifies
/// listeners so the whole app rebuilds instantly on toggle — no
/// app restart needed.
class AppState extends ChangeNotifier {
  String _lang = 'gu'; // Gujarati is the default language

  String get lang => _lang;

  void setLanguage(String lang) {
    if (_lang != lang) {
      _lang = lang;
      notifyListeners();
    }
  }

  void toggle() {
    setLanguage(_lang == 'gu' ? 'en' : 'gu');
  }

  String t(String key) => AppText.t(_lang, key);
}

/// Simple InheritedNotifier so any widget in the tree can read/update
/// the language with `AppScope.of(context)` without extra packages.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in context');
    return scope!.notifier!;
  }
}
