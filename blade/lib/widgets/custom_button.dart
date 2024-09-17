import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
