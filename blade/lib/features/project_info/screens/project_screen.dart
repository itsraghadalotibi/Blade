import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../announcement/src/announcement_model.dart';
import '../../announcement/src/announcement_repository.dart';
import '../../announcement/widgets/skill_tag_widget.dart';
import 'posts_tab.dart';
import 'members_tab.dart';
import '../../newPost/screens/github_oauth.dart'; // Import the GitHub OAuth screen

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
  late bool isMember;
  late bool isOwner;
  late String currentUserId;
  late Idea idea;
  bool isLoading = true;
  String? errorMessage;
  String? githubAccessToken;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    fetchIdeaDetails();
  }

  Future<void> fetchIdeaDetails() async {
    try {
      final updatedIdea = await widget.repository.getIdeaById(widget.idea.id!);
      if (updatedIdea != null) {
        setState(() {
          idea = updatedIdea;
          isMember = idea.members.contains(currentUserId);
          isOwner = currentUserId == idea.members[0];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Project not found.';
        });
      }
    } catch (e) {
      print('Error fetching idea details: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred while loading the project.';
      });
    }
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

  void _showStatusOptions() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        String newStatus = idea.status;
        Brightness brightness = Theme.of(context).brightness;
        Color backgroundColor = brightness == Brightness.dark ? Colors.grey[850]! : Colors.grey[200]!;
        Color textColor = brightness == Brightness.dark ? Colors.white : Colors.black;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: backgroundColor,
              title: Text('Change Project Status', style: TextStyle(color: textColor)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Current Status: ${idea.status[0].toUpperCase() + idea.status.substring(1)}',
                      style: TextStyle(color: textColor)),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: newStatus,
                    dropdownColor: backgroundColor,
                    style: TextStyle(color: textColor),
                    iconEnabledColor: textColor,
                    items: <String>['open', 'ongoing', 'completed'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value[0].toUpperCase() + value.substring(1), style: TextStyle(color: textColor)),
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
                ],
              ),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (newStatus == 'ongoing') {
                      _checkGithubAuthorization();
                    } else {
                      _updateProjectStatus(newStatus);
                    }
                  },
                  child: const Text('Save Status'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color statusColor;
    Color statusTextColor;

    switch (idea.status) {
      case 'ongoing':
        statusColor = Colors.blue[100]!;
        statusTextColor = Colors.blue[900]!;
        break;
      case 'completed':
        statusColor = const Color.fromARGB(255, 224, 224, 224)!;
        statusTextColor = Colors.grey[800]!;
        break;
      default:
        statusColor = Colors.green[100]!;
        statusTextColor = Colors.lightGreen[900]!;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project details'),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
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
                        Text(
                          idea.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: isOwner ? _showStatusOptions : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            idea.status[0].toUpperCase() + idea.status.substring(1),
                            style: TextStyle(
                              color: statusTextColor,
                            ),
                          ),
                          if (isOwner)
                            const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.grey,
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
            Center(
              child: ElevatedButton(
                onPressed: isMember ? _leaveProject : _joinProject,
                child: Text(isMember ? 'Leave Project' : 'Join Project'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                        PostsTab(ideaId: idea.id!, repository: widget.repository),
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
}
