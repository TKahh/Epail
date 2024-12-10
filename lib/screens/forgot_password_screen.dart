import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/encryption_utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _verificationId;
  bool _isOtpSent = false;
  bool _isLoading = false;

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendOtp() async {
    final authService = AuthService();
    setState(() => _isLoading = true);

    try {
      await authService.sendOtp(
        phoneNumber: _phoneController.text,
        onCodeSent: (verificationId) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
          });
          _showSnackbar('OTP sent successfully');
        },
        onError: (error) {
          _showSnackbar(error);
        },
      );
    } catch (e) {
      print('Unknown error: $e');
      _showSnackbar('An unexpected error occurred.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtpAndResetPassword() async {
    if (_verificationId == null) {
      _showSnackbar('Verification ID is null. Please try again.');
      return;
    }

    final authService = AuthService();
    setState(() => _isLoading = true);

    try {
      final newPassword =
          EncryptionUtils.encryptPassword(_newPasswordController.text);

      // Update password in Firestore after OTP verification
      await authService.verifyOtpAndResetPassword(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
        phoneNumber: _phoneController.text,
        encryptedPassword: newPassword,
        onSuccess: () {
          _showSnackbar('Password reset successful');
          Navigator.pop(context);
        },
        onError: (error) {
          _showSnackbar(error);
        },
      );
    } catch (e) {
      print('Error: $e');
      _showSnackbar('Failed to reset password.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!_isOtpSent)
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!RegExp(r'^\+?[0-9]{11,}$').hasMatch(value)) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                )
              else
                Column(
                  children: [
                    TextFormField(
                      controller: _otpController,
                      decoration: const InputDecoration(labelText: 'Enter OTP'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the OTP';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration:
                          const InputDecoration(labelText: 'New Password'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _isOtpSent ? _verifyOtpAndResetPassword() : _sendOtp();
                    }
                  },
                  child: Text(_isOtpSent ? 'Reset Password' : 'Send OTP'),
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
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }
}
