import 'package:cloud_firestore/cloud_firestore.dart';

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
    return FirebaseFirestore.instance
        .collection('emails')
        .where('to', arrayContains: phone)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
