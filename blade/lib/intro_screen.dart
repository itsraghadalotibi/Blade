import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome to Blade",
          body: "Your description for page 1.",
          image: const Center(
    child: Text("👋", style: TextStyle(fontSize: 100.0)),
  ),
        ),
        PageViewModel(
          title: "Explore Features",
          body: "Your description for page 2.",
          image: const Center(
    child: Text("👋", style: TextStyle(fontSize: 100.0)),
  ),
        ),
        PageViewModel(
          title: "Get Started",
          body: "Your description for page 3.",
          image: const Center(
    child: Text("👋", style: TextStyle(fontSize: 100.0)),
  ),
        ),
      ],
      onDone: () async {
        Navigator.of(context).pushReplacementNamed('/home');
      },
      showSkipButton: true,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done'),
      dotsDecorator: const DotsDecorator(
        activeColor: Colors.blue,
      ),
    );
  }
}
