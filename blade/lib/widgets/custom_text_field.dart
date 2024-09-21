// lib/shared/widgets/custom_text_field.dart
import 'package:blade_app/utils/theme/theme.dart';
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

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.obscureText = false,
    this.validator,
    this.errorText,
    this.maxLines = 1, // Default to 1
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      maxLines: maxLines,
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

