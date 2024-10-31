import 'package:flutter/material.dart';
import '../../../announcement/src/announcement_model.dart';

class CompletedProjectsWidget extends StatelessWidget {
  final List<Idea> projects;

  CompletedProjectsWidget({required this.projects});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discover Completed Projects',
          style: TextStyle(fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];

            return Container(
              width: 345,
              height: 109,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Container(
                      width: 313,
                      height: 93,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 313,
                              height: 93,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 233,
                                    top: -2,
                                    child: SizedBox(
                                      width: 80,
                                      child: Text(
                                        '${project.members.length} members',
                                        style: TextStyle(
                                          color: Color(0xFF8D8DA6),
                                          fontSize: 13,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w300,
                                          height: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: -2,
                                    child: SizedBox(
                                      width: 161,
                                      child: Text(
                                        project.title,
                                        style: TextStyle(
                                          color: Color(0xFF060527),
                                          fontSize: 16,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                          height: 0.08,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: 31,
                                    child: SizedBox(
                                      width: 313,
                                      child: Text(
                                        project.description, // Assuming project.description contains a brief about the project
                                        style: TextStyle(
                                          color: Color(0xFF060527),
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 0.11,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
