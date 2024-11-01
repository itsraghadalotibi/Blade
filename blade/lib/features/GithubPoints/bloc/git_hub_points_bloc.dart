import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'git_hub_points_event.dart';
import 'git_hub_points_state.dart';

class GitHubPointsBloc extends Bloc<GitHubPointsEvent, GitHubPointsState> {
  GitHubPointsBloc() : super(GitHubPointsInitial()) {
    // Register event handler for FetchGitHubPointsEvent
    on<FetchGitHubPointsEvent>(_onFetchGitHubPoints);
  }

  Future<void> _onFetchGitHubPoints(
      FetchGitHubPointsEvent event, Emitter<GitHubPointsState> emit) async {
    print("Event received in Bloc with URL: ${event.repoUrl}");
    emit(GitHubPointsLoading());

    try {
      // Parse repo owner and name from the provided URL
      final repoDetails = event.repoUrl.split("github.com/")[1].split("/");
      final owner = repoDetails[0];
      final repo = repoDetails[1];
      
      print("Owner: $owner, Repo: $repo - Preparing API request...");
      final url = Uri.parse('https://api.github.com/repos/$owner/$repo/commits');
      final response = await http.get(url);

      print("API response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Calculate commit count and award points
        int commitsCount = data.length; // Total number of commits
        int points = 0; // Points to be awarded

        // Award 15 points for the first 10 lines (if there are at least 10 commits)
        if (commitsCount >= 10) {
          points += 15;
          // Award additional 15 points for every 50 lines committed after the first 10 lines
          points += ((commitsCount - 10) ~/ 50) * 15;
        }

        // Debugging output
        print('Fetched Commit Count: $commitsCount');
        print('Points awarded: $points');

        // Set progress based on awarded points
        const int goal = 500; // Set goal to 500 points
        final double progress = (points / goal).clamp(0, 1); // Cap progress at 100%

        // Emit loaded state with commit count and progress
        emit(GitHubPointsLoaded(commitsCount: commitsCount, progress: progress));
      } else {
        // Handle errors by emitting an error state
        print('Failed to fetch commits: ${response.statusCode}');
        emit(GitHubPointsError('Failed to fetch repository commits'));
      }
    } catch (e) {
      print('Error: $e');
      emit(GitHubPointsError('Error: $e'));
    }
  }
}
