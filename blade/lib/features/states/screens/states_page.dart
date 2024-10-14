import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../utils/constants/colors.dart';

class StatesPage extends StatelessWidget {
  const StatesPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchJoinRequests(String userId) async {
    try {
      // Query the join_requests collection filtered by the current user ID.
      final querySnapshot = await FirebaseFirestore.instance
          .collection('join_requests')
          .where('userId', isEqualTo: userId)
          .get();

      print('Fetched ${querySnapshot.docs.length} join requests'); // Debug log

      // Use Future.wait to fetch all ideas titles in parallel.
      final joinRequests = await Future.wait(
        querySnapshot.docs.map((doc) async {
          final data = doc.data();
          final ideaId = data['ideaId'];

          // Fetch the idea's title from the 'ideas' collection.
          final ideaSnapshot = await FirebaseFirestore.instance
              .collection('ideas')
              .doc(ideaId)
              .get();

          final ideaTitle = ideaSnapshot.data()?['title'] ?? 'Unknown Idea';

          return {
            'ideaTitle': ideaTitle,
            'status': data['status'] ?? "pending",
            'timestamp': ((data['timestamp'] ?? Timestamp.now()) as Timestamp).toDate(), // Convert timestamp to DateTime.
          };
        }).toList(),
      );

      return joinRequests;
    } catch (e) {
      throw Exception('Error fetching join requests: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: isDarkMode ? TColors.dark : TColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? TColors.textWhite : TColors.textPrimary,
              ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchJoinRequests(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(
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
              final ideaTitle = request['ideaTitle'];
              final status = request['status'];
              final timestamp = request['timestamp'];

              // Define status icons and colors.
              IconData statusIcon;
              Color statusColor;
              String statusMessage;

              if (status == 'accepted') {
                statusIcon = Icons.check_circle;
                statusColor = Colors.green;
                statusMessage = 'Accepted';
              } else if (status == 'rejected') {
                statusIcon = Icons.cancel;
                statusColor = Colors.red;
                statusMessage = 'Rejected';
              } else {
                statusIcon = Icons.hourglass_top;
                statusColor = Colors.amber;
                statusMessage = 'Pending';
              }

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
                                style: TextStyle(
                                  fontSize: screenWidth *
                                      0.05 *
                                      textScaleFactor,
                                  fontWeight: FontWeight.bold,
                                  color: TColors.textWhite,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Requested On: $timestamp',
                                style: TextStyle(
                                  fontSize: screenWidth *
                                      0.035 *
                                      textScaleFactor,
                                  color: TColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Right: Status Icon and Message
                        Row(
                          children: [
                            Icon(
                              statusIcon,
                              color: statusColor,
                              size: screenWidth * 0.08,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              statusMessage,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: screenWidth * 0.04 * textScaleFactor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
