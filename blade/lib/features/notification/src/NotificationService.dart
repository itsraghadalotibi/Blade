import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//raghad
class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List to keep track of notified request IDs to prevent duplicate notifications
  static final List<String> notifiedRequestIds = [];

  // Initialize local notification settings for iOS
  static Future<void> initialize() async {
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
    await _firestore.collection('Notification').add({
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
  static Future<void> showLocalNotification(String title, String body) async {
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

  // Listen to Firestore collection for real-time updates
  static void listenToPendingRequests() {
    _firestore
        .collection('join_requests')
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        if (!notifiedRequestIds.contains(doc.id)) {
          notifiedRequestIds.add(doc.id); // Prevent duplicate notifications
          showLocalNotification(
            'New Join Request',
            'A new request is waiting for your approval',
          );
        }
      }
    });
  }
}
