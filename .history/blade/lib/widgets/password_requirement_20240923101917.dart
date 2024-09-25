import 'package:flutter/material.dart';

class PasswordRequirement extends StatelessWidget {
  final String requirement;
  final bool isMet;

  const PasswordRequirement({
    Key? key,
    required this.requirement,
    required this.isMet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          color: isMet ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(requirement),
      ],
    );
  }
}
