import 'package:blade_app/features/project_info/screens/offers_tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/expandable_text.dart';
import '../../announcement/src/announcement_model.dart';
import '../../announcement/src/announcement_repository.dart';
import '../../announcement/widgets/skill_tag_widget.dart';
import '../bloc/project_bloc.dart';
import '../bloc/project_event.dart';
import '../bloc/project_state.dart';
import 'posts_tab.dart';
import 'members_tab.dart';
import 'project_settings_screen.dart';
import '../../newPost/screens/github_oauth.dart';

class ProjectScreen extends StatefulWidget {
  final Idea idea;
  final AnnouncementRepository repository;
  final bool canJoin;
  final Function()? refershIdeasInProfile;
  

  const ProjectScreen({
    super.key,
    required this.idea,
    required this.repository,
    required this.canJoin, required onJoinRequestSent, this.refershIdeasInProfile,
  });

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  bool _isRequestPending = false;
  bool _isMember = false;
  String? _joinRequestId;
  String _buttonText = 'Join Project';

  @override
  void initState() {
    super.initState();
    _checkJoinRequestStatus();
  }

  Future<void> _checkJoinRequestStatus() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final String ideaId = widget.idea.id!;

    final snapshot = await FirebaseFirestore.instance
        .collection('join_requests')
        .where('ideaId', isEqualTo: ideaId)
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final status = snapshot.docs.first['status'];
      _joinRequestId = snapshot.docs.first.id;

      setState(() {
        if (status == 'pending') {
          _buttonText = 'Pending...';
          _isRequestPending = true;
        } else if (status == 'accepted') {
          _buttonText = 'Leave Project';
          _isMember = true;
        }
      });
    }
  }

  Future<void> _sendJoinRequest() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final String ideaId = widget.idea.id!;

    setState(() {
      _buttonText = 'Pending...';
      _isRequestPending = true;
    });

    try {
      final docRef = await FirebaseFirestore.instance.collection('join_requests').add({
        'ideaId': ideaId,
        'userId': userId,
        'status': 'pending',
        'timestamp': Timestamp.now(),
      });

      _joinRequestId = docRef.id;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() {
        _buttonText = 'Join Project';
        _isRequestPending = false;
      });
    }
  }

  Future<void> _leaveProject() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final String ideaId = widget.idea.id!;

    try {
      // Remove the user from the project.
      await widget.repository.removeMemberFromIdea(ideaId, userId);

      // Remove the join request if it exists.
      if (_joinRequestId != null) {
        await FirebaseFirestore.instance
            .collection('join_requests')
            .doc(_joinRequestId)
            .delete();
        _joinRequestId = null;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have left the project.')),
      );
    

      setState(() {
        _isMember = false;
        _buttonText = 'Join Project';
      });

      context.read<ProjectBloc>().add(LeaveProject(ideaId));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProjectBloc(widget.repository, FirebaseAuth.instance.currentUser?.uid ?? '')
        ..add(FetchProjectDetails(widget.idea.id!)),
      child: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, state) {
          if (state is ProjectLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Loading...')),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is ProjectError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Center(
                child: Text(
                  state.message,
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
            );
          } else if (state is ProjectLoaded) {
            final idea = state.idea;
            final bool isOwner = state.isOwner;
            final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Project details'),
                centerTitle: true,
                actions: [
                  if (isOwner && (idea.status == 'open' || idea.status == 'ongoing'))
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectSettingsScreen(
                              idea: idea,
                              repository: widget.repository,
                            ),
                          ),
                        ).then((_) {
                          context.read<ProjectBloc>().add(FetchProjectDetails(idea.id!));
                        });
                      },
                    ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  idea.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ExpandableTextWidget(
                                  text: idea.description,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode ? Colors.white70 : Colors.grey[800],
                                  ),
                                  maxLines: 4,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(idea.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              idea.status[0].toUpperCase() + idea.status.substring(1),
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SkillTagWidget(skills: idea.skills),
                      ),
                    ),
                    if (!isOwner && idea.status == 'open') ...[
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Red button background
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isRequestPending
                              ? null
                              : (_isMember ? _leaveProject : _sendJoinRequest),
                          child: Text(
                            _buttonText,
                            style: const TextStyle(
                              color: Colors.black, // Black text for contrast
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: DefaultTabController(
                        length: 2 + (isOwner && idea.status == "open" ? 1 : 0),
                        child: Column(
                          children: [
                            TabBar(
                              labelColor: isDarkMode ? Colors.white : Colors.black,
                              indicatorColor: isDarkMode ? Colors.white : Colors.black,
                              tabs: [
                                const Tab(text: 'Posts'),
                                const Tab(text: 'Members'),
                                if (isOwner && idea.status == "open") const Tab(text: 'Join Requests'),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  PostsTab(ideaId: idea.id!, repository: widget.repository),
                                  MembersTab(idea: idea, repository: widget.repository),
                                  if (isOwner && idea.status == "open")
                                    OffersTab(
                                      idea: idea,
                                      repository: widget.repository,
                                      addNewMember: (id) {
                                        idea.members.add(id);
                                        final bool isFull = (idea.members.length - 1) >= idea.maxMembers;
                                        if (isFull && widget.refershIdeasInProfile != null) {
                                          idea.status = "ongoing";
                                          widget.refershIdeasInProfile!();
                                        }
                                        setState(() {});
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

 

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.green;
      case 'ongoing':
        return Colors.blue;
      case 'completed':
        return Colors.grey[600]!;
      default:
        return Colors.black;
    }
  }

}
