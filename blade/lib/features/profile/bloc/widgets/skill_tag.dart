// Path: lib/features/profile/widgets/skill_tag.dart

import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';

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
        color: isDarkMode ? TColors.tag : TColors.grey, // Dynamic color based on theme
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: isDarkMode ? TColors.textWhite : TColors.black, // Dynamic text color based on theme
          fontSize: screenWidth * 0.03,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

