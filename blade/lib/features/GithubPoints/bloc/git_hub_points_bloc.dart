import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'git_hub_points_event.dart';
import 'git_hub_points_state.dart';

class GitHubPointsBloc extends Bloc<GitHubPointsEvent, GitHubPointsState> {
  final _secureStorage = const FlutterSecureStorage(); // Secure storage instance
  int totalPoints = 0;

  GitHubPointsBloc() : super(GitHubPointsInitial()) {
    on<FetchGitHubPointsEvent>(_onFetchGitHubPoints);
  }

  // Fetch commits and calculate points
  Future<void> _onFetchGitHubPoints(
      FetchGitHubPointsEvent event, Emitter<GitHubPointsState> emit) async {
    print("Event received in Bloc with URL: ${event.repoUrl}");
    emit(GitHubPointsLoading());

    try {
      // Retrieve the GitHub access token
      final accessToken = await _secureStorage.read(key: 'github_access_token');
      if (accessToken == null || accessToken.isEmpty) {
        emit(GitHubPointsError("GitHub access token not available"));
        return;
      }

      // Parse repo owner and name from the provided URL
      final repoDetails = event.repoUrl.split("github.com/")[1].split("/");
      final owner = repoDetails[0];
      final repo = repoDetails[1];

      print("Owner: $owner, Repo: $repo - Preparing API request...");
      final url = Uri.parse('https://api.github.com/repos/$owner/$repo/commits');

      // Include token in the request headers
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      print("API response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Calculate commit count and award points
        int commitsCount = data.length;
        int commitPoints = 0;

        // Award points based on commit count
        if (commitsCount >= 10) {
          commitPoints += 15;
          commitPoints += ((commitsCount - 10) ~/ 30) * 15;
        }

        totalPoints += commitPoints; // Add commit points to total
        print('Fetched Commit Count: $commitsCount');
        print('Total Points awarded so far: $totalPoints');

        _emitProgress(emit, commitsCount);
      } else {
        print('Failed to fetch commits: ${response.statusCode}');
        emit(GitHubPointsError('Failed to fetch repository commits'));
      }
    } catch (e) {
      print('Error: $e');
      emit(GitHubPointsError('Error: $e'));
    }
  }

  // Calculate progress and emit the state
  void _emitProgress(Emitter<GitHubPointsState> emit, int count) {
    const int goal = 500;
    double progress = (totalPoints / goal).clamp(0, 1);

    emit(GitHubPointsLoaded(commitsCount: count, progress: progress));
  }
}
