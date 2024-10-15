import 'package:equatable/equatable.dart';

abstract class StatesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAllProjectsRequests extends StatesEvent {
  final String requesterId;

  LoadAllProjectsRequests(this.requesterId);

  @override
  List<Object?> get props => [requesterId];
}

