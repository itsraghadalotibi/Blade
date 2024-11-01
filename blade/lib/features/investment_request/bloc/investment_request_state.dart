

import '../src/investment_request_model.dart';
abstract class InvestmentRequestState {}

class InvestmentRequestInitial extends InvestmentRequestState {}

class InvestmentRequestLoading extends InvestmentRequestState {}

class InvestmentRequestSuccess extends InvestmentRequestState {}

class InvestmentRequestFailure extends InvestmentRequestState {
  final String error;
  InvestmentRequestFailure({required this.error});
}

class InvestmentRequestsLoaded extends InvestmentRequestState {
  final List<InvestmentRequestModel> requests;
  InvestmentRequestsLoaded({required this.requests});
}
class InvestmentRequestCanceled extends InvestmentRequestState {}