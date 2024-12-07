// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'main_screen.dart';
// import '../utils/encryption_utils.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }


  Future<void> _signIn() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);
    final authService = AuthService();

    await authService.signIn(
      phoneNumber: _phoneController.text,
      enteredPassword: _passwordController.text,
      onSuccess: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
        _showSnackbar('Login Successful');
      },
      onError: (error) {
        _showSnackbar(error);
      },
    );

    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.red),
        ),
        title: const Text(
          'LOGIN',
          style: TextStyle(
            fontSize: 50,
            fontFamily: 'Itim',
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 100, left: 100, right: 100),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 200),
              // PHONE
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number.';
                  }
                  if (!RegExp(r'^[0-9]{10,}$').hasMatch(value)) {
                    return 'Enter a valid phone number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // PASSWORD
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 36),
              Center(
                child: SizedBox(
                  height: 50,
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _signIn();
                      }
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'Itim',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading) const Center(child: CircularProgressIndicator()),

              Center(
                child: TextButton(
                  onPressed: () {
                    // Điều hướng đến màn hình "Forgot Password"
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
