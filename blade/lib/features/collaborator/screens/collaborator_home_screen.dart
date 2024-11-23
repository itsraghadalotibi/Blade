// lib/features/collaborator/presentation/screens/collaborator_home_screen.dart
import 'package:blade_app/features/project_info/screens/post_bookmarks.dart';
import 'package:blade_app/features/project_info/screens/posts_tab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../authentication/bloc/authentication_bloc.dart';
import '../../authentication/bloc/authentication_event.dart';
import '../../authentication/bloc/authentication_state.dart';
import '../../authentication/src/collaborator_model.dart';
import '../../chat/screens/chat_list_screen.dart';
import 'screens/HowToEarnPage.dart';

class CollaboratorHomeScreen extends StatelessWidget {
  const CollaboratorHomeScreen({super.key});

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            "Logout Confirmation",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Are you sure you want to log out from Blade?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              child: const Text("Cancel"),
            ),
            const SizedBox(width: 2),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _onLogoutButtonPressed(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(
                "Logout",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onLogoutButtonPressed(BuildContext context) {
    context.read<AuthenticationBloc>().add(LoggedOut());
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationUnauthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Logged out successfully!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(top: 10, left: 10, right: 10),
              showCloseIcon: true,
            ),
          );

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/welcome',
            (Route<dynamic> route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Collaborator Home'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          // leading: IconButton(
          //   icon: const Icon(Icons.bookmarks),
          //   onPressed: () => Navigator.of(context)
          //       .push(MaterialPageRoute(builder: (context) => const PostBookmarks())),
          // ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutConfirmation(context),
            ),
            BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {
                if (state is AuthenticationAuthenticated) {
                  return StreamBuilder<int>(
                    stream: _getUnreadMessagesCount(state.user.uid),
                    builder: (context, snapshot) {
                      int unreadCount = snapshot.data ?? 0;

                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chat_bubble),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatListScreen(userId: state.user.uid),
                                ),
                              );
                            },
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 11,
                              top: 11,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 14,
                                  minHeight: 14,
                                ),
                                child: Text(
                                  '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                } else {
                  return IconButton(
                    icon: const Icon(Icons.chat_bubble),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("User not authenticated"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Monthly Challenge Container with Dark and Light mode support
            Container(
              padding: const EdgeInsets.all(20.0),
              margin: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 30),
                      const SizedBox(width: 10),
                      Text(
                        "Monthly Challenge",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "500 Points", // Example points; replace with dynamic data if needed
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  // const SizedBox(height: 10),
                  // TextButton(
                  //   onPressed: () {  },
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Icon(Icons.local_fire_department, color: Colors.purple),
                  //       Text(
                  //       "How to Earn", // Example points; replace with dynamic data if needed
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.bold,
                  //         color: textColor,
                  //       ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Leaderboard Container
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Add navigation or functionality here
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        margin: const EdgeInsets.only(right: 10.0),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.leaderboard_rounded,
                                color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              "Leaderboard",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // How to Earn Points Container
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HowToEarnPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        margin: const EdgeInsets.only(left: 10.0),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assistant, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              "Blueprint AI",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Posts",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmarks),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const PostBookmarks())),
                  ),
                ],
              ),
            ),
            // Center Content for Posts
            Expanded(
              child: Center(
                child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
                  builder: (context, state) {
                    if (state is AuthenticationAuthenticated &&
                        state.user is CollaboratorModel) {
                      return const PostsTab(fromHome: true);
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Stream<int> _getUnreadMessagesCount(String userId) {
  final chatRoomsCollection = FirebaseFirestore.instance.collection('chatRooms');

  // Get chat rooms where the user is a participant
  final userChatRoomsQuery = chatRoomsCollection.where('members', arrayContains: userId);

  return userChatRoomsQuery.snapshots().map((chatRoomsSnapshot) {
    int totalUnreadMessages = 0;

    print('Chat rooms snapshot received with ${chatRoomsSnapshot.docs.length} rooms.');

    for (var chatRoomDoc in chatRoomsSnapshot.docs) {
      final unreadCounts = chatRoomDoc['unreadCounts'] as Map<String, dynamic>? ?? {};
      final userUnreadCount = unreadCounts[userId] as int? ?? 0;

      print('Chat room ${chatRoomDoc.id} has unread count $userUnreadCount for user $userId');

      totalUnreadMessages += userUnreadCount;
    }

    print('Total unread messages: $totalUnreadMessages');

    return totalUnreadMessages;
  });
}
}
