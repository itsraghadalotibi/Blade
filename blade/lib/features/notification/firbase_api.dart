import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi{
  static final  instance = FirebaseMessaging.instance;
  static Future<String?> getFirebaseToken()async{
    await instance.requestPermission();
    return await instance.getToken();
  } 
}