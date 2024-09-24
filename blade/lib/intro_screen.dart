import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/constants/colors.dart';

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
        Navigator.of(context).pushReplacementNamed('/welcome');
      },
      showSkipButton: true,
      skip: const Text('Skip', style: TextStyle(color: TColors.primary, fontSize: 16)),
      next: const Icon(Icons.arrow_forward, color: TColors.primary,),
      done: const Text('Done', style: TextStyle(color: TColors.primary, fontSize: 16)),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: TColors.primary,
        color: TColors.darkGrey,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
    );
  }
}
