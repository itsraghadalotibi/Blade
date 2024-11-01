import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Declare a StreamSubscription for the notification listener
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _notificationSubscription;

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
  Future<void> createFirebaseNotification(
      String userId, String status, String projectId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Skip the notification if the current user is the one performing the action
    if (currentUser != null && currentUser.uid == userId) {
      return; // Exit the function early to avoid creating notification for the project owner
    }

    final title =
        status == 'accepted' ? 'Request Accepted' : 'Request Rejected';
    final message = status == 'accepted'
        ? 'You have been accepted for the project with ID $projectId!'
        : 'Your join request for the project with ID $projectId has been rejected.';

    // Create notification in Firebase with project ID for the target user
    await _firestore.collection('notifications').add({
      'userId': userId,
      'status': status,
      'projectId': projectId, // Store the project ID
      'timestamp': FieldValue.serverTimestamp(),
      'title': title,
      'message': message,
      'read': false,
    });

    // Show local notification for the target user (only if they are different from the project owner)
    showLocalNotification(title, message);
  }

  // Listen to changes in the notifications collection in Firebase for real-time notifications
  void listenToFirebaseNotifications(String userId) {
    // Cancel any existing subscription to avoid multiple listeners
    _notificationSubscription?.cancel();

    // Set up a new subscription for real-time notifications
    _notificationSubscription = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false) // Only fetch unread notifications
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docChanges) {
        if (doc.type == DocumentChangeType.added) {
          final data = doc.doc.data();
          if (data != null) {
            // Show the local notification
            showLocalNotification(
              data['title'] ?? 'Notification',
              data['message'] ?? 'You have a new notification',
            );

            // Mark the notification as read
            doc.doc.reference.update({'read': true}).then((_) {
              print('Notification marked as read in Firebase: ${data['title']}');
            }).catchError((error) {
              print('Error marking notification as read: $error');
            });
          }
        }
      }
    });
  }
  void dispose() {
    _notificationSubscription?.cancel();
  }
}
