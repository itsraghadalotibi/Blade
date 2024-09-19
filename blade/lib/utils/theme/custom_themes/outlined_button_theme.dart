import 'package:flutter/material.dart';

import '../../constants/colors.dart';

/* -- Light & Dark Outlined Button Themes -- */
class TOutlinedButtonTheme {
  TOutlinedButtonTheme._();

  /* -- Light Theme -- */
  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: TColors.dark, // Foreground color for text and icon
      side: const BorderSide(color: TColors.borderPrimary), // Border color
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  /* -- Dark Theme -- */
  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: TColors.light, // Foreground color for text and icon
      side: const BorderSide(color: TColors.borderPrimary), // Border color
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
