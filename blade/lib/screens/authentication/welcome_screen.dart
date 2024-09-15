import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Detect theme mode (light or dark)
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0, // Remove shadow under the AppBar
        centerTitle: true,
        title: const Text('Welcome'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo at the top half of the screen
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Display different logos based on theme mode
                    Image.asset(
                      isDarkMode ? 'assets/logos/blade-splash-logo-white.png' : 'assets/logos/blade-splash-logo-black.png',
                      height: 150, // Adjust the height based on your image
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome to Our App! Experience seamless management and more.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
              // Continue as Student Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login', arguments: 'student');
                  },
                  child: const Text('Continue as Student'),
                  // Elevated button styling will be applied from TElevatedButtonTheme
                ),
              ),
              const SizedBox(height: 20),

              // Continue as Supporter Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login', arguments: 'supporter');
                  },
                  child: const Text('Continue as Supporter'),
                  // Outlined button styling will be applied from TOutlinedButtonTheme
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
