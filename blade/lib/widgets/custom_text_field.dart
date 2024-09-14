import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final String? errorText; // Add errorText as a parameter

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.focusNode,
    this.validator,
    this.errorText, // Add errorText parameter to constructor
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorText: errorText, // Use errorText for the field's error message
      ),
      validator: validator,
    );
  }
}
