import 'package:flutter/material.dart';
import '../src/announcement_model.dart';
import '../src/announcement_repository.dart';
import 'avatar_stack_widget.dart';
import 'skill_tag_widget.dart';
import '../screens/members_screen.dart';
import '../../../utils/constants/colors.dart';

class AnnouncementCardWidget extends StatefulWidget {
  final Idea idea;
  final AnnouncementRepository repository;

  const AnnouncementCardWidget({
    super.key,
    required this.idea,
    required this.repository,
  });

  @override
  _AnnouncementCardWidgetState createState() => _AnnouncementCardWidgetState();
}

class _AnnouncementCardWidgetState extends State<AnnouncementCardWidget> {
  bool isExpanded = false;
  bool exceedsMaxLines = false; // Cache whether the text exceeds max lines

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTextOverflow();
    });
  }

  // Check if the description exceeds the max lines and update the state
  void _checkTextOverflow() {
    final textStyle = TextStyle(
      color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    final textStyle = TextStyle(
      color: const Color.fromARGB(255, 255, 254, 254),
      fontSize: screenWidth * 0.04 * textScaleFactor,
      fontWeight: FontWeight.w400,
    );

    // Assuming the max number of members for the idea is a predefined constant, e.g., 10
    const int maxMembers = 10;
    final int membersNeeded = maxMembers - widget.idea.members.length;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.02,
        horizontal: screenWidth * 0.05,
      ),
      child: Container(
        width: screenWidth * 0.9,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 42, 151, 241),
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: TColors.borderPrimary),
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
                        color: const Color.fromARGB(255, 241, 238, 238),
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
                style: textStyle,
                maxLines: isExpanded ? null : 4,
                overflow:
                    isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
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
                      color: Color.fromARGB(255, 90, 91, 92),
                      fontSize: screenWidth * 0.04 * textScaleFactor,
                    ),
                  ),
                ),
              SizedBox(height: screenHeight * 0.02),

              // Status for members needed
              Text(
                '$membersNeeded members needed',
                style: TextStyle(
                  color: Colors.white, // Make the text small and less prominent
                  fontSize: screenWidth * 0.035 * textScaleFactor,
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

              // Join button
              Center(
                child: Container(
                  width: screenWidth * 0.4,
                  height: screenHeight * 0.05,
                  decoration: BoxDecoration(
                    color: TColors.primary
                        .withOpacity(0.5), // Reduced opacity for disabled look
                    borderRadius: BorderRadius.circular(48),
                  ),
                  child: Center(
                    child: Text(
                      'Join',
                      style: TextStyle(
                        color: TColors.textWhite.withOpacity(
                            0.5), // Lightened text color to indicate it's disabled
                        fontSize: screenWidth * 0.04 * textScaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
