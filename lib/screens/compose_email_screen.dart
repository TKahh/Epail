import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/email_service.dart';

class ComposeEmailScreen extends StatefulWidget {
  const ComposeEmailScreen({super.key});

  @override
  State<ComposeEmailScreen> createState() => _ComposeEmailScreenState();
}

class _ComposeEmailScreenState extends State<ComposeEmailScreen> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _bccController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  List<PlatformFile> attachments = [];  // Change to List<PlatformFile>

  @override
  void dispose() {
    _toController.dispose();
    _ccController.dispose();
    _bccController.dispose();
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

  void _sendEmail() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are not logged in')),
      );
      return;
    }

    final senderSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final fromPhone = senderSnapshot.data()?['phone'];
    if (fromPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch sender phone number')),
      );
      return;
    }

    final toPhones = _toController.text
        .trim()
        .split(',')
        .map((phone) => normalizePhone(phone.trim()))
        .toList();
    final ccPhones = _ccController.text
        .trim()
        .split(',')
        .map((phone) => normalizePhone(phone.trim()))
        .toList();
    final bccPhones = _bccController.text
        .trim()
        .split(',')
        .map((phone) => normalizePhone(phone.trim()))
        .toList();
    final subject = _subjectController.text.trim();
    final body = _bodyController.text.trim();

    if (toPhones.isEmpty || subject.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required!')),
      );
      return;
    }

    try {
      // Pass the attachments list as a named argument
      await EmailService().sendEmail(
        fromPhone,
        toPhones,
        ccPhones,
        bccPhones,
        subject,
        body,
        attachments: attachments,  // Named argument for attachments
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email sent successfully!')),
      );

      _toController.clear();
      _ccController.clear();
      _bccController.clear();
      _subjectController.clear();
      _bodyController.clear();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send email: $e')),
      );
    }
  }

  // Function to pick files as attachments
  void _pickAttachments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        attachments = result.files;  // Store PlatformFile objects
      });
    }
  }

  // Function to save the draft
  void _saveDraft() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    await FirebaseFirestore.instance.collection('drafts').add({
      'from': currentUser.uid,
      'to': _toController.text,
      'cc': _ccController.text,
      'bcc': _bccController.text,
      'subject': _subjectController.text,
      'body': _bodyController.text,
      'attachments': attachments.map((file) => file.path).toList(),  // Save paths in the draft
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose Email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDraft,
          ),
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
              controller: _ccController,
              decoration: const InputDecoration(
                labelText: 'CC',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bccController,
              decoration: const InputDecoration(
                labelText: 'BCC',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickAttachments,
              icon: const Icon(Icons.attach_file),
              label: const Text('Attach Files'),
            ),
            if (attachments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Attachments:'),
                    ...attachments.map((file) => Text(file.name)).toList(),  // Show file names
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
