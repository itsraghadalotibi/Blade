// states_page_state.dart
import 'package:equatable/equatable.dart';

abstract class StatesPageState extends Equatable {
  @override
  List<Object?> get props => [];
}

// State when the join requests are loading
class StatesLoading extends StatesPageState {}

// State when join requests are successfully loaded
class StatesLoaded extends StatesPageState {
  final List<Map<String, dynamic>> joinRequests;

  StatesLoaded(this.joinRequests);

  @override
  List<Object?> get props => [joinRequests];
}

// State when there is an error loading join requests
class StatesError extends StatesPageState {
  final String error;

  StatesError(this.error);

  @override
  List<Object?> get props => [error];
}
