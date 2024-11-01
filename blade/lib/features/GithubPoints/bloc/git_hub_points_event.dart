import 'package:equatable/equatable.dart';

abstract class GitHubPointsEvent extends Equatable {
  const GitHubPointsEvent();
  @override
  List<Object> get props => [];
}

class FetchGitHubPointsEvent extends GitHubPointsEvent {
  final String repoUrl;
  const FetchGitHubPointsEvent(this.repoUrl);
}

class CommitLinesEvent extends GitHubPointsEvent {
  final int lines;
  const CommitLinesEvent(this.lines);
}

class CloseIssueEvent extends GitHubPointsEvent {
  const CloseIssueEvent();
}
