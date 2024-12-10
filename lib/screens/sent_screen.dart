import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urmail/screens/email_detail_screen.dart';

class SentScreen extends StatefulWidget {
  const SentScreen({super.key});

  @override
  State<SentScreen> createState() => _SentScreenState();
}

class _SentScreenState extends State<SentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> _getSentEmails() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream
          .empty(); // Return an empty stream if no user is logged in
    }

    return _firestore
        .collection('emails')
        .where('from', isEqualTo: user.email) // Filter by current user's email
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    void _showPopupMenu(BuildContext context, DocumentSnapshot emailDoc) {
      showMenu(
        context: context,
        position: const RelativeRect.fromLTRB(10.0, 10.0, 10.0, 10.0),
        items: [
          PopupMenuItem(
            child: const Text('Move to Trash'),
            onTap: () {
              emailDoc.reference.update({'isTrashed': true});
            },
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SENT EMAILS',
          style: TextStyle(
            fontSize: 50,
            fontFamily: 'Itim',
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getSentEmails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Opacity(
                opacity: 0.5,
                child: Text(
                  'No sent emails found',
                  style: TextStyle(
                    fontSize: 50,
                  ),
                ),
              ),
            );
          }

          final emails = snapshot.data!.docs;

          return ListView.builder(
            itemCount: emails.length,
            itemBuilder: (context, index) {
              final email = emails[index].data() as Map<String, dynamic>;
              final emailDoc = emails[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    email['subject'] ?? 'No Subject',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('To: ${email['to'] ?? 'Unknown'}'),
                      const SizedBox(height: 5),
                      Text(
                        email['body'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: Text(
                    (email['timestamp'] as Timestamp).toDate().toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmailDetailScreen(
                          email: email,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    _showPopupMenu(context, emailDoc);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
