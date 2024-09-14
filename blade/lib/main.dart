import 'package:blade_app/app.dart';
import 'package:blade_app/simple_bloc_observe.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

// where the app runs itself
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //to make sure that everything initilized right
  await Firebase.initializeApp(options: FirebaseOptions(
    apiKey: "AIzaSyCyJjv7oScBSeafBZGk6mSVv3U6sPYYmnU", 
    appId: "1:284932571171:android:0597dda5ad92a34e883196", 
    messagingSenderId: "284932571171", 
    projectId: "blade-87cf7",
    )
    
  );
  Bloc.observer = SimpleBlocObserver();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp(FirebaseUserRepo())); //it is implement the abstract class
}




