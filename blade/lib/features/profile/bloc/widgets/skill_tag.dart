// Path: lib/features/profile/widgets/skill_tag.dart

import 'package:blade_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class SkillTagWidget extends StatelessWidget {
  final List<String> skills;

  const SkillTagWidget({super.key, required this.skills});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Wrap(
      spacing: screenWidth * 0.02,
      runSpacing: 10,
      children:
          skills.map((skill) => _buildSkillTag(skill, screenWidth)).toList(),
    );
  }

  Widget _buildSkillTag(String skill, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: TColors.grey, // Light mode accent color for the tag
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: TColors.textPrimary, // Keep the text white for contrast
          fontSize: screenWidth * 0.03,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
