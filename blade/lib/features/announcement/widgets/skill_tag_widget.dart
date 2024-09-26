//theming
import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart'; // Make sure to import the correct path to TColors

class SkillTagWidget extends StatelessWidget {
  final List<String> skills;

  const SkillTagWidget({super.key, required this.skills});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: screenWidth * 0.02,
      runSpacing: 10,
      children:
          skills.map((skill) => _buildSkillTag(skill, screenWidth, isDarkMode)).toList(),
    );
  }

  Widget _buildSkillTag(String skill, double screenWidth, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? TColors.tag : TColors.tag, // Dynamic color based on theme
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: isDarkMode ? TColors.textWhite : TColors.textWhite, // Dynamic text color based on theme
          fontSize: screenWidth * 0.03,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}


// //dark version
// import 'package:flutter/material.dart';
// import '../../../utils/constants/colors.dart'; // Make sure to import the correct path to TColors

// class SkillTagWidget extends StatelessWidget {
//   final List<String> skills;

//   const SkillTagWidget({super.key, required this.skills});

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Wrap(
//       spacing: screenWidth * 0.02,
//       runSpacing: 10,
//       children:
//           skills.map((skill) => _buildSkillTag(skill, screenWidth)).toList(),
//     );
//   }

//   Widget _buildSkillTag(String skill, double screenWidth) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: screenWidth * 0.02,
//         vertical: 4,
//       ),
//       decoration: BoxDecoration(
//         color: TColors.black, // Light mode accent color for the tag
//         borderRadius: BorderRadius.circular(100),
//       ),
//       child: Text(
//         skill,
//         style: TextStyle(
//           color: TColors.textWhite, // Keep the text white for contrast
//           fontSize: screenWidth * 0.03,
//           fontWeight: FontWeight.w400,
//         ),
//       ),
//     );
//   }
// }


// //light version
// import 'package:flutter/material.dart';
// import '../../../utils/constants/colors.dart'; // Make sure to import the correct path to TColors

// class SkillTagWidget extends StatelessWidget {
//   final List<String> skills;

//   const SkillTagWidget({super.key, required this.skills});

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Wrap(
//       spacing: screenWidth * 0.02,
//       runSpacing: 10,
//       children:
//           skills.map((skill) => _buildSkillTag(skill, screenWidth)).toList(),
//     );
//   }

//   Widget _buildSkillTag(String skill, double screenWidth) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: screenWidth * 0.02,
//         vertical: 4,
//       ),
//       decoration: BoxDecoration(
//         color: TColors.grey, // Light mode accent color for the tag
//         borderRadius: BorderRadius.circular(100),
//       ),
//       child: Text(
//         skill,
//         style: TextStyle(
//           color: TColors.textPrimary, // Keep the text white for contrast
//           fontSize: screenWidth * 0.03,
//           fontWeight: FontWeight.w400,
//         ),
//       ),
//     );
//   }
// }
