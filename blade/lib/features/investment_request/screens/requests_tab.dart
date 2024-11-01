import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/constants/colors.dart';
import '../../../widgets/investment_card.dart';
import '../bloc/investment_request_bloc.dart';
import '../bloc/investment_request_event.dart';
import '../bloc/investment_request_state.dart';
import '../src/investment_request_model.dart';
import '../src/investment_request_repository.dart';

class OffersTab extends StatelessWidget {
  final String supporterId;

  const OffersTab({Key? key, required this.supporterId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BlocProvider(
      create: (context) => InvestmentRequestBloc(repository: context.read())
        ..add(FetchInvestmentRequestsBySupporter(supporterId: supporterId)),
      child: BlocListener<InvestmentRequestBloc, InvestmentRequestState>(
        listener: (context, state) {
          if (state is InvestmentRequestSuccess) {
            // Re-fetch the list after a successful cancellation
            context.read<InvestmentRequestBloc>().add(
                FetchInvestmentRequestsBySupporter(supporterId: supporterId));
          }
        },
        child: BlocBuilder<InvestmentRequestBloc, InvestmentRequestState>(
          builder: (context, state) {
            if (state is InvestmentRequestLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is InvestmentRequestsLoaded) {
              final requests = state.requests;
              return requests.isNotEmpty
                  ? ListView.builder(
                      itemCount: requests.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        final iconPath =
                            request.iconPath ?? 'assets/icons/default_icon.png';
                        final isPending = request.status == 'Pending';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    InvestmentRequestDetailScreen(
                                        request: request),
                              ),
                            ).then((cancelReq) {
                              if (cancelReq == true) {
                                context.read<InvestmentRequestBloc>().add(
                                    CancelInvestmentRequest(
                                        requestId: request.id,
                                        supporterId: supporterId));
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? TColors.container
                                  : TColors.white,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      iconPath.endsWith('.svg')
                                          ? SvgPicture.asset(iconPath,
                                              width: 40, height: 40)
                                          : Image.asset(iconPath,
                                              width: 40, height: 40),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                        decoration: BoxDecoration(
                                          color:
                                              _getStatusColor(request.status),
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                                  const SizedBox(height: 4),
                                  if (isPending)
                                    Align(
                                      alignment: Alignment.center,
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            _confirmCancel(context, request),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(
                                              color: Colors.red),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 0.0, horizontal: 8.0),
                                        ),
                                        child: const Text('Cancel Request'),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(child: Text("No requests available"));
            } else if (state is InvestmentRequestFailure) {
              return Center(child: Text("Error: ${state.error}"));
            }
            return const Center(child: Text("No data available"));
          },
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, InvestmentRequestModel request) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Cancel Request"),
          content: const Text("Are you sure you want to cancel this request?"),
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
                context.read<InvestmentRequestBloc>().add(
                    CancelInvestmentRequest(
                        requestId: request.id, supporterId: supporterId));
              },
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Pending':
        return Colors.amber[700]!;
      case 'Rejected':
        return Colors.red;
      case 'Cancelled':
        return Colors.grey[600]!;
      default:
        return Colors.black;
    }
  }
}

class InvestmentRequestDetailScreen extends StatelessWidget {
  final InvestmentRequestModel request;

  const InvestmentRequestDetailScreen({Key? key, required this.request})
      : super(key: key);

  void _cancelRequest(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Cancel Request"),
          content: const Text("Are you sure you want to cancel this request?"),
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
                Navigator.pop(context, true);
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
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Return'),
                  ),
                ),
                const SizedBox(width: 12.0),
                if (request.status == 'Pending')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _cancelRequest(context),
                      child: const Text('Cancel Request'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
