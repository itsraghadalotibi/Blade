import 'package:flutter/material.dart';

class DollarIcon extends StatelessWidget {
  final double size;

  const DollarIcon({Key? key, this.size = 50.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: DollarIconPainter(),
    );
  }
}

class DollarIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint circlePaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.orange.shade600, Colors.yellow.shade600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2));

    final Paint shadowPaint = Paint()..color = Colors.grey.withOpacity(0.5);
    final double shadowOffset = 4.0;

    // Draw shadow
    canvas.drawCircle(
      Offset(size.width / 2 + shadowOffset, size.height / 2 + shadowOffset),
      size.width / 2,
      shadowPaint,
    );

    // Draw main coin circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      circlePaint,
    );

    // Draw dollar symbol
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '\$',
        style: TextStyle(
          fontSize: size.width * 0.6,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
