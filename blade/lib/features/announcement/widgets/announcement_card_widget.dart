import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../src/announcement_model.dart';
import '../src/announcement_repository.dart';
import 'avatar_stack_widget.dart';
import 'skill_tag_widget.dart';
import '../screens/members_screen.dart';
import '../../../utils/constants/colors.dart';

class AnnouncementCardWidget extends StatefulWidget {
  final AnnouncementRepository repository;

  const AnnouncementCardWidget({super.key, required this.repository});

  @override
  _AnnouncementCardWidgetState createState() => _AnnouncementCardWidgetState();
}

class _AnnouncementCardWidgetState extends State<AnnouncementCardWidget> {
  final ScrollController _scrollController = ScrollController();
  List<Idea> _ideas = [];
  bool _isLoading = false;
  DocumentSnapshot? _lastDoc; // Store the last document for pagination
  bool _hasMoreData = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadMoreData(); // Initial data load
    _scrollController.addListener(_onScroll); // Add scroll listener
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the scroll controller
    super.dispose();
  }

  // Load more data with Firestore pagination
  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      const int limit = 10; // Number of ideas to load per request

      QuerySnapshot snapshot = (await widget.repository.fetchIdeasWithPagination(
        limit: limit,
        lastDoc: _lastDoc, // Use the last document for pagination
      )) as QuerySnapshot<Object?>;

      List<Idea> newIdeas = snapshot.docs
          .map((doc) => Idea.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Check if we've reached the end of the data
      if (newIdeas.length < limit) {
        _hasMoreData = false; // No more data to load
      }

      setState(() {
        _ideas.addAll(newIdeas);
        if (snapshot.docs.isNotEmpty) {
          _lastDoc = snapshot.docs.last; // Save the last document for pagination
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load ideas: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Detect when the user is near the bottom of the list to load more data
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more data when the user is near the bottom of the scroll
      _loadMoreData();
    }
  }

  Future<void> _handleJoinRequest(Idea idea) async {
    setState(() {
      idea.isJoined = true;
    });

    await widget.repository.sendJoinRequest(idea, currentUserId!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Join request sent. Awaiting approval.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ideas'),
      ),
      body: _ideas.isEmpty && !_isLoading
          ? const Center(child: Text('No ideas available'))
          : ListView.builder(
              controller: _scrollController,
              itemCount: _ideas.length + (_hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _ideas.length) {
                  // Display a loading indicator at the bottom if more data is being loaded
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final idea = _ideas[index];
                return IdeaCard(
                  idea: idea,
                  repository: widget.repository,
                  onJoinRequest: () => _handleJoinRequest(idea),
                );
              },
            ),
    );
  }
}

class IdeaCard extends StatelessWidget {
  final Idea idea;
  final AnnouncementRepository repository;
  final VoidCallback onJoinRequest;

  const IdeaCard({
    super.key,
    required this.idea,
    required this.repository,
    required this.onJoinRequest,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final int maxMembers = idea.maxMembers;
    final int currentMembers = idea.members.length;
    final int membersNeeded =
        maxMembers > currentMembers ? maxMembers - currentMembers : 0;

    bool canJoin = FirebaseAuth.instance.currentUser?.uid != null &&
        !idea.isJoined! &&
        !idea.members.contains(FirebaseAuth.instance.currentUser!.uid) &&
        currentMembers < maxMembers;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.02,
        horizontal: screenWidth * 0.05,
      ),
      child: Container(
        width: screenWidth * 0.9,
        decoration: BoxDecoration(
          color: isDarkMode ? TColors.container : TColors.white,
          borderRadius: BorderRadius.circular(23),
          border: isDarkMode
              ? null // No border in dark mode
              : Border.all(color: TColors.borderPrimary), // Light mode border
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      idea.title,
                      style: TextStyle(
                        color: isDarkMode ? TColors.textWhite : TColors.black,
                        fontSize: screenWidth * 0.055 * textScaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  GestureDetector(
                    onTap: () {
                      // Navigate to MembersScreen on tap
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MembersScreen(
                            memberIds: idea.members,
                            ideaSkills: idea.skills,
                            repository: repository,
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: screenWidth * 0.2,
                      height: screenWidth * 0.1,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: AvatarStackWidget(
                          userIds: idea.members,
                          screenWidth: screenWidth,
                          repository: repository,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),

              // Description and "Show more" logic
              Text(
                idea.description,
                style: TextStyle(
                  color: isDarkMode ? TColors.textWhite : TColors.black,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: screenHeight * 0.02),

              // Dynamically display the number of members needed
              if (membersNeeded > 0)
                Text(
                  '$membersNeeded members needed',
                  style: TextStyle(
                    color: isDarkMode ? TColors.grey : TColors.darkerGrey,
                    fontSize: screenWidth * 0.035 * textScaleFactor, // Small font size
                    fontStyle: FontStyle.italic, // Italic for subtle emphasis
                    fontWeight: FontWeight.w400,
                  ),
                )
              else
                Text(
                  'All members filled',
                  style: TextStyle(
                    color: isDarkMode ? TColors.grey : TColors.darkerGrey,
                    fontSize: screenWidth * 0.035 * textScaleFactor,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              SizedBox(height: screenHeight * 0.01),

              // Skills section
              SizedBox(
                height: screenHeight * 0.05,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: idea.skills
                        .map((skill) => SkillTagWidget(skills: [skill]))
                        .toList(),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.005),

              // Join button
              if (canJoin)
                Center(
                  child: Container(
                    width: screenWidth * 0.4,
                    height: screenHeight * 0.05,
                    decoration: BoxDecoration(
                      color: TColors.primary, // Reduced opacity for disabled look
                      borderRadius: BorderRadius.circular(48),
                    ),
                    child: ElevatedButton(
                      onPressed: onJoinRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary, // Regular color for join button
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      ),
                      child: const Text('Join'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
