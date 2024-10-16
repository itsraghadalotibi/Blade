import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), centerTitle: true, automaticallyImplyLeading: false),
      body: const Center(
        child: Text('Notifications Screen', style: TextStyle(fontSize: 40)),
      ),
    );
  }
}