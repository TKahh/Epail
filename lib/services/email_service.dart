import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

class EmailService {
  Future<void> sendEmail(
    String fromPhone,
    List<String> toPhones,
    String subject,
    String body, {
    List<File>? attachments,
  }) async {
    final List<Map<String, dynamic>> attachmentData = [];
    if (attachments != null && attachments.isNotEmpty) {
      for (File file in attachments) {
        final bytes = await file.readAsBytes();
        final encodedFile = base64Encode(bytes);
        attachmentData.add({
          'fileName': file.path.split('/').last,
          'fileContent': encodedFile,
        });
      }
    }
    await FirebaseFirestore.instance.collection('emails').add({
      'from': fromPhone,
      'to': toPhones,
      'subject': subject,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'isTrashed': false,
      'labels': ['inbox'],
      'attachments': attachmentData,
    });
  }

  Stream<QuerySnapshot> getEmails(String phone) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('emails')
        .where('from', arrayContains: phone)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
