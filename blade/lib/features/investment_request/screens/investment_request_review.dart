import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/constants/colors.dart';
import '../../../widgets/investment_card.dart';
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
              MaterialPageRoute(builder: (context) => SuccessAnimationScreen(userId: request.supporterId,)),
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
          InvestmentRequestCard(request: request),
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
}
