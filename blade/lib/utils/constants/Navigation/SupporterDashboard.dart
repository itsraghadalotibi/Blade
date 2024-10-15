import 'package:flutter/material.dart';

class SupporterDashboard extends StatefulWidget {
  const SupporterDashboard({super.key});

  @override
  State<SupporterDashboard> createState() => _SupporterDashboardState();
}

class _SupporterDashboardState extends State<SupporterDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supporter Dashboard'),
        centerTitle: true,
      ),
      body: const Center(
        child:
            Text('Supporter Dashboard Screen', style: TextStyle(fontSize: 40)),
      ),
    );
  }
}
