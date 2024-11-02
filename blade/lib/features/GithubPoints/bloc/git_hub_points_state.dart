import 'package:equatable/equatable.dart';

abstract class GitHubPointsState extends Equatable {
  const GitHubPointsState();
  @override
  List<Object> get props => [];
}

class GitHubPointsInitial extends GitHubPointsState {}

class GitHubPointsLoading extends GitHubPointsState {}

class GitHubPointsLoaded extends GitHubPointsState {
  final int commitsCount;
  final double progress;

  const GitHubPointsLoaded({required this.commitsCount, required this.progress});

  @override
  List<Object> get props => [commitsCount, progress];
}

class GitHubPointsError extends GitHubPointsState {
  final String message;

  const GitHubPointsError(this.message);

  @override
  List<Object> get props => [message];
}
