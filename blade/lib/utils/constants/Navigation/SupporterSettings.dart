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
        title: const Text('Supporter Settings'),
        centerTitle: true,
      ),
      body: const Center(
        child:
            Text('Supporter Settings Screen', style: TextStyle(fontSize: 40)),
      ),
    );
  }
}
