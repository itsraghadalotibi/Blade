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
  final int? maxLength;
  final bool showCounter; //control counter visibility
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.obscureText = false,
    this.validator,
    this.errorText,
    this.maxLines = 1,
    this.maxLength = 320, // Default maxLength is 320
    this.keyboardType,
    this.showCounter = false, // Counter is hidden by default
    this.suffixIcon,
    this.prefixIcon,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText; // State variable to toggle password visibility

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText; // Initialize with the passed obscureText value
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText; // Toggle the obscureText state
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine the suffix icon
    Widget? suffixIcon = widget.suffixIcon;
    if (widget.obscureText) {
      suffixIcon = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
        ),
        onPressed: _toggleObscureText,
      );
    }

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscureText,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        contentPadding: const EdgeInsets.symmetric(
          vertical: TSizes.sm,
          horizontal: TSizes.md,
        ),
        suffixIcon: suffixIcon,
        prefixIcon: widget.prefixIcon,
        // Hide counter when showCounter is false
        counterText: widget.showCounter ? null : '',
      ),
      validator: widget.validator,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}
