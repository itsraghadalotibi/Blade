import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart'; // Make sure to import the correct path to TColors

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
        color: const Color.fromARGB(
            255, 190, 189, 189), // Light mode accent color for the tag
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: const Color.fromARGB(
              255, 187, 9, 9), // Keep the text white for contrast
          fontSize: screenWidth * 0.03,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
