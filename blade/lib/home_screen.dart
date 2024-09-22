import 'package:flutter/material.dart';
import 'package:blade_app/features/announcement/screens/announcement_screen.dart';
import 'package:blade_app/features/announcement/src/announcement_repository.dart'; // Import the repository
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create an instance of AnnouncementRepository
    final announcementRepository = AnnouncementRepository(
      firestore: FirebaseFirestore.instance,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnnouncementScreen(
                      repository: announcementRepository,
                    ),
                  ),
                );
              },
              child: const Text('Go to Announcements'),
            ),
            const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: () {
            //     // Navigate to the skill selection screen
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => ListSkillsScreen(),
            //       ),
            //     );
            //   },
            //   child: const Text('Select Specialization'),
            // ),
          ],
        ),
      ),
    );
  }
}




// import 'package:flutter/widgets.dart';

// class HomeScreen extends StatelessWidget{
//   const HomeScreen({super.key});
  
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     throw UnimplementedError();
//   }
  
// }

// // lib/home_screen.dart

// import 'package:blade_app/features/profile/bloc/bloc/profile_view_bloc.dart';
// import 'package:blade_app/features/profile/bloc/bloc/profile_view_event.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:provider/provider.dart';
// import 'features/authentication/bloc/authentication_bloc.dart';
// import 'features/authentication/bloc/authentication_event.dart';
// import 'features/authentication/bloc/authentication_state.dart';
// import 'features/authentication/src/collaborator_model.dart';
// import 'features/authentication/src/supporter_model.dart';
// import 'features/profile/bloc/screens/profile_screen.dart';
// import 'features/profile/bloc/repository/profile_repository.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   void _onLogoutButtonPressed(BuildContext context) {
//     context.read<AuthenticationBloc>().add(LoggedOut());
//   }

//   // Add the _onProfileButtonPressed function here
//   void _onProfileButtonPressed(BuildContext context, String userId) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MultiProvider(
//           providers: [
//             RepositoryProvider.value(
//               value:
//                   context.read<ProfileRepository>(), // Inject ProfileRepository
//             ),
//             BlocProvider(
//               create: (context) => ProfileViewBloc(
//                 profileRepository:
//                     context.read<ProfileRepository>(), // Create ProfileViewBloc
//               )..add(LoadProfile(
//                   userId)), // Trigger profile loading event with userId
//             ),
//           ],
//           child: ProfileScreen(userId: userId), // Pass userId to ProfileScreen
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthenticationBloc, AuthenticationState>(
//       listener: (context, state) {
//         if (state is AuthenticationUnauthenticated) {
//           // Navigate to WelcomeScreen when unauthenticated
//           Navigator.of(context).pushReplacementNamed('/');
//         }
//       },
//       child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
//         builder: (context, state) {
//           if (state is AuthenticationAuthenticated) {
//             final user = state.user;

//             if (user is CollaboratorModel) {
//               // Render the home screen for collaborators
//               return Scaffold(
//                 appBar: AppBar(
//                   title: const Text('Collaborator Home'),
//                   actions: [
//                     IconButton(
//                       icon: const Icon(Icons.logout),
//                       onPressed: () => _onLogoutButtonPressed(context),
//                     ),
//                   ],
//                 ),
//                 body: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Welcome Collaborator ${user.firstName} ${user.lastName}!',
//                         style: Theme.of(context).textTheme.headlineMedium,
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: () => _onProfileButtonPressed(context,
//                             user.uid), // Call the profile button handler
//                         child: const Text('Go to Profile'),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             } else if (user is SupporterModel) {
//               // Render the home screen for supporters
//               return Scaffold(
//                 appBar: AppBar(
//                   title: const Text('Supporter Home'),
//                   actions: [
//                     IconButton(
//                       icon: const Icon(Icons.logout),
//                       onPressed: () => _onLogoutButtonPressed(context),
//                     ),
//                   ],
//                 ),
//                 body: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Welcome Supporter ${user.firstName} ${user.lastName}!',
//                         style: Theme.of(context).textTheme.headlineMedium,
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: () => _onProfileButtonPressed(context,
//                             user.uid), // Call the profile button handler
//                         child: const Text('Go to Profile'),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             } else {
//               // Handle unexpected user type
//               return Scaffold(
//                 appBar: AppBar(
//                   title: const Text('Home'),
//                   actions: [
//                     IconButton(
//                       icon: const Icon(Icons.logout),
//                       onPressed: () => _onLogoutButtonPressed(context),
//                     ),
//                   ],
//                 ),
//                 body: const Center(
//                   child: Text('Unknown user type'),
//                 ),
//               );
//             }
//           } else {
//             // If not authenticated, show loading indicator
//             return const Scaffold(
//               body: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
