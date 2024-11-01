
import 'package:flutter_bloc/flutter_bloc.dart';
import '../src/investment_request_repository.dart';
import 'investment_request_event.dart';
import 'investment_request_state.dart';


class InvestmentRequestBloc
    extends Bloc<InvestmentRequestEvent, InvestmentRequestState> {
  final InvestmentRequestRepository repository;

  InvestmentRequestBloc({required this.repository})
      : super(InvestmentRequestInitial()) {
    on<SubmitInvestmentRequest>(_onSubmitInvestmentRequest);
    on<FetchInvestmentRequests>(_onFetchInvestmentRequests);
  }

  Future<void> _onSubmitInvestmentRequest(SubmitInvestmentRequest event,
      Emitter<InvestmentRequestState> emit) async {
    emit(InvestmentRequestLoading());
    try {
      await repository.createInvestmentRequest(event.request);
      emit(InvestmentRequestSuccess());
    } catch (e) {
      emit(InvestmentRequestFailure(error: e.toString()));
    }
  }

  Future<void> _onFetchInvestmentRequests(FetchInvestmentRequests event,
      Emitter<InvestmentRequestState> emit) async {
    emit(InvestmentRequestLoading());
    try {
      final requests =
          await repository.getInvestmentRequestsByProject(event.projectId);
      emit(InvestmentRequestsLoaded(requests: requests));
    } catch (e) {
      emit(InvestmentRequestFailure(error: e.toString()));
    }
  }
}
