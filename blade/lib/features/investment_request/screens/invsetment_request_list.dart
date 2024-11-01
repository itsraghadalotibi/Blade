import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../utils/constants/colors.dart';
import '../bloc/investment_request_bloc.dart';
import '../bloc/investment_request_event.dart';
import '../bloc/investment_request_state.dart';
import 'investment_request_details.dart';

class InvestmentRequestsListScreen extends StatelessWidget {
  final String projectId;
  final bool isOwner; //to determine if the user is the project owner

  const InvestmentRequestsListScreen({
    Key? key,
    required this.projectId,
    required this.isOwner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    context
        .read<InvestmentRequestBloc>()
        .add(FetchInvestmentRequests(projectId: projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Requests'),
      ),
      body: BlocBuilder<InvestmentRequestBloc, InvestmentRequestState>(
        builder: (context, state) {
          if (state is InvestmentRequestLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is InvestmentRequestsLoaded) {
            if (state.requests.isEmpty) {
              return const Center(child: Text('No investment requests.'));
            }
            return ListView.builder(
              itemCount: state.requests.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final request = state.requests[index];
                final iconPath =
                    request.iconPath ?? 'assets/icons/default_icon.png';
                final isPending = request.status == 'Pending';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InvestmentRequestDetailScreen(
                          request: request,
                          isOwner: isOwner,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? TColors.container : TColors.white,
                      borderRadius: BorderRadius.circular(12),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.grey.withOpacity(0.3),
                      //     spreadRadius: 2,
                      //     blurRadius: 5,
                      //     offset: const Offset(0, 3),
                      //   ),
                      // ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              iconPath.endsWith('.svg')
                                  ? SvgPicture.asset(iconPath,
                                      width: 40, height: 40)
                                  : Image.asset(iconPath,
                                      width: 40, height: 40),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request.projectName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      request.offer,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Valid until: ${request.validUntil.toLocal().toString().split(' ')[0]}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Status indicator button on the right
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                margin: EdgeInsets.only(left: 10.0),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(request.status),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  request.status ?? 'Pending',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (isPending)
                            Align(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (isOwner)
                                    Expanded(
                                      child: ElevatedButton(
                                       child: const Text('Reject'),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            side: const BorderSide(color: Colors.red),
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                                           ),
                                        onPressed: () {
                                          // context.read<InvestmentRequestBloc>().add(
                                          //       RejectInvestmentRequest(
                                          //         requestId: request.id,
                                          //         projectId: projectId,
                                          //       ),
                                          //     );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                  if (isOwner) // Only show buttons if the user is the project owner
                                    Expanded(
                                      child: ElevatedButton(
                                        child: const Text('Accept'),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            side: const BorderSide(color: Colors.green),
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                                           ),
                                        onPressed: () {
                                          // context.read<InvestmentRequestBloc>().add(
                                          //       AcceptInvestmentRequest(
                                          //         requestId: request.id,
                                          //         projectId: projectId,
                                          //       ),
                                          //     );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (state is InvestmentRequestFailure) {
            return Center(child: Text('Error: ${state.error}'));
          } else {
            return Container();
          }
        },
      ),
    );
  }
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Pending':
        return Colors.amber[800]!;
      case 'Rejected':
        return Colors.red;
      case 'Cancelled':
        return Colors.blue;
      case 'Expired':
        return Colors.grey[600]!;
      default:
        return Colors.purple;
    }
  }
}
