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
          body:
              "Join a global community where innovators and supporters come together. Blade is the platform where ideas take flight through collaboration and empowerment.",
          image: Center(
            child: Image.asset(
              'assets/images/on_boarding_images/welcome-sign.png',
              width: 250,
            ),
          ),
          decoration: const PageDecoration(
            pageMargin: EdgeInsets.only(
              top: 50,
            ),
          ),
        ),
        // Page 2
        PageViewModel(
          title: "Collaborate and Empower",
          body:
              "Discover exciting projects, connect with talented individuals, and contribute your skills or resources. Together, we turn visionary ideas into reality and make a meaningful impact.",
          image: Center(
            child: Image.asset(
              'assets/images/on_boarding_images/developer-team.png',
              width: 250,
            ),
          ),
          decoration: const PageDecoration(
            pageMargin: EdgeInsets.only(
              top: 50,
            ),
          ),
        ),
        // Page 3
        PageViewModel(
          title: "Get Started Today",
          body:
              "Whether you're here to create, collaborate, or support, Blade offers the tools and community you need. Join us now and be part of a movement that shapes the future.",
          image: Center(
            child: Image.asset(
              'assets/images/on_boarding_images/office-workplace.png',
              width: 250,
            ),
          ),
          decoration: const PageDecoration(
            pageMargin: EdgeInsets.only(
              top: 50,
            ),
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
