import 'package:cloud_firestore/cloud_firestore.dart';

class EmailService {
  // sample email tets
  Future<void> addSampleEmail() async {
    await FirebaseFirestore.instance.collection('emails').add({
      'from': 'UID_sender',
      'to': ['UID_reciever'],
      'subject': 'Welcome to EPAIL!',
      'body': 'This is my first mail. Please concid.',
      'attachments': [],
      'timestamp': FieldValue.serverTimestamp(),
      'labels': ['welcome'],
      'isRead': false,
      'isDraft': false,
    });
  }
}
