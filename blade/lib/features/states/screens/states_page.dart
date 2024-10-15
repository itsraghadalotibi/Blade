import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../utils/constants/colors.dart';

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

        // Fetch the title from the 'ideas' collection.
        final ideaSnapshot = await FirebaseFirestore.instance
            .collection('ideas')
            .doc(ideaId)
            .get();
        final ideaTitle = ideaSnapshot.data()?['title'] ?? 'Unknown Idea';

        return {
          'id': doc.id, // Document ID for cancellation.
          'ideaTitle': ideaTitle,
          'status': data['status'] ?? "pending",
          'timestamp': ((data['timestamp'] ?? Timestamp.now()) as Timestamp).toDate(), // Convert timestamp to DateTime.
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

    // Define the same style used for the idea title in the card.
    final TextStyle ideaTitleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: screenWidth * 0.05 * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: TColors.textWhite,
        ) ?? const TextStyle();

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
              final ideaTitle = request['ideaTitle'];
              final status = request['status'];
              final timestamp = request['timestamp'];

              // Adjust the color of the status dynamically.
              final Color statusColor = status == 'pending'
                  ? Colors.amber
                  : status == 'accepted'
                      ? Colors.green
                      : Colors.red;

              return Padding(
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
                        // Left: Idea Title and Timestamp
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ideaTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: ideaTitleStyle, // Use idea title style
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
                        // Right: Status Text and Cancel Button for Pending Requests
                        Row(
                          children: [
                            // Status text using the same style as idea title, with dynamic color
                            Text(
                              status.toUpperCase(), // Display status in uppercase
                              style: ideaTitleStyle.copyWith(
                                color: statusColor,
                                fontSize: screenWidth * 0.045 * textScaleFactor, // Slightly smaller size
                              ),
                            ),
                            // Cancel button only for pending requests
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
              );
            },
          );
        },
      ),
    );
  }
}




