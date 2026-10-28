// import 'dart:convert';

// import 'package:blade_app/features/notification/src/NotificationModel.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/auth_io.dart' as auth;

// class PushNotificationService {
  
//   static Future<String> getAccessToken() async {
//     // Service account credentials were removed from source control.
//     // Load them server-side (e.g. Cloud Functions), never inside the app.
//     final serviceAcountJson = <String, dynamic>{};
//     List<String> scopes = [
//       "https://www.googleapis.com/auth/userinfo.email",
//       "https://www.googleapis.com/auth/firebase.database",
//       "https://www.googleapis.com/auth/firebase.messaging"
//     ];
//     http.Client client = await auth.clientViaServiceAccount(
//         auth.ServiceAccountCredentials.fromJson(serviceAcountJson), scopes);
//     // get the access  token
//     auth.AccessCredentials credentials =
//         await auth.obtainAccessCredentialsViaServiceAccount(
//       auth.ServiceAccountCredentials.fromJson(serviceAcountJson),
//       scopes,
//       client,
//     );
//     client.close();
//     return credentials.accessToken.data;
//   }

//   static sendNotification({
//     required String userId,
//     required String deviceToken,
//     required String title,
//     required String messageBody,
//   }) async {
//     FirebaseFirestore firestore = FirebaseFirestore.instance;
//     final String serverAccessTokenKey = await getAccessToken();
//     String endPointFirebaseCloudMessaging =
//         'https://fcm.googleapis.com/v1/projects/blade-87cf7/messages:send';

//     final Map<String, dynamic> message = {
//       'message': {
//         'token': deviceToken,
//         'notification': {'title': title, 'body': messageBody},
//       }
//     };

//     final http.Response response =
//         await http.post(Uri.parse(endPointFirebaseCloudMessaging),
//             headers: <String, String>{
//               'Content-Type': 'application/json',
//               'Authorization': 'Bearer $serverAccessTokenKey'
//             },
//             body: jsonEncode(message));

//       final notification = NotificationModel(id: "",userId: userId,  title: title, message: messageBody, timestamp: DateTime.now());
//       await firestore.collection('notifications').add(notification.toMap());
//     if (response.statusCode == 200) {
//       print('Notification send successfully');
//     } else {
//       print('Send notification faild: ${response.statusCode}');
//     }
//   }
// }