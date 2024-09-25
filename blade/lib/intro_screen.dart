import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/constants/colors.dart';
class IntroScreen extends StatelessWidget {
  const IntroScreen({Key? key}) : super(key: key);

  Future<void> _onIntroEnd(BuildContext context) async {
    // Save to shared preferences that the user has seen the intro
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenIntro', true);

    // Navigate to the welcome screen
    Navigator.of(context).pushReplacementNamed('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        // Page 1
        PageViewModel(
          title: "Welcome to Blade",
          body: "Discover a new way to manage your tasks efficiently.",
          image: const Center(
            child: Icon(Icons.task, size: 100.0, color: TColors.primary),
          ),
        ),
        // Page 2
        PageViewModel(
          title: "Explore Features",
          body: "Stay organized with our intuitive design.",
          image: const Center(
            child: Icon(Icons.explore, size: 100.0, color: TColors.primary),
          ),
        ),
        // Page 3
        PageViewModel(
          title: "Get Started",
          body: "Sign up today and boost your productivity!",
          image: const Center(
            child: Icon(Icons.get_app, size: 100.0, color: TColors.primary),
          ),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text(
        'Skip',
        style: TextStyle(color: TColors.primary, fontSize: 16),
      ),
      next: const Icon(
        Icons.arrow_forward,
        color: TColors.primary,
      ),
      done: const Text(
        'Done',
        style: TextStyle(color: TColors.primary, fontSize: 16),
      ),
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