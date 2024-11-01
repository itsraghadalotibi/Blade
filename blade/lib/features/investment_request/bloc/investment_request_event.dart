

import '../src/investment_request_model.dart';
abstract class InvestmentRequestEvent {}

class SubmitInvestmentRequest extends InvestmentRequestEvent {
  final InvestmentRequestModel request;
  SubmitInvestmentRequest({required this.request});
}

class FetchInvestmentRequests extends InvestmentRequestEvent {
  final String projectId;
  FetchInvestmentRequests({required this.projectId});
}

class FetchInvestmentRequestsBySupporter extends InvestmentRequestEvent {
  final String supporterId;
  FetchInvestmentRequestsBySupporter({required this.supporterId});
}
class CancelInvestmentRequest extends InvestmentRequestEvent {
  final String requestId;
  final String supporterId;

  CancelInvestmentRequest({required this.requestId, required this.supporterId});
}