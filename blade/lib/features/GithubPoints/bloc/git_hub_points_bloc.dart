import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'git_hub_points_event.dart';
import 'git_hub_points_state.dart';

class GitHubPointsBloc extends Bloc<GitHubPointsEvent, GitHubPointsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _secureStorage = const FlutterSecureStorage();
  int totalPoints = 0;
  int postPoints = 0;
  int commitPoints = 0;

  GitHubPointsBloc() : super(GitHubPointsInitial()) {
    on<FetchGitHubPointsEvent>(_onFetchGitHubPoints);
    on<NewPostCreatedEvent>(_onNewPostCreated);
    on<UpdatePointsEvent>(_onUpdatePoints); 
    on<PostDeletedEvent>(_onPostDeleted); // Add event for post deletion
  }

  // Fetch GitHub commits and calculate commit points
  Future<void> _onFetchGitHubPoints(
      FetchGitHubPointsEvent event, Emitter<GitHubPointsState> emit) async {
    emit(GitHubPointsLoading());
    try {
      final accessToken = await _secureStorage.read(key: 'github_access_token');
      if (accessToken == null || accessToken.isEmpty) {
        emit(GitHubPointsError("GitHub access token not available"));
        return;
      }

      final repoDetails = event.repoUrl.split("github.com/")[1].split("/");
      final owner = repoDetails[0];
      final repo = repoDetails[1];

      final url = Uri.parse('https://api.github.com/repos/$owner/$repo/commits');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        int commitsCount = data.length;

        // Calculate commit points
        commitPoints = _calculateCommitPoints(commitsCount);
        totalPoints = commitPoints + postPoints;

        _emitProgress(emit, commitsCount, postPoints, totalPoints, event.projectId);
      } else {
        emit(GitHubPointsError('Failed to fetch repository commits'));
      }
    } catch (e) {
      emit(GitHubPointsError('Error: $e'));
    }
  }

  // Handle new post event
  Future<void> _onNewPostCreated(
      NewPostCreatedEvent event, Emitter<GitHubPointsState> emit) async {
    try {
      final postsSnapshot = await _firestore
          .collection('posts')
          .where('ideaId', isEqualTo: event.projectId)
          .get();

      int postCount = postsSnapshot.docs.length;

      // Award points for posts
      if (postCount > 0) {
        postPoints = 50 + (postCount - 1) * 15; // 50 points for the first post, 15 for each additional
      } else {
        postPoints = 0;
      }

      totalPoints = commitPoints + postPoints;

      _emitProgress(emit, commitPoints, postCount, totalPoints, event.projectId);
    } catch (e) {
      emit(GitHubPointsError('Failed to fetch posts for project: $e'));
    }
  }

  // Handle dynamic point updates
  Future<void> _onUpdatePoints(
      UpdatePointsEvent event, Emitter<GitHubPointsState> emit) async {
    try {
      // Update points dynamically based on event values
      totalPoints = event.newCommitPoints + event.newPostPoints;
      commitPoints = event.newCommitPoints;
      postPoints = event.newPostPoints;

      _emitProgress(
          emit, commitPoints, postPoints, totalPoints, event.projectId);
    } catch (e) {
      emit(GitHubPointsError('Failed to update points: $e'));
    }
  }

  // Handle post deletion event
  Future<void> _onPostDeleted(
      PostDeletedEvent event, Emitter<GitHubPointsState> emit) async {
    try {
      // Deduct points for the deleted post
      postPoints -= event.postPointsToRemove;
      totalPoints = commitPoints + postPoints;

      // Emit updated progress
      _emitProgress(emit, commitPoints, postPoints, totalPoints, event.projectId);
    } catch (e) {
      emit(GitHubPointsError('Error processing post deletion: $e'));
    }
  }

  // Emit progress and save points to Firestore
  void _emitProgress(
      Emitter<GitHubPointsState> emit,
      int commitsCount,
      int postCount,
      int totalPoints,
      String projectId) {
    const int goal = 500;
    double progress = (totalPoints / goal).clamp(0, 1);

    // Save total points to Firestore
    _firestore.collection('ideas').doc(projectId).update({
      'points': totalPoints,
      'progress': progress,
    }).catchError((e) {
      emit(GitHubPointsError('Failed to update points in Firestore: $e'));
    });

    emit(GitHubPointsLoaded(
      commitsCount: commitsCount,
      postCount: postCount,
      progress: progress,
      totalPoints: totalPoints,
    ));
  }

  // Helper to calculate commit points
  int _calculateCommitPoints(int commitsCount) {
    int points = 0;
    if (commitsCount >= 10) {
      points += 50; // First 10 commits
      points += ((commitsCount - 10) ~/ 5) * 15; // 15 points for every 5 commits after the first 10
    } else {
      points += commitsCount * 5; // Adjust points for commits below 10 if needed
    }
    return points;
  }
}
