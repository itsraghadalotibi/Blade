import 'package:equatable/equatable.dart';

abstract class StatesPageState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StatesLoading extends StatesPageState {}

class ProjectsLoaded extends StatesPageState {
  final List<Map<String, dynamic>> projectRequests;

  ProjectsLoaded(this.projectRequests);

  @override
  List<Object?> get props => [projectRequests];
}

class StatesError extends StatesPageState {
  final String error;

  StatesError(this.error);

  @override
  List<Object?> get props => [error];
}

