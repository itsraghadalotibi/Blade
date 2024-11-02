import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../utils/constants/colors.dart';
import '../bloc/investment_request_bloc.dart';
import '../bloc/investment_request_event.dart';
import '../bloc/investment_request_state.dart';
import '../src/investment_request_model.dart';
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
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InvestmentRequestDetailScreen(
                          request: request,
                          isOwner: isOwner,
                        ),
                      ),
                    );
                    if (result is Map<String, dynamic>) {
                      if (result["status"] == "accepted") {
                        context.read<InvestmentRequestBloc>().add(
                              AcceptInvestmentRequest(
                                requestId: request.id,
                                projectId: projectId,
                              ),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              backgroundColor: TColors.success,
                              behavior: SnackBarBehavior.floating,
                              content: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(
                                      CupertinoIcons.check_mark_circled_solid,
                                      color: Colors
                                          .white), // Change icon and color as needed
                                  const SizedBox(
                                      width: 8), // Space between icon and text
                                  const Expanded(
                                    child: Text(
                                      'Request Accepted',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              showCloseIcon: true),
                        );
                      } else if (result["status"] == "rejected") {
                        final rejectionReason = result["reason"];
                        context.read<InvestmentRequestBloc>().add(
                              RejectInvestmentRequest(
                                requestId: request.id,
                                projectId: projectId,
                                reasonForRejection: rejectionReason,
                              ),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              backgroundColor: TColors.success,
                              behavior: SnackBarBehavior.floating,
                              content: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(
                                      CupertinoIcons.check_mark_circled_solid,
                                      color: Colors
                                          .white), // Change icon and color as needed
                                  const SizedBox(
                                      width: 8), // Space between icon and text
                                  const Expanded(
                                    child: Text(
                                      'Request Rejected',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              showCloseIcon: true),
                        );
                      }
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? TColors.container : TColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: isDarkMode
                          ? null // No border in dark mode
                          : Border.all(
                              color:
                                  TColors.borderPrimary), // Light mode border
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (isOwner && request.status == 'Pending')
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          side: const BorderSide(
                                              color: Colors.red),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 12.0),
                                        ),
                                        onPressed: () {
                                          _showRejectDialog(context, request);
                                        },
                                        child: const Text('Reject'),
                                      ),
                                    ),
                                  const SizedBox(width: 16),
                                  if (isOwner &&
                                      request.status ==
                                          'Pending') // Only show buttons if the user is the project owner
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          side: const BorderSide(
                                              color: Colors.green),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 12.0),
                                        ),
                                        onPressed: () {
                                          context
                                              .read<InvestmentRequestBloc>()
                                              .add(AcceptInvestmentRequest(
                                                requestId: request.id,
                                                projectId: projectId,
                                              ));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                backgroundColor:
                                                    TColors.success,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                content: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    const Icon(
                                                        CupertinoIcons
                                                            .check_mark_circled_solid,
                                                        color: Colors
                                                            .white), // Change icon and color as needed
                                                    const SizedBox(
                                                        width:
                                                            8), // Space between icon and text
                                                    const Expanded(
                                                      child: Text(
                                                        'Request Accepted',
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                showCloseIcon: true),
                                          );
                                        },
                                        child: const Text('Accept'),
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

  void _showRejectDialog(
      BuildContext outerContext, InvestmentRequestModel request) {
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
                      outerContext.read<InvestmentRequestBloc>().add(
                            RejectInvestmentRequest(
                              requestId: request.id,
                              projectId: projectId,
                              reasonForRejection: reason,
                            ),
                          );
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor: TColors.success,
                            behavior: SnackBarBehavior.floating,
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                    CupertinoIcons.check_mark_circled_solid,
                                    color: Colors
                                        .white), // Change icon and color as needed
                                const SizedBox(
                                    width: 8), // Space between icon and text
                                const Expanded(
                                  child: Text(
                                    'Request Rejected',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            showCloseIcon: true),
                      );
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
