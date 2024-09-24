import 'package:blade_app/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import '../utils/constants/sizes.dart';

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
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.obscureText = false,
    this.validator,
    this.errorText,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        contentPadding: const EdgeInsets.symmetric(
          vertical: TSizes.sm,
          horizontal: TSizes.md,
        ),
      ),
      validator: validator,
    );
  }
}
