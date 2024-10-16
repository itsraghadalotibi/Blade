// Path: lib/features/profile/screens/project_idea_card_widget.dart

import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:blade_app/features/announcement/src/announcement_repository.dart';
import 'package:blade_app/features/project_info/screens/project_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../repository/project_idea_repository.dart';
import '../widgets/avatar_stack.dart'; // Correct import after renaming
import '../widgets/skill_tag.dart'; // Correct import after renaming

class ProjectIdeaCardWidget extends StatefulWidget {
  final Idea idea;
  final ProjectIdeaRepository repository;
  final AnnouncementRepository announcementRepository;
  final Function()? refershIdeasInProfile;

  const ProjectIdeaCardWidget(
      {super.key, required this.idea, required this.repository, required this.announcementRepository, required this.refershIdeasInProfile});

  @override
  _ProjectIdeaCardWidgetState createState() => _ProjectIdeaCardWidgetState();
}

class _ProjectIdeaCardWidgetState extends State<ProjectIdeaCardWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: screenWidth * 0.04 * textScaleFactor,
      fontWeight: FontWeight.w400,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectScreen(
              canJoin: false,
              idea: widget.idea,
              repository: widget.announcementRepository,
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
            color: const Color(0xFF333333),
            borderRadius: BorderRadius.circular(23),
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
                          color: Colors.white,
                          fontSize: screenWidth * 0.055 * textScaleFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    SizedBox(
                      width: screenWidth * 0.2,
                      height: screenWidth * 0.1,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: AvatarStack(
                          userIds: widget.idea.members,
                          screenWidth: screenWidth,
                          repository: widget.repository,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                LayoutBuilder(
                  builder: (context, constraints) {
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
      
                    tp.layout(maxWidth: constraints.maxWidth);
                    bool exceedsMaxLines = tp.didExceedMaxLines;
      
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.idea.description,
                          style: textStyle,
                          maxLines: isExpanded ? null : 4,
                          overflow: isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
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
                                color: const Color.fromARGB(255, 41, 151, 235),
                                fontSize: screenWidth * 0.04 * textScaleFactor,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                if(widget.idea.members[0] == FirebaseAuth.instance.currentUser?.uid && 
                  widget.idea.requestCount != null && widget.idea.requestCount != 0)...[
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    "Number of requests is ${widget.idea.requestCount!}",
                    style: textStyle
                  ),
                ],
                  SizedBox(height: screenHeight * 0.01),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
