import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blade_app/features/states/screens/states_page.dart';
import '../bloc/announcement_bloc.dart';
import '../src/announcement_repository.dart';
import '../widgets/announcement_card_widget.dart';
import '../../../utils/constants/colors.dart'; // Import the colors file

class AnnouncementScreen extends StatefulWidget {
  final AnnouncementRepository repository;

  const AnnouncementScreen({required this.repository, Key? key})
      : super(key: key);

  @override
  State<AnnouncementScreen> createState() =>
      _AnnouncementAndStatesScreenState();
}

class _AnnouncementAndStatesScreenState
    extends State<AnnouncementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Two tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the system is in dark mode
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Announcements & Projects',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? TColors.textWhite : TColors.textPrimary,
              ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Announcements'),
            Tab(text: 'Project Status'),
          ],
          indicatorColor: isDarkMode ? TColors.textWhite : TColors.textPrimary,
        ),
      ),
      
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnnouncementTab(), // Announcement tab content
          const StatesPage(), // StatesPage as the second tab
        ],
      ),
    );
  }

  Widget _buildAnnouncementTab() {
    return BlocProvider(
      create: (context) => AnnouncementBloc(repository: widget.repository)
        ..add(FetchAnnouncements()),
      child: BlocBuilder<AnnouncementBloc, AnnouncementState>(
        builder: (context, state) {
          if (state is AnnouncementLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnnouncementLoaded) {
            if (state.ideas.isEmpty) {
              return const Center(
                child: Text(
                  'No announcements available.',
                  style: TextStyle(color: TColors.textSecondary),
                ),
              );
            }

            return ListView.builder(
              itemCount: state.ideas.length,
              itemBuilder: (context, index) {
                final idea = state.ideas[index];
                return AnnouncementCardWidget(
                  idea: idea,
                  repository: widget.repository,
                );
              },
            );
          } else if (state is AnnouncementError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}


