import 'package:blade_app/features/notification/bloc/NotificationBloc.dart';
import 'package:blade_app/features/notification/bloc/notification_event.dart';
import 'package:blade_app/features/notification/bloc/notification_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../src/NotificationModel.dart';

class NotificationsScreen extends StatelessWidget {
  final String userId;

  const NotificationsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          NotificationBloc(firestore: FirebaseFirestore.instance)
            ..add(LoadNotifications(userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
        ),
        body: BlocConsumer<NotificationBloc, NotificationState>(
          listener: (context, state) {
            if (state is NotificationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            } else if (state is NotificationUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Notification marked as read")),
              );
            } else if (state is NotificationDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Notification deleted")),
              );
            }
          },
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return const Center(child: Text("No notifications found."));
              }
              return ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return Dismissible(
                    key: Key(notification.id),
                    background: Container(
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white)),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      context
                          .read<NotificationBloc>()
                          .add(DeleteNotification(notification.id));
                    },
                    child: ListTile(
                      title: Text(notification.title,
                          style: TextStyle(
                              fontWeight: notification.read
                                  ? FontWeight.normal
                                  : FontWeight.bold)),
                      subtitle: Text(notification.message),
                      trailing: Icon(
                          notification.read ? Icons.check_circle : Icons.circle,
                          color:
                              notification.read ? Colors.green : Colors.grey),
                      onTap: () {
                        if (!notification.read) {
                          context
                              .read<NotificationBloc>()
                              .add(MarkNotificationAsRead(notification.id));
                        }
                      },
                    ),
                  );
                },
              );
            } else if (state is NotificationError) {
              return Center(child: Text(state.error));
            } else {
              return const Center(child: Text("Unknown error occurred."));
            }
          },
        ),
      ),
    );
  }
}
