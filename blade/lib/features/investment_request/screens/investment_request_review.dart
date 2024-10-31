import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/constants/colors.dart';
import '../bloc/investment_request_bloc.dart';
import '../bloc/investment_request_event.dart';
import '../bloc/investment_request_state.dart';
import '../src/investment_request_model.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'success_screen.dart';

class InvestmentRequestReviewScreen extends StatelessWidget {
  final InvestmentRequestModel request;

  const InvestmentRequestReviewScreen({Key? key, required this.request})
      : super(key: key);

  void _confirmSubmission(BuildContext context) {
    final updatedRequest = request.copyWith(
      id: UniqueKey().toString(),
    );

    context
        .read<InvestmentRequestBloc>()
        .add(SubmitInvestmentRequest(request: updatedRequest));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? TColors.dark : TColors.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Request'),
      ),
       body: BlocListener<InvestmentRequestBloc, InvestmentRequestState>(
        listener: (context, state) {
          if (state is InvestmentRequestSuccess) {
            // Navigate to the success animation screen on successful submission
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SuccessAnimationScreen()),
            );
          } else if (state is InvestmentRequestFailure) {
            // Show an error message if submission fails
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to submit request: ${state.error}')),
            );
          }
        },
        child: Column(
        children: [
          Expanded(
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
          ),
          // Button bar with gradient fade at the top
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            padding: const EdgeInsets.only(top: 18.0, bottom: 32.0, right: 16.0, left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _confirmSubmission(context),
                    child: const Text('Confirm'),
                  ),
                ),
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