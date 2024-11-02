// Updated CompletedProjectsWidget with ProjectCard UI

import 'package:flutter/material.dart';
import '../../../announcement/src/announcement_model.dart';
import '../../../announcement/src/announcement_repository.dart';
import '../../../project_info/screens/project_screen.dart';

class CompletedProjectsWidget extends StatelessWidget {
  final List<Idea> projects;

  CompletedProjectsWidget({required this.projects});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discover Blade Projects',
          style: TextStyle(fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            final bool isCompleted = project.status == 'completed';
            final Color statusColor = isCompleted ? Color(0xB3FFFFFF) : Color(0xFFFD5336);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectScreen(
                      idea: project,
                      repository: AnnouncementRepository(),
                      canJoin: false,
                      onJoinRequestSent: () {},
                    ),
                  ),
                );
              },
              child: Container(
                width: 345,
                height: 137,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      top: 16,
                      child: Container(
                        width: 313,
                        height: 93,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            const SizedBox(height: 8),
                            Text(
                              project.description,
                              style: TextStyle(
                                color: Color(0xFF060527),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 127,
                      top: 103,
                      child: Container(
                        width: 92,
                        height: 27,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF4fe3c2),
                              Color(0xFF6febf4),
                            ],
                            begin: Alignment.center,
                            end: Alignment.bottomRight,
                          ),
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
                    Positioned(
                      left: 248,
                      top: 14,
                      child: Container(
                        width: 81,
                        height: 19,
                        decoration: ShapeDecoration(
                          color: statusColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(48),
                          ),
                        ),
                        child: Center(
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
