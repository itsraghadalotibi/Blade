import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:blade_app/features/announcement/src/announcement_repository.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../project_info/screens/project_screen.dart';
import '../../../utils/constants/colors.dart';

import 'package:blade_app/features/announcement/screens/announcement_screen.dart';


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

        // Fetch the full idea object from Firestore.
        final ideaSnapshot = await FirebaseFirestore.instance
            .collection('ideas')
            .doc(ideaId)
            .get();

        final idea = Idea.fromMap(ideaSnapshot.data()!, ideaId);

        return {
          'id': doc.id,  // Document ID for cancellation.
          'idea': idea,  // Full idea object.
          'status': data['status'] ?? 'pending',
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        };
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

    // Text style for the idea title.
    final TextStyle ideaTitleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: screenWidth * 0.05 * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: TColors.textWhite,
        ) ??
        const TextStyle();

    return Scaffold(
      backgroundColor: isDarkMode ? TColors.dark : TColors.primaryBackground,
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

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
              horizontal: screenWidth * 0.05,
            ),
            itemCount: joinRequests.length,
            itemBuilder: (context, index) {
              final request = joinRequests[index];
              final requestId = request['id'];
              final idea = request['idea'] as Idea;
              final status = request['status'];
              final timestamp = request['timestamp'];

              // Adjust the status color dynamically.
              final Color statusColor = _getStatusColor(status);

              return GestureDetector(
                onTap: () {
                  // Navigate to ProjectScreen on tap.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectScreen(
                        idea: idea,
                        repository: AnnouncementRepository(), // Replace with actual repository instance.
                        canJoin: !idea.isJoined!, onJoinRequestSent: null, // Check if the user can join the project.
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? TColors.container : TColors.container,
                      borderRadius: BorderRadius.circular(23),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left: Idea title and timestamp.
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  idea.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: ideaTitleStyle,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Requested On: $timestamp',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: screenWidth * 0.035 * textScaleFactor,
                                        color: TColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          // Right: Status text and cancel button for pending requests.
                          Row(
                            children: [
                              Text(
                                status.toUpperCase(),
                                style: ideaTitleStyle.copyWith(
                                  color: statusColor,
                                  fontSize: screenWidth * 0.045 * textScaleFactor,
                                ),
                              ),
                              if (status == 'pending') ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: screenWidth * 0.07,
                                  ),
                                  onPressed: () => cancelJoinRequest(requestId),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
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

  // Helper to get color based on status.
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.amber;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
