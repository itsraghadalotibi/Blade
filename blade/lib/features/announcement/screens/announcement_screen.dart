//dynammic theming
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/announcement_bloc.dart';
import '../src/announcement_repository.dart';
import '../widgets/announcement_card_widget.dart';
import '../../../utils/constants/colors.dart';

class AnnouncementScreen extends StatelessWidget {
  final AnnouncementRepository repository;

  const AnnouncementScreen({required this.repository, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if the system is in dark mode
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => AnnouncementBloc(repository: repository)
        ..add(FetchAnnouncements()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Transparent AppBar
          elevation: 0, // No shadow under AppBar
          centerTitle: true, // Center the title
          title: Text(
            'Announcements',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? TColors.textWhite : TColors.textPrimary, // Adjust color based on theme
                ),
          ),
        ),
        backgroundColor: isDarkMode ? TColors.dark : TColors.primaryBackground, // Background color based on theme
        body: BlocBuilder<AnnouncementBloc, AnnouncementState>(
          builder: (context, state) {
            if (state is AnnouncementLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AnnouncementLoaded) {
              return ListView.builder(
                itemCount: state.ideas.length,
                itemBuilder: (context, index) {
                  final idea = state.ideas[index];
                  return AnnouncementCardWidget(
                    idea: idea,
                    repository: repository,
                  );
                },
              );
            } else if (state is AnnouncementError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }
            return const Center(
              child: Text(
                'No announcements available.',
                style: TextStyle(color: TColors.textSecondary),
              ),
            );
          },
        ),
      ),
    );
  }
}


// //the dark theme
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/announcement_bloc.dart'; 
// import '../src/announcement_repository.dart'; 
// import '../widgets/announcement_card_widget.dart'; 
// import '../../../utils/constants/colors.dart';

// class AnnouncementScreen extends StatelessWidget {
//   final AnnouncementRepository repository;

//   const AnnouncementScreen({required this.repository, Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => AnnouncementBloc(repository: repository)
//         ..add(FetchAnnouncements()),
//       child: Scaffold(
//         appBar:AppBar(
//           backgroundColor: Colors.transparent, // Make AppBar background transparent or default
//           elevation: 0, // Remove shadow under AppBar
//           centerTitle: true, // Center the title
//           title: Text(
//             'Announcements',
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: TColors.textWhite, // Light mode text color
//                 ),
//           ),
//         ),
//         backgroundColor: TColors.dark,
//         body: BlocBuilder<AnnouncementBloc, AnnouncementState>(
//           builder: (context, state) {
//             if (state is AnnouncementLoading) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (state is AnnouncementLoaded) {
//               return ListView.builder(
//                 itemCount: state.ideas.length,
//                 itemBuilder: (context, index) {
//                   final idea = state.ideas[index];
//                   return AnnouncementCardWidget(
//                     idea: idea,
//                     repository: repository,
//                   );
//                 },
//               );
//             } else if (state is AnnouncementError) {
//               return Center(
//                 child: Text(
//                   'Error: ${state.message}',
//                   style: TextStyle(color: Theme.of(context).colorScheme.error),
//                 ),
//               );
//             }
//             return const Center(
//               child: Text(
//                 'No announcements available.',
//                 style: TextStyle(color: TColors.textSecondary),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// light version
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/announcement_bloc.dart'; 
// import '../src/announcement_repository.dart'; 
// import '../widgets/announcement_card_widget.dart'; 
// import '../../../utils/constants/colors.dart';

// class AnnouncementScreen extends StatelessWidget {
//   final AnnouncementRepository repository;

//   const AnnouncementScreen({required this.repository, Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => AnnouncementBloc(repository: repository)
//         ..add(FetchAnnouncements()),
//       child: Scaffold(
//         appBar:AppBar(
//           backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // Same background color as the profile
//           elevation: 0, // Remove shadow under AppBar
//           centerTitle: true, // Center the title
//           title: Text(
//             'Announcements',
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: TColors.textPrimary, // Light mode text color
//                 ),
//           ),
//         ),
//         backgroundColor: TColors.primaryBackground,
//         body: BlocBuilder<AnnouncementBloc, AnnouncementState>(
//           builder: (context, state) {
//             if (state is AnnouncementLoading) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (state is AnnouncementLoaded) {
//               return ListView.builder(
//                 itemCount: state.ideas.length,
//                 itemBuilder: (context, index) {
//                   final idea = state.ideas[index];
//                   return AnnouncementCardWidget(
//                     idea: idea,
//                     repository: repository,
//                   );
//                 },
//               );
//             } else if (state is AnnouncementError) {
//               return Center(
//                 child: Text(
//                   'Error: ${state.message}',
//                   style: TextStyle(color: Theme.of(context).colorScheme.error),
//                 ),
//               );
//             }
//             return const Center(
//               child: Text(
//                 'No announcements available.',
//                 style: TextStyle(color: TColors.textSecondary),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
