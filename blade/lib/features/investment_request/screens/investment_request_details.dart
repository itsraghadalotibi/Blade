

import 'package:blade_app/widgets/investment_card.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../bloc/investment_request_bloc.dart';
import '../src/investment_request_model.dart';

class InvestmentRequestDetailScreen extends StatelessWidget {
  final InvestmentRequestModel request;
  final bool isOwner;

  const InvestmentRequestDetailScreen({Key? key, required this.request, required this.isOwner})
      : super(key: key);

  void _acceptRequest(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Accept Request"),
          content: const Text("Are you sure you want to accept this request?"),
          actions: [
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.pop(context, "accepted"); // Return 'accepted' status to previous screen
              },
            ),
          ],
        );
      },
    );
  }

  void _rejectRequest(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Reject Request"),
          content: const Text("Are you sure you want to reject this request?"),
          actions: [
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.pop(context, "rejected"); // Return 'rejected' status to previous screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? TColors.dark : TColors.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Request Details'),
      ),
      body: Column(
        children: [
          InvestmentRequestCard(request: request),
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
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (isOwner) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _rejectRequest(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _acceptRequest(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                          ),
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Return'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}