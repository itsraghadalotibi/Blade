// lib/shared/widgets/custom_text_field.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final String? Function(String?)? validator;
  final String? errorText;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.obscureText = false,
    this.validator,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
      ),
    );
  }
}

