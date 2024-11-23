import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  static final instance = FirebaseMessaging.instance;

  static Future<String?> getFirebaseToken() async {
    try {
      // Request user permission for notifications
      NotificationSettings settings = await instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Check the user’s permission status
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Fetch and return the Firebase token
        String? token = await instance.getToken();
        print('Firebase Token: $token');
        return token;
      } else {
        print('User denied notification permissions.');
        return null; // Return null if permissions are denied
      }
    } catch (e) {
      print('Error fetching Firebase token: $e');
      return null; // Gracefully handle any errors
    }
  }
}
