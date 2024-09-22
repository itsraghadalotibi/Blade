import 'package:blade_app/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import '../utils/constants/sizes.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final String? Function(String?)? validator;
  final String? errorText;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? inputType;
  final int? maxLength;
  final VoidCallback? onTap;
  
  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.validator,
    this.errorText,
    this.maxLength,
    this.obscureText = false, // Default to false
    this.maxLines = 1, // Default to 1
    this.keyboardType,
    this.inputType, this.onTap,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _isObscured,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: widget.inputType == "password"
            ? IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        )
            : null,
        errorText: widget.errorText,
        contentPadding: EdgeInsets.symmetric(
          vertical: TSizes.sm,
          horizontal: TSizes.md,
        ),
      ),
      validator: widget.validator,
      onTap:widget.onTap,
      keyboardType: widget.keyboardType,
    );
  }
}
