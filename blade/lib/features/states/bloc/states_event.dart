// states_event.dart
import 'package:equatable/equatable.dart';

abstract class StatesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Event to load all join requests for a specific user
class LoadStates extends StatesEvent {
  final String requesterId;

  LoadStates(this.requesterId);

  @override
  List<Object?> get props => [requesterId];
}
