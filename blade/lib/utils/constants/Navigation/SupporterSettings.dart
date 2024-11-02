import 'package:flutter/material.dart';

class SupporterSettings extends StatefulWidget {
  const SupporterSettings({super.key});

  @override
  State<SupporterSettings> createState() => _SupporterSettingsState();
}

class _SupporterSettingsState extends State<SupporterSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Center'),
        centerTitle: true,
      ),
      body: const Center(
        child:
            Center(child: Text('Notification Center', style: TextStyle(fontSize: 20))),
      ),
    );
  }
}
