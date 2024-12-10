import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/email_service.dart';

class ComposeEmailScreen extends StatefulWidget {
  const ComposeEmailScreen({super.key});

  @override
  State<ComposeEmailScreen> createState() => _ComposeEmailScreenState();
}

class _ComposeEmailScreenState extends State<ComposeEmailScreen> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final List<File> _attachments = [];

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  String normalizePhone(String phone) {
    if (phone.startsWith('0')) {
      return '+84${phone.substring(1)}';
    }
    return phone;
  }

  Future<void> _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _attachments.addAll(result.paths.map((path) => File(path!)));
      });
    }
  }

  Future<bool> _validateRecipients(List<String> toPhones) async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    for (String phone in toPhones) {
      final snapshot = await usersCollection.doc(phone).get();
      if (!snapshot.exists) {
        return false;
      }
    }
    return true;
  }

  void _sendEmail() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are not logged in')),
      );
      return;
    }
    final fromPhone = currentUser.phoneNumber;
    if (fromPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch sender phone number')),
      );
      return;
    }
    final toPhones = _toController.text
        .trim()
        .split(',')
        .map((phone) => AuthService().normalizePhone(phone.trim()))
        .toList();
    final subject = _subjectController.text.trim();
    final body = _bodyController.text.trim();

    if (toPhones.isEmpty || subject.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required!')),
      );
      return;
    }
    if (!await _validateRecipients(toPhones)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Some recipients do not exist')),
      );
      return;
    }

    try {
      await EmailService().sendEmail(fromPhone, toPhones, subject, body,
          attachments: _attachments);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email sent successfully!')),
      );
      setState(() {
        _toController.clear();
        _subjectController.clear();
        _bodyController.clear();
        _attachments.clear();
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send email: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'COMPOSE EMAIL',
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
            icon: const Icon(Icons.send),
            onPressed: _sendEmail,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _toController,
              decoration: const InputDecoration(
                labelText: 'To',
                hintText: 'Recipient Phone Number',
                prefixIcon: Icon(Icons.person),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                prefixIcon: Icon(Icons.subject),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.message),
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text("Attach Files",
                  style: TextStyle(fontFamily: 'Itim')),
              onPressed: _pickAttachments,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _attachments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.file_present),
                    title: Text(_attachments[index].path.split('/').last),
                    trailing: IconButton(
                      onPressed: () {
                        setState(
                          () {
                            _attachments.removeAt(index);
                          },
                        );
                      },
                      icon: const Icon(Icons.remove_circle),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
