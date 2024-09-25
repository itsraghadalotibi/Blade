import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/announcement_bloc.dart'; // Ensure correct path to your bloc
import '../src/announcement_repository.dart'; // Ensure correct path to your repository
import '../widgets/announcement_card_widget.dart';
import '../../../utils/constants/colors.dart';

class AnnouncementScreen extends StatelessWidget {
  final AnnouncementRepository repository;

  // Constructor requiring repository
  const AnnouncementScreen({required this.repository, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnnouncementBloc(repository: repository)
        ..add(FetchAnnouncements()), // Trigger fetching announcements
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Announcements'),
          centerTitle: true, // Center the title
          automaticallyImplyLeading: false, // Remove the back button
          backgroundColor:
              Colors.transparent, // Make AppBar background transparent
          elevation: 0, // Remove shadow under AppBar
          titleTextStyle: const TextStyle(
            fontSize: 20, // Adjust the font size if needed
            color: TColors.textPrimary, // Light mode text color
          ),
        ),
        backgroundColor: TColors
            .primaryBackground, // Set background to light mode primary background
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
                    repository: repository, // Pass the repository to the widget
                  );
                },
              );
            } else if (state is AnnouncementError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: TColors.error), // Error color
                ),
              );
            }
            return const Center(
              child: Text(
                'No announcements available.',
                style: TextStyle(
                    color: TColors.textSecondary), // Secondary text color
              ),
            );
          },
        ),
      ),
    );
  }
}
