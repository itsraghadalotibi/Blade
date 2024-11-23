

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
class AcceptInvestmentRequest extends InvestmentRequestEvent {
  final String requestId;
  final String projectId; // Add projectId here

  AcceptInvestmentRequest({required this.requestId, required this.projectId});
}

class RejectInvestmentRequest extends InvestmentRequestEvent {
  final String requestId;
  final String reasonForRejection;
  final String projectId; // Add projectId here

  RejectInvestmentRequest({
    required this.requestId,
    required this.reasonForRejection,
    required this.projectId,
  });
}
class FetchInvestmentRequestsForUserProjects extends InvestmentRequestEvent {
  final String userId;
  FetchInvestmentRequestsForUserProjects({required this.userId});
}