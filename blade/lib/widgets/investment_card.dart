import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../features/investment_request/src/investment_request_model.dart';
import '../utils/constants/colors.dart';
class InvestmentRequestCard extends StatelessWidget {
  final InvestmentRequestModel request;

  const InvestmentRequestCard({
    Key? key,
    required this.request,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconPath = request.iconPath ?? 'assets/icons/default_icon.png';
    final isPending = request.status == 'Pending';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? TColors.dark : TColors.light;

    return Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[100]!, Colors.blue[300]!],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Offer',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          request.offer,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        // Display selected icon if available, otherwise default icon
                        request.iconPath != null
                            ? SvgPicture.asset(
                                request.iconPath!,
                                height: 80,
                                width: 80,
                              )
                            : const Icon(
                                Icons.monetization_on,
                                size: 50,
                                color: Colors.deepOrange,
                              ),
                        const SizedBox(height: 20),
                        TicketSeparator(),
                        const SizedBox(height: 10),
                        const Text(
                          'Investment Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        buildDetailRow('Project Name', request.projectName),
                        const SizedBox(height: 10),
                        buildDetailRow('Supporter Name', request.supporterName),
                        const SizedBox(height: 10),
                        buildDetailRow('Reason for Interest', request.reasonForInterest),
                        const SizedBox(height: 10),
                         ...request.contactInfo.entries.map((entry) => buildDetailRow(
                              entry.key.capitalize(),
                              entry.value,
                            )),
                        const SizedBox(height: 10),
                        buildDetailRow('Valid Until', request.validUntil.toLocal().toString().split(' ')[0]),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget buildDetailRow(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class TicketSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? TColors.dark : TColors.light;
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(100),
              topRight: Radius.circular(100),
            ),
            color: bgColor,
          ),
          height: 20,
          width: 10,
        ),
        Expanded(
          child: CustomPaint(
            painter: DottedLinePainter(color: bgColor),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(100),
              topLeft: Radius.circular(100),
            ),
            color: bgColor,
          ),
          height: 20,
          width: 10,
        ),
      ],
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;
  DottedLinePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    const dashWidth = 6;
    const dashSpace = 7;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
extension StringCasingExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}