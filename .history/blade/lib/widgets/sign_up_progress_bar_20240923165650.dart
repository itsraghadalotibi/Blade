import 'package:flutter/material.dart';

import '../utils/constants/colors.dart';

class SignUpProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const SignUpProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> steps = [];
    for (int i = 0; i < totalSteps; i++) {
      bool isCompleted = i < currentStep;
      bool isActive = i == currentStep;

      steps.add(
        Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor:
                    isCompleted ? TColors.primary : Colors.grey[300],
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: isActive ? TColors.primary : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              if (i < totalSteps - 1)
                Container(
                  height: 2,
                  color: isCompleted ? TColors.primary : Colors.grey[300],
                ),
            ],
          ),
        ),
      );

      if (i < totalSteps - 1) {
        steps.add(
          SizedBox(
            width: 16,
            child: Divider(
              thickness: 2,
              color: isCompleted ? TColors.primary : Colors.grey[300],
            ),
          ),
        );
      }
    }

    return Row(
      children: steps,
    );
  }
}
