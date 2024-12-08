import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
     options: const FirebaseOptions(
       apiKey: "AIzaSyA7TMJKOAPZIA2JMjW5dQVeg1LrRUqUjiU",
       projectId: "epail-d3fef",
       appId: "1:175272769832:web:69fdd7f23cca999a38781d",
       messagingSenderId: "175272769832",
  )
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
  }

  // Load Dark Mode preference from SharedPreferences
  void _loadDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkModeEnabled') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _darkMode ? ThemeData.dark() : ThemeData.light(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            //return const MainScreen(); // Navigate to MainScreen if logged in
            return const SettingsScreen(); // Or a login screen if needed
          } else {
            return const SettingsScreen(); // Or a login screen if needed
          }
        },
      ),
    );
  }
}
