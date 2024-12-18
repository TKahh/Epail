import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urmail/screens/sent_screen.dart';
import '../screens/settings_screen.dart';
// import '../services/email_service.dart';
import 'package:urmail/screens/compose_email_screen.dart';
import 'package:urmail/screens/trash_screen.dart';
import 'package:urmail/screens/profile_screen.dart';
import 'email_detail_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  final bool showSentEmails;

  const MainScreen({super.key, this.showSentEmails = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _searchQuery = '';

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

    var query = FirebaseFirestore.instance
        .collection('emails')
        .orderBy('timestamp', descending: true);

    if (widget.showSentEmails) {
      query = query.where('from', isEqualTo: currentUser.phoneNumber);
    } else {
      query = query.where('to', arrayContains: currentUser.phoneNumber);
    }

    if (_searchQuery.isNotEmpty) {
      query = query.where('subject', isGreaterThanOrEqualTo: _searchQuery);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.showSentEmails ? 'Sent Emails' : 'Inbox',
          style: const TextStyle(
            fontSize: 50,
            fontFamily: 'Itim',
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ExpandableSearchDelegate(
                  onSearchChanged: (query) {
                    setState(() {
                      _searchQuery = query.trim();
                    });
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MainScreen(showSentEmails: false),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.send),
              title: const Text('Sent'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SentScreen()));
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
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
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
        stream: query.snapshots(),
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
                  subtitle: Text(widget.showSentEmails
                      ? 'To: ${email['to'].join(', ')}'
                      : 'From: ${email['from']}'),
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

class ExpandableSearchDelegate extends SearchDelegate {
  final Function(String) onSearchChanged;

  ExpandableSearchDelegate({required this.onSearchChanged});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearchChanged('');
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearchChanged(query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    onSearchChanged(query);
    return ListTile(
      title: Text('Searching for: $query'),
    );
  }
}
