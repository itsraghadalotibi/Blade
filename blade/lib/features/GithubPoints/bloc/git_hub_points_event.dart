abstract class GitHubPointsEvent {}

class FetchGitHubPointsEvent extends GitHubPointsEvent {
  final String repoUrl;

  FetchGitHubPointsEvent(this.repoUrl);
}

class FetchCommentsEvent extends GitHubPointsEvent {
  final String projectId;

  FetchCommentsEvent(this.projectId);
}
