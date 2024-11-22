abstract class GitHubPointsEvent {}

// Event to fetch GitHub points (commits)
class FetchGitHubPointsEvent extends GitHubPointsEvent {
  final String repoUrl;
  final String projectId; // Added projectId for better context

  FetchGitHubPointsEvent(this.repoUrl, this.projectId);
}

// Event for when a new post is created
class NewPostCreatedEvent extends GitHubPointsEvent {
  final String projectId;

  NewPostCreatedEvent(this.projectId);
}

// Event to update points dynamically
class UpdatePointsEvent extends GitHubPointsEvent {
  final String projectId;
  final int newCommitPoints;
  final int newPostPoints;

  UpdatePointsEvent({
    required this.projectId,
    required this.newCommitPoints,
    required this.newPostPoints,
  });
}
