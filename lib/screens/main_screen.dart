import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urmail/screens/compose_email_screen.dart';
import 'package:urmail/screens/trash_screen.dart';
import 'package:urmail/screens/profile_screen.dart';

import 'email_detail_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text('No user is logged in'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EPAIL',
          style: TextStyle(
            fontSize: 50,
            fontFamily: 'Itim',
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings tapped')),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration:
                  const BoxDecoration(color: Color.fromARGB(255, 36, 81, 104)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'EPAIL',
                    style: TextStyle(
                      fontSize: 50,
                      fontFamily: 'Itim',
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 10
                        ..color = Colors.black,
                    ),
                  ),
                  const Text(
                    'EPAIL',
                    style: TextStyle(
                      fontSize: 50,
                      fontFamily: 'Itim',
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_box_rounded),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.inbox),
              title: const Text('Inbox'),
              onTap: () {
                // Handle Inbox tap
              },
            ),
            ListTile(
              leading: const Icon(Icons.send),
              title: const Text('Sent'),
              onTap: () {
                // Handle Sent tap
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Trash'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrashScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Setting'),
              onTap: () {
                // Handle setting tap
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Future.delayed(const Duration(milliseconds: 500), () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                });
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('emails')
            .where('to',
                arrayContains: currentUser
                    .phoneNumber) // Lọc email theo số điện thoại người nhận
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No emails found'));
          }

          final emails = snapshot.data!.docs;

          return ListView.builder(
            itemCount: emails.length,
            itemBuilder: (context, index) {
              final email = emails[index].data() as Map<String, dynamic>;
              final emailDoc = emails[index];

              return Card(
                child: ListTile(
                  title: Text(email['subject'] ?? 'No Subject'),
                  subtitle: Text('From: ${email['from']}'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmailDetailScreen(email: email),
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ComposeEmailScreen()),
              );
            },
            child: const Icon(Icons.edit),
          ),
        ),
      ),
    );
  }
}
