import 'package:flutter/material.dart';
import '../../../announcement/src/announcement_model.dart';
import '../../../announcement/src/announcement_repository.dart';
import '../../../project_info/screens/project_screen.dart';
import '../../../../utils/constants/colors.dart';

class ProjectsWidget extends StatefulWidget {
  final List<Idea> projects;

  ProjectsWidget({required this.projects});

  @override
  _ProjectsWidgetState createState() => _ProjectsWidgetState();
}

class _ProjectsWidgetState extends State<ProjectsWidget> {
  bool isExpanded = false;

  bool _doesTextOverflow(String text, TextStyle style, double maxWidth, int maxLines) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.projects.isNotEmpty)
          Text(
            'Discover Blade Projects',
            style: TextStyle(fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          ),
        const SizedBox(height: 12),
        widget.projects.isEmpty
            ? Center(
                child: Text(
                  'No result found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            : ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.projects.length,
                itemBuilder: (context, index) {
                  final project = widget.projects[index];
                  final bool isCompleted = project.status == 'completed';
                  final Color statusColor = isCompleted ? Color(0xFF6C757D) : Color(0xFF148fff);

                  final bool exceedsMaxLines = _doesTextOverflow(
                    project.description,
                    TextStyle(
                      color: Color(0xFF060527),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                    313.0,
                    4,
                  );

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProjectScreen(
                              idea: project,
                              repository: AnnouncementRepository(),
                              canJoin: false,
                              useInvestButton: true, // Corrected parameter name
                            ),
                        ),
                      );
                    },
                    child: Container(
                      width: 345,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                project.title,
                                style: TextStyle(
                                  color: Color(0xFF060527),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(48),
                                ),
                                child: Text(
                                  isCompleted ? 'Completed' : 'Ongoing',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            project.description,
                            style: TextStyle(
                              color: Color(0xFF060527),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
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
                                  color: Colors.blue,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Center(
                            child: Container(
                              width: 92,
                              height: 27,
                              decoration: BoxDecoration(
                                color: TColors.primary,
                                borderRadius: BorderRadius.circular(48),
                              ),
                              child: Center(
                                child: Text(
                                  'Invest',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
