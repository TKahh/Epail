import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EmailDetailScreen extends StatelessWidget {
  final Map<String, dynamic> email;

  const EmailDetailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              email['subject'] ?? 'No Subject',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'From: ${email['from'] ?? 'Unknown'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'To: ${email['to'] != null ? (email['to'] as List).join(', ') : 'Unknown'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            if (email['timestamp'] != null)
              Text(
                'Sent: ${DateFormat.yMMMd().add_jm().format(email['timestamp'].toDate())}',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            const Divider(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  email['body'] ?? 'No content available',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
