import 'package:flutter/material.dart';

class AiTodoListItem extends StatelessWidget {
  final String title;
  final String description;
  final Color backgroundColor;
  final int stepNumber;

  const AiTodoListItem({
    Key? key,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.stepNumber,
  }) : super(key: key);

  void _showDescriptionPopup(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF424242) : Colors.white,
          title: Text(
            "Step $stepNumber: $title",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            description,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFD5336),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 20.0,
                  ),
                ),
                child: const Text(
                  "Clear 👍🏻",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showDescriptionPopup(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "Step $stepNumber: $title",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
