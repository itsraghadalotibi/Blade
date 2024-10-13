import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/expandable_text.dart';
import '../../announcement/src/announcement_model.dart';
import '../../announcement/src/announcement_repository.dart';
import '../../announcement/widgets/skill_tag_widget.dart';
import '../bloc/project_bloc.dart';
import '../bloc/project_event.dart';
import '../bloc/project_state.dart';
import 'edit_project_screen.dart';
import 'posts_tab.dart'; // Import your PostsTab widget
import 'members_tab.dart'; // We'll adjust this widget accordingly

class ProjectScreen extends StatefulWidget {
  final Idea idea;
  final AnnouncementRepository repository;

  const ProjectScreen({
    Key? key,
    required this.idea,
    required this.repository,
  }) : super(key: key);

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _checkGithubAuthorization() async {
    if (githubAccessToken == null) {
      final result = await Navigator.push<UserCredential?>(
        context,
        MaterialPageRoute(
          builder: (context) => const GithubAuthentication(),
        ),
      );

      if (result != null && result.credential != null && result.credential?.accessToken != null) {
        setState(() {
          githubAccessToken = result.credential!.accessToken!;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('GitHub authorization is required to continue.')),
        );
        return;
      }
    }

    _updateProjectStatus('ongoing');
  }

  Future<void> _updateProjectStatus(String newStatus) async {
    try {
      await widget.repository.updateIdeaStatus(idea.id!, newStatus);
      setState(() {
        idea.status = newStatus;
      });

      await _inviteMembersToGithubRepo();
    } catch (e) {
      print('Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update status')),
      );
    }
  }

  Future<void> _inviteMembersToGithubRepo() async {
    try {
      final members = idea.members;
      final collaboratorsSnapshot = await FirebaseFirestore.instance
          .collection('collaborators')
          .where('uid', whereIn: members)
          .get();

      for (var doc in collaboratorsSnapshot.docs) {
        final email = doc['email'] as String;
        await _sendGithubInvitation(email);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitations sent successfully!')),
      );
    } catch (e) {
      print('Error sending invitations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send invitations')),
      );
    }
  }

  Future<void> _sendGithubInvitation(String email) async {
    final url = Uri.parse('https://api.github.com/repos/${idea.title}/collaborators/$email');
    
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $githubAccessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'permission': 'push',
      }),
    );

    if (response.statusCode == 201) {
      print('Invitation sent to $email');
    } else {
      print('Failed to send invitation to $email: ${response.body}');
    }
  }

  void _joinProject() async {
    try {
      await widget.repository.addMemberToIdea(idea.id!, currentUserId);
      setState(() {
        isMember = true;
        idea.members.add(currentUserId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have joined the project!')),
      );
    } catch (e) {
      print('Error joining project: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join project')),
      );
    }
  }

  void _leaveProject() async {
    try {
      await widget.repository.removeMemberFromIdea(idea.id!, currentUserId);
      setState(() {
        isMember = false;
        idea.members.remove(currentUserId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have left the project!')),
      );
    } catch (e) {
      print('Error leaving project: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to leave project')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              appBar: AppBar(
                title: const Text('Loading...'),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is ProjectError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Error'),
              ),
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
            final bool isMember = state.isMember;
            final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Project details'),
                centerTitle: true,
                actions: [
                  if (isOwner && idea.status == 'open')
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Navigate to the EditProjectScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProjectScreen(
                              idea: idea,
                              repository: widget.repository,
                            ),
                          ),
                        ).then((_) {
                          // Refresh project details after returning from edit screen
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
                          // Left Side: Project Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Project Title
                                Text(
                                  idea.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Project Description
                                ExpandableTextWidget(
                                  text: idea.description,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode ? Colors.white70 : Colors.grey[800],
                                  ),
                                  maxLines: 4,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                          // Project Status Button with Padding Adjustments
                          GestureDetector(
                            onTap: isOwner && idea.status != 'completed'
                                ? () => _showStatusOptions(context, idea)
                                : null,
                            child: Container(
                              margin: const EdgeInsets.only(left: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(idea.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isOwner && idea.status != 'completed')
                                    const Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                  if (isOwner && idea.status != 'completed')
                                    const SizedBox(width: 4),
                                  Text(
                                    idea.status[0].toUpperCase() + idea.status.substring(1),
                                    style: TextStyle(color: _getStatusTextColor(idea.status)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SkillTagWidget(
                            skills: idea.skills,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Join/Leave Button
                    if (!isOwner && idea.status=='open') ...[
                      Center(
                        child: ElevatedButton(
                          onPressed: isMember
                              ? () => context.read<ProjectBloc>().add(LeaveProject(idea.id!))
                              : () => context.read<ProjectBloc>().add(JoinProject(idea.id!)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          ),
                          child: Text(isMember ? 'Leave Project' : 'Join Project'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 16),
                    // Tabs for Posts and Members
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            labelColor: isDarkMode ? Colors.white : Colors.black,
                            indicatorColor: isDarkMode ? Colors.white : Colors.black,
                            tabs: const [
                              Tab(text: 'Posts'),
                              Tab(text: 'Members'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // Posts Tab
                                PostsTab(ideaId: idea.id!, repository: widget.repository),
                                // Members Tab
                                MembersTab(idea: idea, repository: widget.repository),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(); // Fallback
        },
      ),
    );
  }

  // Method to show status options (unchanged from your original UI)
  void _showStatusOptions(BuildContext context, Idea idea) {
    List<String> availableStatusOptions = _getAvailableStatusOptions(idea.status);
    if (availableStatusOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The project status is already completed and cannot be changed.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newStatus = availableStatusOptions[0];

        // Determine the theme brightness
        Brightness brightness = Theme.of(context).brightness;

        // Set background colors based on theme
        Color backgroundColor;

        if (brightness == Brightness.dark) {
          backgroundColor = Colors.grey[850]!; // Dark grey for dark theme
        } else {
          backgroundColor = Colors.grey[200]!; // Light grey for light theme
        }


        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: backgroundColor,
              title: const Text('Change Project Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Current Status: ${idea.status[0].toUpperCase() + idea.status.substring(1)}'),
                  DropdownButton<String>(
                    value: newStatus,
                    dropdownColor: backgroundColor,
                    items: availableStatusOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value[0].toUpperCase() + value.substring(1)),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          newStatus = value;
                        });
                      }
                    },
                  ),
                  const Text('Note: You will not be able to change back to the previous status.'),
                ],
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<ProjectBloc>().add(UpdateProjectStatus(idea.id!, newStatus));
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    backgroundColor: Colors.green,
                    side: const BorderSide(color:  Colors.green),
                  ),
                  child: const Text('Save Status'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper methods (Unchanged)
  List<String> _getAvailableStatusOptions(String currentStatus) {
    switch (currentStatus) {
      case 'open':
        return ['ongoing', 'completed'];
      case 'ongoing':
        return ['completed'];
      default:
        return [];
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ongoing':
        return Colors.blue[100]!;
      case 'completed':
        return Colors.grey[300]!;
      default:
        return Colors.green[100]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'ongoing':
        return Colors.blue[900]!;
      case 'completed':
        return Colors.grey[800]!;
      default:
        return Colors.green[900]!;
    }
  }
}
