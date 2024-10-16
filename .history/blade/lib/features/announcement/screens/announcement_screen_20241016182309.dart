import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blade_app/features/states/screens/states_page.dart';
import '../bloc/announcement_bloc.dart';
import '../src/announcement_repository.dart';
import '../widgets/announcement_card_widget.dart';
import '../../../utils/constants/colors.dart';

//yara
class AnnouncementScreen extends StatefulWidget {
  final AnnouncementRepository repository;
  final String currentUserId;

  const AnnouncementScreen({
    required this.repository,
    required this.currentUserId,
    Key? key,
  }) : super(key: key);

  @override
  State<AnnouncementScreen> createState() =>
      _AnnouncementAndStatesScreenState();
}

class _AnnouncementAndStatesScreenState extends State<AnnouncementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _focusNode = FocusNode();

    // Fetch announcements when the screen is focused
    // _focusNode.addListener(() {
    //   if (_focusNode.hasFocus) {
    //     BlocProvider.of<AnnouncementBloc>(context).add(
    //       FetchAnnouncements(currentUserId: widget.currentUserId),
    //     );
    //   }
    // });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => AnnouncementBloc(repository: widget.repository)
        ..add(FetchAnnouncements(currentUserId: widget.currentUserId)),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text('Announcements'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context)
                .primaryColor, // Matches the primary theme color
            labelColor:
                Theme.of(context).primaryColor, // Label color for selected tab
            unselectedLabelColor: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.color, // Color for unselected tabs
            tabs: const [
              Tab(text: 'Announcements'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: Focus(
          focusNode: _focusNode, // Wrap the TabBarView with a Focus widget
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAnnouncementTab(),
              const StatesPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementTab() {
    return BlocBuilder<AnnouncementBloc, AnnouncementState>(
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
              if (idea.isJoined!) return const SizedBox();
              return AnnouncementCardWidget(
                idea: idea,
                fetchAll: () {
                  context.read<AnnouncementBloc>().add(
                      FetchAnnouncements(currentUserId: widget.currentUserId));
                },
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
        return const SizedBox.shrink(); // Default case when no state matches
      },
    );
  }
}
