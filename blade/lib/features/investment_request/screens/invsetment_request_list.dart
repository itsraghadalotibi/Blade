

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/investment_request_bloc.dart';
import '../bloc/investment_request_event.dart';
import '../bloc/investment_request_state.dart';
import 'investment_request_details.dart';

class InvestmentRequestsListScreen extends StatelessWidget {
  final String projectId;

  const InvestmentRequestsListScreen({Key? key, required this.projectId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    context
        .read<InvestmentRequestBloc>()
        .add(FetchInvestmentRequests(projectId: projectId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Investment Requests'),
      ),
      body: BlocBuilder<InvestmentRequestBloc, InvestmentRequestState>(
        builder: (context, state) {
          if (state is InvestmentRequestLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is InvestmentRequestsLoaded) {
            if (state.requests.isEmpty) {
              return Center(child: Text('No investment requests.'));
            }
            return ListView.builder(
              itemCount: state.requests.length,
              itemBuilder: (context, index) {
                final request = state.requests[index];
                return ListTile(
                  title: Text(request.supporterName),
                  subtitle: Text('Offer: ${request.offer}'),
                  trailing: Text(
                    'Valid Until: ${request.validUntil.toLocal().toString().split(' ')[0]}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InvestmentRequestDetailScreen(
                          request: request,
                        ),
                      ),
                    );
                  },
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
}
