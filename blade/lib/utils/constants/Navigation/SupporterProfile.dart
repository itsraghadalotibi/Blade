import 'package:flutter/material.dart';

class SupporterProfile extends StatefulWidget {
  const SupporterProfile({super.key});

  @override
  State<SupporterProfile> createState() => _SupporterProfileState();
}

class _SupporterProfileState extends State<SupporterProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supporter Profile'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Supporter Profile Screen', style: TextStyle(fontSize: 40)),
      ),
    );
  }
}
