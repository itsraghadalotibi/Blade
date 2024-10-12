import 'package:blade_app/home_screen.dart';
import 'package:blade_app/utils/constants/Navigation/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'package:lottie/lottie.dart';
import '../../../utils/constants/Navigation/navigation.dart';
import 'post.dart'; // Assuming this is your custom widget for creating a post

class backgroundScreen extends StatefulWidget {
  final bool isSuccess;  // Flag to check if we need to show the success message or form

  const backgroundScreen({Key? key, this.isSuccess = false}) : super(key: key);

  @override
  _backgroundScreenState createState() => _backgroundScreenState();
}

class _backgroundScreenState extends State<backgroundScreen> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(vsync: this);

    // Add listener to know when the animation finishes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Redirect to the profile page when the animation completes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Navigation()),
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Set system UI overlay style based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light, // For iOS
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark, // For Android
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Idea'),
        backgroundColor: isDarkMode ? Colors.grey.shade900 : const Color.fromARGB(255, 255, 255, 255), // Background color for AppBar
        elevation: 0, // Remove shadow under AppBar
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black), // Icon color for AppBar
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: isDarkMode
                ? [Colors.grey.shade800, Colors.grey.shade900] // Dark mode gradient
                : [const Color(0xFFFD5336), const Color(0xFFFD5336)], // Light mode gradient
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Text(
                          widget.isSuccess ? "" : "",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black, // Adjust text color based on theme
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  child: widget.isSuccess
                      ? _buildSuccessMessage(context)
                      : const Post(), // Conditional rendering
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessMessage(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/posted2.json',  // Path to your Lottie animation file
            width: 300,
            height: 300,
            fit: BoxFit.fill,
            controller: _controller,  // Use the controller to control the animation
            onLoaded: (composition) {
              _controller.duration = composition.duration;  // Set the controller duration to match Lottie animation
              _controller.forward();  // Start the animation
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Your post has been successfully created!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black, // Adjust text color based on theme
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

