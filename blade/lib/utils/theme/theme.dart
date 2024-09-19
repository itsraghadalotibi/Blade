import 'package:blade_app/utils/constants/colors.dart';
import 'package:blade_app/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:blade_app/utils/theme/custom_themes/text_theme.dart';
import 'package:flutter/material.dart';

<<<<<<< Updated upstream
import 'custom_themes/appbar_theme.dart';
import 'custom_themes/outlined_button_theme.dart';

class TAppTheme{
=======
class TAppTheme {
>>>>>>> Stashed changes
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
<<<<<<< Updated upstream
    primaryColor: TColors.primary,
    scaffoldBackgroundColor: TColors.primaryBackground,
    textTheme: TTextTheme.lightTextTheme, // Using the light text theme
    appBarTheme: TAppBarTheme.lightAppBarTheme, // Using the light app bar theme
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.lightOutlinedButtonTheme,
=======
    primaryColor: const Color.fromARGB(255, 255, 85, 7),
    scaffoldBackgroundColor: Colors.white,
    textTheme: TTextTheme.lightTextTheme,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
  ).copyWith(
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Colors.orange, // Replaces accentColor with secondary color
    ),
>>>>>>> Stashed changes
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
<<<<<<< Updated upstream
    primaryColor: TColors.primary,
    scaffoldBackgroundColor: TColors.dark,
    textTheme: TTextTheme.darkTextTheme, // Using the dark text theme
    appBarTheme: TAppBarTheme.darkAppBarTheme, // Using the dark app bar theme
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.darkOutlinedButtonTheme,
=======
    primaryColor: const Color.fromARGB(255, 255, 85, 7),
    scaffoldBackgroundColor: const Color.fromARGB(255, 23, 23, 23), // Changed to match dark theme convention
    textTheme: TTextTheme.darkTextTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
  ).copyWith(
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Colors.orange, // Replaces accentColor with secondary color
    ),
>>>>>>> Stashed changes
  );
}
