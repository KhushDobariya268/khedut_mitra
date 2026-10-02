import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/app_state.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    await FirestoreService().seedInitialDataIfEmpty();
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }
  runApp(const KhedutMitraApp());
}

class KhedutMitraApp extends StatefulWidget {
  const KhedutMitraApp({super.key});

  @override
  State<KhedutMitraApp> createState() => _KhedutMitraAppState();
}

class _KhedutMitraAppState extends State<KhedutMitraApp> {
  final AppState _state = AppState();

  static const Color leafGreen = Color(0xFF2E7D32);
  static const Color paleGreen = Color(0xFFE8F5E9);
  static const Color earthYellow = Color(0xFFF9A825);

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: 'Khedut Mitra',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: leafGreen,
            primary: leafGreen,
            secondary: earthYellow,
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: paleGreen,
          fontFamily: 'Roboto',
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontSize: 18),
            bodyMedium: TextStyle(fontSize: 16),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: leafGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const WelcomeScreen(),
      ),
    );
  }
}
