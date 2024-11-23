// import 'dart:convert';

// import 'package:blade_app/features/notification/src/NotificationModel.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/auth_io.dart' as auth;

// class PushNotificationService {
  
//   static Future<String> getAccessToken() async {
//     final serviceAcountJson = {  
//       "type": "service_account",
//       "project_id": "blade-87cf7",
//       "private_key_id": "cbdcb326c7c82a961a2025dccd0ca997f122606b",
//       "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDCDSzllTnrGiAH\nMIKZRfw/EecaMwZO50QRp7MgZ6u4Nio9jb5SMMCI0ggIxPLfBjSRaJp387LCmdpb\nJzrBsvq3BlSLmyaT7PpjMnZLqUc4VlT+bYDmcrjloLYce4w3x6BugxeSaK8NRfYg\nhrDO2g7KIPrBYjII7k2rw4cbhMUwRFcqT2U/eVuBFd4LIvSJwKS/HsqwJPovitog\nEy1mTUtZxBv0nDSRStQUKx8pgtaNFiHhNoUXjL4fJhWOVmZZiErD+UpBXA8TJUGB\nshug5YLnbo/uet1bfXDOS/nn02yHH4GINRA5eMNUPWhjS8y16N9/iEBfIw9H607D\nVkvEqJTvAgMBAAECggEAJqPs/sJaSCBppETanJ68/eoYtLTYWrneag2Us60xGnte\nqechsMgYbqY0B1sAabyYlyPXLm+OdwWf32rOXme/WNaf2zTH18jmiv4vZB2PGv7F\n6evwMPNDMiZwXPeVEj5kCd18wiCqSuBVhGCNsILnUwSCKiPdhr29JajHrIkhotx/\n/suXBVBMxIC+sjtsmBPjocmWpwpiLSG1MzBrU//qvWOUr6py03BwQNERXr1crxvx\nlUtDwnfeEG0Cmr7wfbS8aWUDaRz0T70fwa6krzB6HTORew2aOE2yZfS8cH+YukOB\nBo/KlrooSh0cjPNN7a7kScJIHiubfeUYF7ygoq/lwQKBgQDr3DdmXzUR0hxVyyX5\nUn6QhyJNFhsu0NnbnXces83nlR5UxXLrnL6l218CRzd21qyx0OxgjbThrszHO6Dy\ngrRQC97+EpLDsH0eNK9AXsdiPdchf79mqvuX1fzU3F6B0+i3iAujvUE+pU8zT4O8\n57e4kCFzxQP937GEqecI6HFz0QKBgQDSnwqAuM+a67fU2q80MWcfDbUntO6o+K+d\nT4jmtbrGalNEoRLfdT+kQGH7YdQxcl5II39cufN4n15270ysmQLIa0FRwGAew1b5\nJeMmAHT3KNUr/2est1XkWsN3BN1fRCOKDGL/DV3yiEwKlgBEM8qOdc4aoQgpgaM/\n+vmhlXdsvwKBgGgQvhDZKR03y3C/NX4QO++g8C1693tsgvM3Qvu08cCgNsXIaLA0\ndJnRdNYYfgxdI81BFUp0u75n1cqCML1PlidLVZRctYzKLipJrJmGOArMpkMNjnHK\nN0ADFo8EvF4kFaYEzL3uHv95CLzm9IVA5/ry/Q+Leftl23lhTaLMjGJBAoGAciMj\nsuvz/TU+EshLZ9JZ2rc384OWTdUufeZK/xN+WuXlp+xN6PCGA4GsV2kFb6JVu2wZ\nKevPKA/dRkCZ4XKt0mRlKmNA84rSCARjGwXmXMYw9z3aNfvIPQ5+nHHzcRvg0n+x\n6huZTMRVyOrOzCbw3tCyVzXq0WtiR1q/irQP2ssCgYBDmPLpjPgN7tFKVqdk8dWE\nnPpUwhir1c1UTGVqI4LeGMZ4C49XFPLh2pxHnIVrklI+D0jIaxwxlrYC45T4af5z\nmrM4iivzmzjj/XY89K9K4saOmVMYsQBYAmLnyZDbQhm4o3XeBd+OolvucEi9AvO4\nR1HAVC5FhmjFMU1N+GunfA==\n-----END PRIVATE KEY-----\n",
//       "client_email": "blade-87cf7@appspot.gserviceaccount.com",
//       "client_id": "105530128749228862505",
//       "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//       "token_uri": "https://oauth2.googleapis.com/token",
//       "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
//       "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/blade-87cf7%40appspot.gserviceaccount.com",
//       "universe_domain": "googleapis.com"
//     };
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