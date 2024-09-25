import 'package:blade_app/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
        // Redirect to the home page when the animation completes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),  // Replace with your HomePage
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
    return Scaffold(
      appBar: AppBar(title: const Text('New Idea')),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Color(0xFFFD5336),   
              Color.fromARGB(255, 139, 139, 139),
              Color(0xFFFD5336),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Align(
                      //   alignment: Alignment.centerLeft,
                      //   child: IconButton(
                      //     icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                      //     onPressed: () {
                      //       Navigator.pop(context);
                      //     },
                      //   ),
                      // ),
                      Center(
                        child: Text(
                          widget.isSuccess ? "" : "",
                          style: const TextStyle(color: Colors.white, fontSize: 40),
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
                  color: Colors.grey.shade900,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  child: widget.isSuccess ? _buildSuccessMessage(context) : const Post(),  // Conditional rendering
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessMessage(BuildContext context) {
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
          const Text(
            'Your post has been successfully created!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // ElevatedButton(
          //   onPressed: () {
          //     Navigator.pop(context);  // Navigate back or close the screen
          //   },
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: const Color(0xFFFD5336),
          //   ),
          //   child: const Text('Go Back'),
          // ),
        ],
      ),
    );
  }
}
