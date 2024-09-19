import 'package:blade_app/app.dart';
import 'package:blade_app/simple_bloc_observe.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_repository/user_repository.dart';

// where the app runs itself
void main() async {
<<<<<<< Updated upstream
  WidgetsFlutterBinding
      .ensureInitialized(); //to make sure that everything initilized right
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: "AIzaSyCyJjv7oScBSeafBZGk6mSVv3U6sPYYmnU",
    appId: "1:284932571171:android:0597dda5ad92a34e883196",
    messagingSenderId: "284932571171",
    projectId: "blade-87cf7",
  ));
  Bloc.observer = SimpleBlocObserver();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp(FirebaseUserRepo())); //it is implement the abstract class
}
=======
  WidgetsFlutterBinding.ensureInitialized(); // Ensure everything is initialized properly
  await Firebase.initializeApp(); // Initialize Firebase
  Bloc.observer = SimpleBlocObserver(); // Set up Bloc observer for state management
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // Lock orientation to portrait mode
  
  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 690), // Set the base design size of your app
      minTextAdapt: true, // Optionally adapt text size
      splitScreenMode: true, // Support split screen mode
      builder: (context, child) {
        return MyApp(FirebaseUserRepo()); // Pass FirebaseUserRepo to your app
      },
    ),
  );
}



>>>>>>> Stashed changes
