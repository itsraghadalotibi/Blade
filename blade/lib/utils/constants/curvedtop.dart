import 'package:flutter/material.dart';

class CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 40); // Start point, slight vertical line for smooth start
    path.quadraticBezierTo(
        size.width / 2, 120, size.width, 40); // Curve control points
    path.lineTo(size.width, 0); // Move to top right
    path.close(); // Connect to starting point
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) =>
      false; // No reclip if new instance
}
