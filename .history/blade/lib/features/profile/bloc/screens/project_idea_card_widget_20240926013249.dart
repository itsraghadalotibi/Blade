// Path: lib/features/profile/screens/project_idea_card_widget.dart

import 'package:flutter/material.dart';
import '../src/project_idea_model.dart';
import '../repository/project_idea_repository.dart';
import '../widgets/avatar_stack.dart'; // Correct import after renaming
import '../widgets/skill_tag.dart'; // Correct import after renaming

class ProjectIdeaCardWidget extends StatefulWidget {
  final Idea idea;
  final ProjectIdeaRepository repository;

  const ProjectIdeaCardWidget(
      {super.key, required this.idea, required this.repository});

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

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.02,
        horizontal: screenWidth * 0.05,
      ),
      child: Container(
        width: screenWidth * 0.9,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 151, 148, 148),
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
              SizedBox(height: screenHeight * 0.02),
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
    );
  }
}
