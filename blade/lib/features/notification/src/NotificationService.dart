import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Constructor to initialize settings
  NotificationService() {
    _initialize(); // Properly initialize on instance creation
  }

  // Initialize local notifications for iOS and macOS
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
        // Handle notification tap if necessary
      },
    );
  }

  // Request permissions for local notifications (useful for iOS)
  Future<void> requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Show a local notification on the device
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

  // Add a notification to Firebase for the target user
  Future<void> createFirebaseNotification(String userId, String status) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final title =
        status == 'accepted' ? 'Request Accepted' : 'Request Rejected';
    final message = status == 'accepted'
        ? 'You have been accepted for the project!'
        : 'Your join request has been rejected.';

    // Create notification in Firebase
    await _firestore.collection('notifications').add({
      'userId': userId,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
      'title': title,
      'message': message,
      'read': false,
    });

    if (currentUser != null && currentUser.uid == userId) {
    print('Showing local notification for title: $title');
    showLocalNotification(title, message);
  }
  }

  // Listen to changes in the notifications collection in Firebase for real-time notifications
  void listenToFirebaseNotifications(String userId) {
    _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docChanges) {
        if (doc.type == DocumentChangeType.added) {
          final data = doc.doc.data();
          if (data != null) {
            showLocalNotification(
              data['title'] ?? 'Notification',
              data['message'] ?? 'You have a new notification',
            );
          }
        }
      }
    });
  }
}
