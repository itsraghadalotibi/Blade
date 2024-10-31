import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotificationService() {
    _initialize();
  }

  // Initialize local notification settings for iOS
  Future<void> _initialize() async {
    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap, if necessary
      },
    );
  }

  // Create a notification in Firebase for the targeted user
  Future<void> createFirebaseNotification(String userId, String status) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
      'title': status == 'accepted' ? 'Request Accepted' : 'Request Rejected',
      'message': status == 'accepted'
          ? 'You have been accepted for the project!'
          : 'Your join request has been rejected.',
      'read': false,
    });
  }

  // Show a local notification on iOS
  Future<void> showLocalNotification(String title, String body) async {
    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
    );
  }
}
