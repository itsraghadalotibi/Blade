
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
    on<FetchInvestmentRequestsBySupporter>(_onFetchInvestmentRequestsBySupporter);
    on<CancelInvestmentRequest>(_onCancelInvestmentRequest);
      on<AcceptInvestmentRequest>(_onAcceptInvestmentRequest);
    on<RejectInvestmentRequest>(_onRejectInvestmentRequest);
    on<FetchInvestmentRequestsForUserProjects>(_onFetchInvestmentRequestsForUserProjects);
  }

  Future<void> _onSubmitInvestmentRequest(
      SubmitInvestmentRequest event, Emitter<InvestmentRequestState> emit) async {
    emit(InvestmentRequestLoading());
    try {
      await repository.createInvestmentRequest(event.request);
      emit(InvestmentRequestSuccess());
    } catch (e) {
      emit(InvestmentRequestFailure(error: e.toString()));
    }
  }

  Future<void> _onFetchInvestmentRequests(
      FetchInvestmentRequests event,
      Emitter<InvestmentRequestState> emit) async {
    emit(InvestmentRequestLoading());
    try {
      final requests = await repository.getInvestmentRequests(event.projectId);
      emit(InvestmentRequestsLoaded(requests: requests));
    } catch (e) {
      emit(InvestmentRequestFailure(error: e.toString()));
    }
  }

  Future<void> _onFetchInvestmentRequestsBySupporter(
      FetchInvestmentRequestsBySupporter event,
      Emitter<InvestmentRequestState> emit) async {
    emit(InvestmentRequestLoading());
    try {
      final requests = await repository.getInvestmentRequestsBySupporter(event.supporterId);
      emit(InvestmentRequestsLoaded(requests: requests));
    } catch (e) {
      emit(InvestmentRequestFailure(error: e.toString()));
    }
  }

  Future<void> _onFetchInvestmentRequestsForUserProjects(
      FetchInvestmentRequestsForUserProjects event,
      Emitter<InvestmentRequestState> emit) async {
    emit(InvestmentRequestLoading());
    try {
      final requests =
          await repository.getInvestmentRequestsForUserProjects(event.userId);
      emit(InvestmentRequestsLoaded(requests: requests));
    } catch (e) {
      emit(InvestmentRequestFailure(error: e.toString()));
    }
  }
  Future<void> _onCancelInvestmentRequest(
    CancelInvestmentRequest event, Emitter<InvestmentRequestState> emit) async {
  emit(InvestmentRequestLoading());
  try {
    await repository.cancelInvestmentRequest(event.requestId);
    emit(InvestmentRequestSuccess());

    // Emit an event to fetch updated requests
    add(FetchInvestmentRequestsBySupporter(supporterId: event.supporterId));
  } catch (e) {
    emit(InvestmentRequestFailure(error: e.toString()));
  }
}
Future<void> _onAcceptInvestmentRequest(
    AcceptInvestmentRequest event, Emitter<InvestmentRequestState> emit) async {
  emit(InvestmentRequestLoading());
  try {
    await repository.updateRequestStatus(event.requestId, "Accepted");
    emit(InvestmentRequestSuccess());
    add(FetchInvestmentRequests(projectId: event.projectId)); // Fetch updated list
  } catch (e) {
    emit(InvestmentRequestFailure(error: e.toString()));
  }
}

Future<void> _onRejectInvestmentRequest(
    RejectInvestmentRequest event, Emitter<InvestmentRequestState> emit) async {
  emit(InvestmentRequestLoading());
  try {
    await repository.updateRequestStatus(
      event.requestId,
      "Rejected",
      reasonForRejection: event.reasonForRejection,
    );
    emit(InvestmentRequestSuccess());
    add(FetchInvestmentRequests(projectId: event.projectId)); // Fetch updated list
  } catch (e) {
    emit(InvestmentRequestFailure(error: e.toString()));
  }
}
}
