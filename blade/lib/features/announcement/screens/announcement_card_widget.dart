import 'package:flutter/material.dart';
import '../src/announcement_model.dart';
import '../src/announcement_repository.dart';
import 'avatar_stack_widget.dart';
import 'skill_tag_widget.dart';

class AnnouncementCardWidget extends StatefulWidget {
  final Idea idea;
  final AnnouncementRepository repository;

  AnnouncementCardWidget({required this.idea, required this.repository});

  @override
  _AnnouncementCardWidgetState createState() => _AnnouncementCardWidgetState();
}

class _AnnouncementCardWidgetState extends State<AnnouncementCardWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Text style to be reused
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: screenWidth * 0.04 * textScaleFactor,
      fontWeight: FontWeight.w400,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.02,
        horizontal: screenWidth * 0.05,
      ),
      child: Container(
        width: screenWidth * 0.9,
        decoration: BoxDecoration(
          color: Color(0xFF333333), // Set card background color to #333333
          borderRadius: BorderRadius.circular(23),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row for title and avatar stack
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
                  // Wrapping AvatarStackWidget in SingleChildScrollView to enable horizontal scrolling
                  SizedBox(
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
                ],
              ),
              SizedBox(height: screenHeight * 0.01), // Reduced space between title and description

              // Conditionally show "Show more" based on description length
              LayoutBuilder(
                builder: (context, constraints) {
                  final span = TextSpan(
                    text: widget.idea.description,
                    style: textStyle,
                  );

                  final tp = TextPainter(
                    text: span,
                    maxLines: 4,  // We measure for 4 lines to check if truncation is needed
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
                        maxLines: isExpanded ? null : 4,  // Show 4 lines when collapsed
                        overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,  // Ellipsis for truncated text
                      ),
                      // Only show "Show more" if the description exceeds 4 lines
                      if (exceedsMaxLines)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isExpanded = !isExpanded;  // Toggle between expanded and collapsed state
                            });
                          },
                          child: Text(
                            isExpanded ? "Show less" : "Show more",
                            style: TextStyle(
                              color: Color.fromARGB(255, 41, 151, 235),  // "Show more" in #0000FF blue color
                              fontSize: screenWidth * 0.04 * textScaleFactor,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              SizedBox(height: screenHeight * 0.02), // Reduced space before the skill tags

              // Skill Tags limited to 2 rows, with scrolling for more
              Container(
                height: screenHeight * 0.05, // Reduced height for the skill tags
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: widget.idea.skills.map((skill) => SkillTagWidget(skills: [skill])).toList(),
                  ),
                ),
              ),
              
              // Further minimized space between the skills and the Join button
              SizedBox(height: screenHeight * 0.005),

              // Join Button
              Center(
                child: Container(
                  width: screenWidth * 0.4,
                  height: screenHeight * 0.05,
                  decoration: BoxDecoration(
                    color: Color(0xFFFD5336), // Set Join button color to #FD5336
                    borderRadius: BorderRadius.circular(48),
                  ),
                  child: Center(
                    child: Text(
                      'Join',
                      style: TextStyle(
                        color: Colors.white,
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
