import 'package:flutter/material.dart';

import '../utils/constants/sizes.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final String? Function(String?)? validator;
  final String? errorText;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.obscureText = false,
    this.validator,
    this.errorText,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      decoration: InputDecoration(
      labelText: label,
      errorText: errorText,
      contentPadding: EdgeInsets.symmetric(
        vertical: TSizes.sm,
        horizontal: TSizes.md,
        ),
      ),
    );
  }
}

