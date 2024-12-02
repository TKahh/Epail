import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Text(
                    'EPOIL',
                    style: TextStyle(
                      fontSize: 90,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Itim',
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 10
                        ..color = Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'EPOIL',
                    style: TextStyle(
                      fontSize: 90,
                      fontFamily: 'Itim',
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 70,
                child: ElevatedButton(
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: const BorderSide(color: Colors.black)))),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                  },
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(
                      fontSize: 40,
                      fontFamily: 'Itim',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                height: 70,
                child: ElevatedButton(
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: const BorderSide(color: Colors.black)))),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen()));
                  },
                  child: const Text(
                    'REGISTER',
                    style: TextStyle(
                      fontSize: 40,
                      fontFamily: 'Itim',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
