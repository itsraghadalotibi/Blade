

import 'package:flutter/material.dart';

import '../src/investment_request_model.dart';

class InvestmentRequestDetailScreen extends StatelessWidget {
  final InvestmentRequestModel request;

  const InvestmentRequestDetailScreen({Key? key, required this.request})
      : super(key: key);

  Widget buildDetailRow(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isValid = request.validUntil.isAfter(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Request'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: isValid ? Colors.blue[100] : Colors.grey[400],
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Offer',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    request.offer,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/coins.png', // Ensure you add your image in the assets folder
                    height: 50,
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.black, thickness: 1),
                  const SizedBox(height: 10),
                  const Text(
                    'Investment Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildDetailRow('Supporter Name', request.supporterName),
                  const SizedBox(height: 10),
                  buildDetailRow('Reason for Interest', request.reasonForInterest),
                  const SizedBox(height: 10),
                  // Display contact information entries
                  ...request.contactInfo.entries.map((entry) => buildDetailRow(
                        entry.key.capitalize(), // Displays 'Email' or 'Phone' as labels
                        entry.value,
                      )),
                  const SizedBox(height: 10),
                  buildDetailRow(
                    'Valid Until',
                    request.validUntil.toLocal().toString().split(' ')[0],
                  ),
                  if (!isValid) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'This request has expired.',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}
