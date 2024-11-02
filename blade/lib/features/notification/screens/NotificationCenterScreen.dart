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

  String formatDate(DateTime date) {
    return DateFormat('h:mm a').format(date);
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ToggleButtons(
                isSelected: [onlyUnread, !onlyUnread],
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Unread',
                      style: TextStyle(
                        color: onlyUnread
                            ? Colors.white
                            : const Color.fromARGB(255, 2, 147, 103),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'All',
                      style: TextStyle(
                        color: !onlyUnread
                            ? Colors.white
                            : const Color.fromARGB(255, 1, 208, 195),
                      ),
                    ),
                  ),
                ],
                onPressed: (index) {
                  setState(() {
                    onlyUnread = index == 0;
                  });
                  BlocProvider.of<NotificationBloc>(context).add(
                      LoadNotifications(widget.userId, onlyUnread: onlyUnread));
                },
                fillColor: const Color.fromARGB(255, 5, 165, 141),
                selectedColor: Colors.white,
                borderRadius: BorderRadius.circular(8),
                borderColor: const Color.fromARGB(255, 4, 167, 134),
              ),
            ),
            Expanded(
              child: BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is NotificationLoaded) {
                    if (state.notifications.isEmpty) {
                      return const Center(
                          child: Text('No Notifications Found.'));
                    }
                    return ListView.builder(
                      itemCount: state.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = state.notifications[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6.0),
                          child: Dismissible(
                            key: Key(notification.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              color: Colors.red,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              BlocProvider.of<NotificationBloc>(context)
                                  .add(DeleteNotification(notification.id));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Notification deleted")),
                              );
                            },
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
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 12),
                                ),
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
          ],
        ),
      ),
    );
  }
}
