

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

  

  void _rejectRequest(BuildContext outerContext, InvestmentRequestModel request) {
  final TextEditingController reasonController = TextEditingController();
  bool showError = false;

  showDialog(
    context: outerContext,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Reject Request"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Are you sure you want to reject this request?"),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Rejection Reason',
                  ),
                  maxLength: 100,
                ),
                if (showError)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Please provide a reason.',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
            actions: [
              OutlinedButton(
                style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 12.0),
                    ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 12.0),
                    ),
                onPressed: () {
                  final reason = reasonController.text.trim();
                  if (reason.isNotEmpty) {
                    Navigator.of(dialogContext).pop();
                      Navigator.pop(outerContext, {
                        "status": "rejected",
                        "reason": reason,
                      });
                  } else {
                    // Show error message under the text field
                    setState(() {
                      showError = true;
                    });
                  }
                },
                child: const Text('Reject'),
              ),
            ],
          );
        },
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
                    if (isOwner && request.status == 'Pending') ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _rejectRequest(context, request),
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
                          onPressed: () => {
                            Navigator.pop(context, {"status": "accepted"}),
                          },
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