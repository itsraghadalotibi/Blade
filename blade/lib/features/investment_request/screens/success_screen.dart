import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessAnimationScreen extends StatefulWidget {
  @override
  _SuccessAnimationScreenState createState() => _SuccessAnimationScreenState();
}

class _SuccessAnimationScreenState extends State<SuccessAnimationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSuccessMessage(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/posted2.json', // Replace with your Lottie file
            width: 300,
            height: 300,
            fit: BoxFit.fill,
            controller: _controller,
            onLoaded: (composition) {
              // Set the controller duration to match the Lottie animation
              _controller.duration = composition.duration;
              _controller.forward(); // Start the animation
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Investment Request Sent Successfully!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.popUntil(
                context,
                (route) =>
                    route.isFirst, // Or specify another condition if needed
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Text('Back to Projects')
              ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildSuccessMessage(context),
    );
  }
}
