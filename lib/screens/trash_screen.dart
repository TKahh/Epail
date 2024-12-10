import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'email_detail_screen.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TRASH',
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
        stream: FirebaseFirestore.instance
            .collection('emails')
            .where('isTrashed', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Opacity(
                opacity: 0.5,
                child: Text(
                  'No emails in trash',
                  style: TextStyle(
                    fontSize: 50,
                  ),
                ),
              ),
            );
          }

          final trashedEmails = snapshot.data!.docs;

          return ListView.builder(
            itemCount: trashedEmails.length,
            itemBuilder: (context, index) {
              final email = trashedEmails[index].data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(email['subject'] ?? 'No Subject'),
                  subtitle: Text('From: ${email['from']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.restore),
                        onPressed: () {
                          // Restore the email
                          FirebaseFirestore.instance
                              .collection('emails')
                              .doc(trashedEmails[index].id)
                              .update({'isTrashed': false});
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever),
                        onPressed: () {
                          // Permanently delete the email
                          FirebaseFirestore.instance
                              .collection('emails')
                              .doc(trashedEmails[index].id)
                              .delete();
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to the email detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmailDetailScreen(email: email),
                      ),
                    );
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
