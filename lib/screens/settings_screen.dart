import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoAnswerEnabled = false;
  double _fontSize = 16.0;
  String _fontFamily = 'Roboto';

  final List<String> _fontFamilies = ['Roboto', 'Itim', 'Arial', 'Times New Roman'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load settings from SharedPreferences
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _darkModeEnabled = prefs.getBool('darkModeEnabled') ?? false;
      _autoAnswerEnabled = prefs.getBool('autoAnswerEnabled') ?? false;
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;
      _fontFamily = prefs.getString('fontFamily') ?? 'Roboto';
    });
  }

  // Save settings to SharedPreferences
  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('darkModeEnabled', _darkModeEnabled);
    await prefs.setBool('autoAnswerEnabled', _autoAnswerEnabled);
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setString('fontFamily', _fontFamily);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Notifications Toggle
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                _saveSettings();
              });
            },
          ),
          const Divider(),

          // Dark Mode Toggle
          SwitchListTile(
            title: const Text('Enable Dark Mode'),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
                _saveSettings();
              });
            },
          ),
          const Divider(),

          // Auto-Answer Toggle
          SwitchListTile(
            title: const Text('Enable Auto-Answer'),
            value: _autoAnswerEnabled,
            onChanged: (value) {
              setState(() {
                _autoAnswerEnabled = value;
                _saveSettings();
              });
            },
          ),
          const Divider(),

          // Font Size Selection
          ListTile(
            title: const Text('Font Size'),
            subtitle: Slider(
              value: _fontSize,
              min: 12.0,
              max: 24.0,
              divisions: 6,
              label: '${_fontSize.round()}',
              onChanged: (value) {
                setState(() {
                  _fontSize = value;
                  _saveSettings();
                });
              },
            ),
          ),
          const Divider(),

          // Font Family Selection
          ListTile(
            title: const Text('Font Family'),
            trailing: DropdownButton<String>(
              value: _fontFamily,
              items: _fontFamilies.map((font) {
                return DropdownMenuItem(
                  value: font,
                  child: Text(font),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _fontFamily = value!;
                  _saveSettings();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
