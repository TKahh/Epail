import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../utils/encryption_utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  String _verificationId = '';
  bool _isOtpSent = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+84${_phoneController.text}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          _showSnackBar('Phone verified automatically');
        },
        verificationFailed: (FirebaseAuthException e) {
          _showSnackBar('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 30), // Time wait for OTP
      );
    } catch (e) {
      _showSnackBar('Failed to send OTP: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

// Verify OTP and then proceed
  Future<void> _verifyOtpAndRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      //Verify OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      // encrypt password
      final encryptedPassword =
          EncryptionUtils.encryptPassword(_passwordController.text);
      // print("Registering password: ${_passwordController.text}");
      // print("Encrypted Password: $encryptedPassword");

      // Save phone and password to Firestore
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw FirebaseAuthException(code: 'no-user', message: 'User not found');
      }
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'phone': _phoneController.text,
        'password': encryptedPassword, // encrypted password
        'name':
            'User ${_phoneController.text}', // Default name, can ask for user input
        'profilePicture': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // move to login screen when register successfully
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

      _showSnackBar('Registration Successful');
    } catch (e) {
      _showSnackBar('Verification failed: $e');
    } finally {
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
          'REGISTER',
          style: TextStyle(
            fontSize: 50,
            fontFamily: 'Itim',
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 200,
              ),
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
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^[0-9]{10,}$').hasMatch(value)) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              // PASSWORD
              const SizedBox(height: 16),
              if (_isOtpSent)
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'OTP Field',
                    border: OutlineInputBorder(),
                  ),
                ),

              if (_isOtpSent) ...[
                const SizedBox(height: 16),
                _buildPasswordField('Password', _passwordController),
                const SizedBox(height: 16),
                _buildPasswordField('Confirm Password',
                    _confirmPasswordController, _passwordController)
              ],

              const SizedBox(height: 36),
              Center(
                child: SizedBox(
                  height: 50,
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _isOtpSent ? _verifyOtpAndRegister : _sendOtp,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isOtpSent ? 'Register' : 'Send OTP',
                            style: const TextStyle(
                                fontSize: 30, fontFamily: 'Itim'),
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

  Widget _buildPasswordField(String label, TextEditingController controller,
      [TextEditingController? matchController]) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        if (label == 'Password' && value.length < 8) {
          return 'Password must be at least 8 characters long';
        }
        if (matchController != null && value != matchController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
