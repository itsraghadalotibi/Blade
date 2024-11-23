import 'package:blade_app/features/notification/bloc/NotificationBloc.dart';
import 'package:blade_app/features/notification/bloc/notification_event.dart';
import 'package:blade_app/features/notification/bloc/notification_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class NotificationCenterScreen extends StatefulWidget {
  final String userId;

  const NotificationCenterScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  _NotificationCenterScreenState createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  bool onlyUnread = true;

  // Updated formatDate function to handle both cases
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      // Show time for notifications within the last 24 hours
      return DateFormat('h:mm a').format(date);
    } else if (difference.inDays == 1) {
      // Show "1 day ago" for notifications older than 1 day
      return '1 day ago';
    } else {
      // Show "X days ago" for notifications older than 1 day
      return '${difference.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Center"),
      ),
      body: BlocProvider(
        create: (context) =>
            NotificationBloc(firestore: FirebaseFirestore.instance)
              ..add(LoadNotifications(widget.userId, onlyUnread: onlyUnread)),
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return const Center(child: Text('No Notifications Found.'));
              }
              return ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 6.0),
                    child: Card(
                      elevation: 3,
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          notification.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          notification.message,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        trailing: Text(
                          formatDate(notification.timestamp),
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (state is NotificationError) {
              return Center(child: Text('Error: ${state.error}'));
            } else {
              return const Center(child: Text('No Notifications Found.'));
            }
          },
        ),
      ),
    );
  }
}
