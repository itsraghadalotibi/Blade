import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../announcement/src/announcement_model.dart';
import '../../announcement/src/announcement_repository.dart';
import '../../announcement/widgets/skill_tag_widget.dart';
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
  late bool isMember;
  late bool isOwner; // Determine ownership based on idea.members[0]
  late String currentUserId;
  late Idea idea;
  bool isLoading = true;
  String? errorMessage; // For handling errors

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
          isOwner = currentUserId == idea.members[0]; // Determine if current user is the owner
          isLoading = false;
        });
      } else {
        // Handle case where idea is not found
        setState(() {
          isLoading = false;
          errorMessage = 'Project not found.';
        });
      }
    } catch (e) {
      // Handle errors
      print('Error fetching idea details: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred while loading the project.';
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _joinProject() async {
    await widget.repository.addMemberToIdea(idea.id!, currentUserId);
    setState(() {
      isMember = true;
      idea.members.add(currentUserId);
    });
  }

  void _leaveProject() async {
    await widget.repository.removeMemberFromIdea(idea.id!, currentUserId);
    setState(() {
      isMember = false;
      idea.members.remove(currentUserId);
    });
  }

  void _showStatusOptions() async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      String newStatus = idea.status;

      // Determine the theme brightness
      Brightness brightness = Theme.of(context).brightness;

      // Set background colors based on theme
      Color backgroundColor;
      Color textColor;

      if (brightness == Brightness.dark) {
        backgroundColor = Colors.grey[850]!; // Dark grey for dark theme
        textColor = Colors.white; // Light text for contrast
      } else {
        backgroundColor = Colors.grey[200]!; // Light grey for light theme
        textColor = Colors.black; // Dark text for contrast
      }

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: backgroundColor,
            title: Text(
              'Change Project Status',
              style: TextStyle(color: textColor),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current Status: ${idea.status[0].toUpperCase() + idea.status.substring(1)}',
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: newStatus,
                  dropdownColor: backgroundColor, // Match dialog background
                  style: TextStyle(color: textColor), // Text color for selected item
                  iconEnabledColor: textColor, // Icon color
                  items: <String>['open', 'ongoing', 'completed'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value[0].toUpperCase() + value.substring(1),
                        style: TextStyle(color: textColor), // Text color for items
                      ),
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
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _updateProjectStatus(newStatus);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
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

  void _updateProjectStatus(String newStatus) async {
    try {
      await widget.repository.updateIdeaStatus(idea.id!, newStatus);
      setState(() {
        idea.status = newStatus;
      });
    } catch (e) {
      print('Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Show a loading indicator while data is being fetched
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      // Display the error message
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

    // Determine status colors based on idea.status
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
            // Project Details
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
                  // Right Side: Project Status
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
            // Skills Tags
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
            // Tabs for Posts and Members
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6, // Adjust as needed
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
}