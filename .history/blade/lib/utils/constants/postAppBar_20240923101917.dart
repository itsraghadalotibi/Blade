import 'package:flutter/material.dart';

// StatelessWidget with external state management using ValueNotifier
class PostAppBar extends StatelessWidget {
  final String title; // Title passed to the app bar
  final ValueNotifier<String> _valueNotifier = ValueNotifier<String>('Announcement'); // Tracks the dropdown's selected value
    final Widget child; // Accept child widget


  // Constructor with required title parameter and const optimization
   PostAppBar({Key? key, required this.title, required this.child}) : super(key: key);

  // The build method describes the UI of the widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar with a ValueListenableBuilder to update the DropdownButton
        title: ValueListenableBuilder<String>(
          valueListenable: _valueNotifier,
          builder: (context, value, _) {
            return DropdownButton<String>(
              value: value, // Sets the current value of the dropdown
              items: const <DropdownMenuItem<String>>[
                // Static dropdown items that won't change
                DropdownMenuItem(
                  value: 'Announcement', // Value for this option
                  child: Text('Announcement'), // Visible text for the option
                ),
                DropdownMenuItem(
                  value: 'New Post', // Value for this option
                  child: Text('New Post'), // Visible text for the option
                ),
              ],
              onChanged: (String? newValue) {
                // Update the ValueNotifier when a new value is selected
                _valueNotifier.value = newValue!;
              },
            );
          },
        ),
      ),
      // Body content of the Scaffold
      body: const Center(
        child: Column(
          // Center the text vertically in the middle of the screen
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Static text widget inside a column
            Text('hello world'), // Constant "hello world" text displayed in the center
          ],
        ),
      ),
    );
  }
}