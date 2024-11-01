import 'package:blade_app/features/announcement/bloc/announcement_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../investment_request/screens/investment_request_form.dart';
import '../../project_info/screens/project_screen.dart';
import '../src/announcement_model.dart';
import '../src/announcement_repository.dart';
import 'avatar_stack_widget.dart';
import 'skill_tag_widget.dart';
import '../screens/members_screen.dart';
import '../../../utils/constants/colors.dart';

class AnnouncementCardWidget extends StatefulWidget {
  final Idea idea;
  final AnnouncementRepository repository;
  final Function() fetchAll;

  const AnnouncementCardWidget({
    super.key,
    required this.idea,
    required this.repository,
    required this.fetchAll,
  });

  @override
  _AnnouncementCardWidgetState createState() => _AnnouncementCardWidgetState();
}

class _AnnouncementCardWidgetState extends State<AnnouncementCardWidget> {
  bool isExpanded = false;
  bool exceedsMaxLines = false;
  String? currentUserId;
  bool isJoinPending = false;
  String? userType; 

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
     if (currentUserId != null) {
      _fetchUserType(); // Fetch user type
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTextOverflow();
    });
  }
  // Function to fetch the user type (collaborator or supporter)
  void _fetchUserType() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('collaborators')
          .doc(currentUserId)
          .get();
      if (userDoc.exists) {
        setState(() {
          userType = 'collaborator'; // Assuming 'type' field exists
        });
      }
      else{
        setState(() {
          userType = 'supporter'; // Assuming 'type' field exists
        });
      }
    } catch (e) {
      print('Error fetching user type: $e');
    }
  }

  void _checkTextOverflow() {
    final textStyle = TextStyle(
      color: Theme.of(context).textTheme.bodyLarge?.color ?? TColors.textPrimary,
      fontSize: MediaQuery.of(context).size.width *
          0.04 *
          MediaQuery.of(context).textScaleFactor,
      fontWeight: FontWeight.w400,
    );

    final span = TextSpan(
      text: widget.idea.description,
      style: textStyle,
    );

    final tp = TextPainter(
      text: span,
      maxLines: 4,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    tp.layout(maxWidth: MediaQuery.of(context).size.width * 0.9);
    setState(() {
      exceedsMaxLines = tp.didExceedMaxLines;
    });
  }

  // Function to handle the join request
  void _handleJoinRequest() async {
    if (!mounted) return; // Ensure the widget is still mounted

    // Immediately show success message on button tap
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green, // Success background color
        behavior: SnackBarBehavior.floating,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(
              Icons.check_circle, // Success icon
              color: Colors.white,
            ),
            const SizedBox(width: 8), // Space between icon and text
            const Expanded(
              child: Text(
                'Join request sent successfully!',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );

    setState(() {
      isJoinPending = true; // Show "Waiting" state
      widget.idea.isJoined = true; // Mark as joined
    });

    try {
      // Send the join request
      await widget.repository.sendJoinRequest(widget.idea, currentUserId!);

      if (!mounted) return; // Ensure the widget is still mounted after async

      widget.fetchAll(); // Refresh the list after the join request

    } catch (e) {
      if (!mounted) return; // Ensure widget is still mounted before showing error

      setState(() {
        isJoinPending = false;
        widget.idea.isJoined = false;
      });

      // Show error SnackBar if the request fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red, // Error background color
          behavior: SnackBarBehavior.floating,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.error, // Error icon
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Failed to send join request!',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  void _handleSendInvestment() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => InvestmentRequestFormScreen(
        projectId: widget.idea.id!,
        projectTitle: widget.idea.title,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final int maxMembers = widget.idea.maxMembers;
    final int currentMembers = widget.idea.members.length;
    final int membersNeeded =
        maxMembers > currentMembers ? maxMembers - currentMembers : 0;

    bool canJoin = currentUserId != null &&
        !widget.idea.isJoined! &&
        !widget.idea.members.contains(currentUserId) &&
        currentMembers < maxMembers &&
        !isJoinPending;

    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectScreen(
                canJoin: canJoin,
                idea: widget.idea,
                repository: widget.repository,
                onJoinRequestSent: null,
              ),
            ),
          );
        },
        child: Padding(
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
                          widget.idea.title,
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MembersScreen(
                                memberIds: widget.idea.members,
                                ideaSkills: widget.idea.skills,
                                repository: widget.repository,
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
                              userIds: widget.idea.members,
                              screenWidth: screenWidth,
                              repository: widget.repository,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),

                  // Description and "Show more" logic
                  Text(
                    widget.idea.description,
                    style: TextStyle(
                      color: isDarkMode ? TColors.textWhite : TColors.black,
                    ),
                    maxLines: isExpanded ? null : 4,
                    overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),
                  if (exceedsMaxLines)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Text(
                        isExpanded ? "Show less" : "Show more",
                        style: TextStyle(
                          color: TColors.info,
                          fontSize: screenWidth * 0.04 * textScaleFactor,
                        ),
                      ),
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
                        children: widget.idea.skills
                            .map((skill) => SkillTagWidget(skills: [skill]))
                            .toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),

                   // Conditional Button based on userType
                  if (userType != null) // Only show button after userType is fetched
                    if (userType == 'collaborator' && canJoin)
                      // Show Join button for collaborators
                      Center(
                        child: Container(
                          width: screenWidth * 0.4,
                          height: screenHeight * 0.05,
                          decoration: BoxDecoration(
                            color: TColors.primary,
                            borderRadius: BorderRadius.circular(48),
                          ),
                          child: ElevatedButton(
                            onPressed: _handleJoinRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isJoinPending
                                  ? Colors.grey // Grey color for waiting status
                                  : TColors.primary, // Regular color for join button
                              padding: const EdgeInsets.symmetric(horizontal: 18.0),
                            ),
                            child: Text(isJoinPending ? 'Waiting' : 'Join'),
                          ),
                        ),
                      )
                    else if (userType == 'supporter')
                      // Show Send Investment button for supporters
                      Center(
                        child: Container(
                          width: screenWidth * 0.6,
                          height: screenHeight * 0.05,
                          decoration: BoxDecoration(
                            color: TColors.primary,
                            borderRadius: BorderRadius.circular(48),
                          ),
                          child: ElevatedButton(
                            onPressed: _handleSendInvestment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 18.0),
                            ),
                            child: const Text('Send Investment'),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
