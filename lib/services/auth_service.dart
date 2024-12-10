import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/encryption_utils.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String normalizePhone(String phone) {
    if (phone.startsWith('+')) {
      return phone;
    } else if (phone.startsWith('0')) {
      return '+84${phone.substring(1)}';
    }
    throw const FormatException('Invalid phone number format');
  }

  // send OTP
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'OTP verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          onCodeSent(verificationId); // For timeout cases
        },
        timeout: const Duration(seconds: 30),
      );
    } catch (e) {
      onError('Failed to send OTP: $e');
    }
  }

  // verify OTP and register
  Future<void> verifyOtpAndRegister({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
    required String encryptedPassword,
    required Function onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      final normalizedPhone = normalizePhone(phoneNumber);

      // verify OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);

      // Save user info into Firestore
      // final userId = _auth.currentUser?.phoneNumber;
      // if (userId == null) {
      //   throw FirebaseAuthException(code: 'no-user', message: 'User not found');
      // }
      await _firestore.collection('users').doc(normalizedPhone).set({
        'phone': normalizedPhone,
        'password': encryptedPassword,
        'name': 'User $phoneNumber',
        'profilePictureBase64': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      onSuccess();
    } catch (e) {
      onError('Registration failed: $e');
    }
  }

  Future<void> resendOTP({required String phoneNumber}) async {
    await sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {},
      onError: (error) {
        throw Exception('Failed to resend OTP: $error');
      },
    );
  }

  // Login
  Future<void> signIn({
    required String phoneNumber,
    required String enteredPassword,
    required Function onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      final normalizedPhone = normalizePhone(phoneNumber);
      // Take user info Firestore
      final userSnapshot =
          await _firestore.collection('users').doc(normalizedPhone).get();

      if (!userSnapshot.exists) {
        throw Exception('No user found for this phone number.');
      }

      final userData = userSnapshot.data();
      final storedEncryptedPassword = userData?['password'];

      // check password
      final decryptedPassword =
          EncryptionUtils.decryptPassword(storedEncryptedPassword);
      if (decryptedPassword != enteredPassword) {
        throw Exception('Wrong password provided.');
      }
      print('Normalized phone: $normalizedPhone');
      print('User exists: ${userSnapshot.exists}');
      print('Stored password: $storedEncryptedPassword');
      onSuccess();
    } catch (e) {
      onError('Login failed: $e');
    }
  }
  // Future<void> signInWithOtp({
  //   required String verificationId,
  //   required String smsCode,
  //   required Function onSuccess,
  //   required Function(String error) onError,
  // }) async {
  //   try {
  //     final credential = PhoneAuthProvider.credential(
  //       verificationId: verificationId,
  //       smsCode: smsCode,
  //     );
  //     await _auth.signInWithCredential(credential);
  //     onSuccess();
  //   } catch (e) {
  //     onError('Login failed: $e');
  //   }
  // }
}
