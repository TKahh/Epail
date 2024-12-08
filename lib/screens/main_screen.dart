import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urmail/screens/compose_email_screen.dart';
import 'package:urmail/screens/profile_screen.dart';

import 'email_detail_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final phone = currentUser?.phoneNumber;

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
                // Handle Trash tap
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Setting'),
              onTap: () {
                // Handle Logout tap
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                try {
                  // Sign out from Firebase
                  await FirebaseAuth.instance.signOut();

                  // Navigate back to the home screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: $e')),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(phone)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData ||
              snapshot.data == null ||
              !snapshot.data!.exists) {
            return const Center(child: Text('No user data found'));
          }
          final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          final emails = userData['emails'] as List<dynamic>?;

          if (emails == null || emails.isEmpty) {
            return const Center(child: Text('No emails found'));
          }

          // Hiển thị email đầu tiên trong danh sách
          final latestEmail = emails.first;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Latest Email:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'From: ${latestEmail['from']}', // Thay đổi key theo cấu trúc dữ liệu của bạn
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  'Subject: ${latestEmail['subject']}',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  'Body: ${latestEmail['body']}',
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
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
