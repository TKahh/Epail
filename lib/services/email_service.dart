
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:firebase_auth/firebase_auth.dart';

class EmailService {
  Future<void> sendEmail(
      String fromPhone,
      List<String> toPhones,
      String subject,
      String body,
      List<String> ccPhones,
      List<String> bccPhones) async {
    await FirebaseFirestore.instance.collection('emails').add({
      'from': fromPhone,
      'to': toPhones,
      'cc': ccPhones,
      'bcc': bccPhones,
      'subject': subject,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'isTrashed': false,
      'labels': ['inbox'],
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
