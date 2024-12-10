import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/main_screen.dart';
import 'firebase_options.dart';
// import 'utils/phone_normalization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print("User is currently signed out.");
    } else {
      print("User is signed in: ${user.uid}");
    }
  });
  // await normalizePhoneNumbers();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
          ),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          User? currentUser = FirebaseAuth.instance.currentUser;

          // Check if user is logged in or not
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (currentUser == null) {
            print("No user is logged in");
            return const HomeScreen();
          } else {
            print("Logged in as: ${currentUser.uid}");
            return const MainScreen();
          }
        },
      ),
    );
  }
}
