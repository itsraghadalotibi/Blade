import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blade_app/features/notification/bloc/NotificationBloc.dart';
import 'package:blade_app/features/notification/bloc/notification_event.dart';
import 'package:blade_app/features/notification/bloc/notification_state.dart';
import 'package:blade_app/features/notification/src/NotificationModel.dart';

class NotificationScreen extends StatelessWidget {
  final String userId;

  const NotificationScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          NotificationBloc(firestore: FirebaseFirestore.instance)
            ..add(LoadNotifications(userId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Notification Center"),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                // Open notification settings
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return Center(child: Text("No notifications available."));
              }

              return ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final NotificationModel notification =
                      state.notifications[index];
                  final isUnread = !notification.read;
                  final timestamp = notification.timestamp;

                  return Dismissible(
                    key: Key(notification.id),
                    onDismissed: (direction) {
                      BlocProvider.of<NotificationBloc>(context)
                          .add(DeleteNotification(notification.id));
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTile(
                      title: Text(notification.title),
                      subtitle: Text(notification.message),
                      trailing: Text(
                        _formatTime(timestamp),
                        style: TextStyle(color: Colors.grey),
                      ),
                      tileColor: isUnread ? Colors.grey[200] : null,
                      onTap: () {
                        if (isUnread) {
                          BlocProvider.of<NotificationBloc>(context)
                              .add(MarkNotificationAsRead(notification.id));
                        }
                      },
                    ),
                  );
                },
              );
            } else if (state is NotificationError) {
              return Center(child: Text('Error: ${state.error}'));
            }
            return Center(child: Text("No notifications found."));
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }
}
