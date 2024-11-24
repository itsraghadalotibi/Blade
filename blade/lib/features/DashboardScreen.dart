import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Hello"); // Print "Hello" to the console

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Hello'), // Display "Hello" on the screen
      ),
    );
  }
}
