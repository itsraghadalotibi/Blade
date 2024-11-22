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
  final int postCount;
  final double progress;
  final int totalPoints;

  const GitHubPointsLoaded({
    required this.commitsCount,
    required this.postCount,
    required this.progress,
    required this.totalPoints,
  });

  @override
  List<Object> get props => [commitsCount, postCount, progress, totalPoints];
}

class GitHubPointsError extends GitHubPointsState {
  final String message;

  const GitHubPointsError(this.message);

  @override
  List<Object> get props => [message];
}
