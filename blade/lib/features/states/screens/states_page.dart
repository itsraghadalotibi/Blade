import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../GithubPoints/bloc/git_hub_points_bloc.dart';
import '../../project_info/screens/project_screen.dart';
import '../../../utils/constants/colors.dart';
import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:blade_app/features/announcement/src/announcement_repository.dart';

class StatesPage extends StatelessWidget {
  const StatesPage({Key? key}) : super(key: key);

  // Stream to fetch join requests in real-time.
  Stream<List<Map<String, dynamic>>> streamJoinRequests(String userId) {
    return FirebaseFirestore.instance
        .collection('join_requests')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      return Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();
        final ideaId = data['ideaId'];

        try {
          // Fetch the idea from the ideas collection
          final ideaSnapshot = await FirebaseFirestore.instance
              .collection('ideas')
              .doc(ideaId)
              .get();

          if (!ideaSnapshot.exists) {
            // If the idea is deleted, return the title from join_requests
            return {
              'id': doc.id,
              'idea': null,
              'title': data['title'] ?? 'Unknown Project',
              'status': 'deleted',
              'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            };
          }

          final idea = Idea.fromMap(ideaSnapshot.data()!, ideaId);
          return {
            'id': doc.id,
            'idea': idea,
            'title': idea.title,
            'status': data['status'] ?? 'pending',
            'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          };
        } catch (e) {
          print('Error fetching idea: $e');
          return {
            'id': doc.id,
            'idea': null,
            'title': data['title'] ?? 'Unknown Project',
            'status': 'deleted',
            'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          };
        }
      }).toList());
    });
  }

  // Function to cancel a join request.
  Future<void> cancelJoinRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('join_requests')
          .doc(requestId)
          .delete();
      print('Join request $requestId cancelled successfully');
    } catch (e) {
      print('Error cancelling join request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Text style for the idea title with a smaller font size.
    final TextStyle ideaTitleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: screenWidth * 0.04 * textScaleFactor, // Adjusted font size
          fontWeight: FontWeight.w600, // Slightly lighter weight
        ) ?? const TextStyle();

    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: streamJoinRequests(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: screenWidth * 0.045,
                    ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No join requests found.',
                style: TextStyle(color: TColors.textSecondary),
              ),
            );
          }

          final joinRequests = snapshot.data!;
          joinRequests.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
              horizontal: screenWidth * 0.05,
            ),
            itemCount: joinRequests.length,
            itemBuilder: (context, index) {
              final request = joinRequests[index];
              final requestId = request['id'];
              final idea = request['idea'] as Idea?;
              final title = request['title'];
              final status = request['status'];
              final timestamp = request['timestamp'];

              final Color statusColor =
                  status == 'deleted' ? Colors.grey : _getStatusColor(status);

              return GestureDetector(
                onTap: () {
                  // Forward to project info when the card is tapped
                  if (idea != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectScreen(
                          canSendComment: true,
                          idea: idea,
                          repository: AnnouncementRepository(),
                          canJoin: !idea.isJoined!,
                          onJoinRequestSent: null,
                          gitHubPointsBloc: BlocProvider.of<GitHubPointsBloc>(context), 
                        ),
                      ),
                    );
                  }
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: idea != null
                                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.2),
                              child: Icon(
                                idea != null ? Icons.lightbulb : Icons.error_outline,
                                size: 30,
                                color: idea != null
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: ideaTitleStyle.copyWith(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${DateFormat('MMMM dd, yyyy').format(timestamp)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: TColors.textSecondary,
                                          fontSize: screenWidth * 0.035,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status == 'deleted'
                                    ? 'Deleted'
                                    : status[0].toUpperCase() + status.substring(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Description for Deleted Projects
                        if (status == 'deleted')
                          Text(
                            'This project has been deleted and is no longer available.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                          ),

                        // Cancel Request Button
                        if (status == 'pending' && idea != null)
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 20,
                                ),
                              ),
                              onPressed: () =>
                                  _showCancelConfirmationDialog(context, requestId),
                              child: const Text(
                                'Cancel Request',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCancelConfirmationDialog(BuildContext context, String requestId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            "Cancel Request",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Are you sure you want to cancel this request?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                cancelJoinRequest(requestId);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.amber[800]!;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'deleted':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}