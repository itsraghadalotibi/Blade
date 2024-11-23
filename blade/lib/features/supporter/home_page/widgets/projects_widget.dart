import 'package:flutter/material.dart';
import '../../../announcement/src/announcement_model.dart';
import '../../../announcement/src/announcement_repository.dart';
import '../../../investment_request/screens/investment_request_form.dart';
import '../../../project_info/screens/project_screen.dart';
import '../../../../utils/constants/colors.dart';
import 'no_result_widget.dart'; // Import the new widget

class ProjectsWidget extends StatefulWidget {
  final List<Idea> projects;
  final bool showDiscoverText;

  ProjectsWidget({
    required this.projects,
    this.showDiscoverText = true,
  });

  @override
  _ProjectsWidgetState createState() => _ProjectsWidgetState();
}

class _ProjectsWidgetState extends State<ProjectsWidget> {
  bool isExpanded = false;

  bool _doesTextOverflow(
      String text, TextStyle style, double maxWidth, int maxLines) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  void _handleSendInvestment(Idea project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvestmentRequestFormScreen(
          projectId: project.id!,
          projectTitle: project.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showDiscoverText && widget.projects.isNotEmpty)
          const Text(
            'Discover Blade Projects',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        const SizedBox(height: 12),
        widget.projects.isEmpty
            ? NoResultWidget(message: 'No projects found.')
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.projects.length,
                itemBuilder: (context, index) {
                  final project = widget.projects[index];
                  final bool isCompleted = project.status == 'completed';
                  final Color statusColor = isCompleted
                      ? const Color(0xFF6C757D)
                      : const Color(0xFF148fff);

                  final bool exceedsMaxLines = _doesTextOverflow(
                    project.description,
                    TextStyle(
                      color: isDarkMode ? Colors.white : TColors.black,
                      fontSize: 14,
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
                            canSendComment: false,
                            idea: project,
                            repository: AnnouncementRepository(),
                            canJoin: false,
                            useInvestButton: true,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: isDarkMode ? TColors.container : TColors.white,
                        border: isDarkMode
                            ? null
                            : Border.all(color: TColors.borderPrimary),
                        borderRadius: BorderRadius.circular(23),
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
                                  color: isDarkMode ? Colors.white : TColors.black,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(48),
                                ),
                                child: Text(
                                  isCompleted ? 'Completed' : 'Ongoing',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
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
                              color: isDarkMode ? Colors.white : TColors.black,
                              fontSize: 13.9,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
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
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Center(
                            child: GestureDetector(
                              onTap: () => _handleSendInvestment(project),
                              child: Container(
                                width: 120,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: TColors.primary,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: FittedBox(
                                    child: Text(
                                      'Request Invest',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
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
