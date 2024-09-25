import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/announcement_bloc.dart'; // Ensure correct path to your bloc
import '../src/announcement_repository.dart'; // Ensure correct path to your repository
import '../widgets/announcement_card_widget.dart'; 

class AnnouncementScreen extends StatelessWidget {
  final AnnouncementRepository repository;

  // Constructor requiring repository
  const AnnouncementScreen({required this.repository, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnnouncementBloc(repository: repository)
        ..add(FetchAnnouncements()), // Trigger fetching announcements
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Announcements'),
          backgroundColor: Colors.transparent, // Make AppBar background transparent or default
          elevation: 0, // Remove shadow under AppBar
          iconTheme: const IconThemeData(
            color: Colors.white, // Set the back button color to #848484
          ),
          titleTextStyle: const TextStyle(
            fontSize: 20, // You can adjust the font size if needed
          ),
        ),
        backgroundColor: const Color(0xFF161616), // Set the background color to #161616
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
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('No announcements available.'));
          },
        ),
      ),
    );
  }
}
