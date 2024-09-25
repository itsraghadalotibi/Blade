import 'package:flutter/material.dart';
import '../src/announcement_repository.dart';
import '../widgets/skill_tag_widget.dart';
import '../src/announcement_model.dart';
import 'announcement_screen.dart';
import '../../../utils/constants/colors.dart';
import 'package:blade_app/features/profile/bloc/screens/collaborator_profile_screen.dart';

class MembersScreen extends StatelessWidget {
  final List<String> memberIds;
  final List<String> ideaSkills;
  final AnnouncementRepository repository;

  const MembersScreen({
    required this.memberIds,
    required this.ideaSkills,
    required this.repository,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.primaryBackground, // Light mode background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: TColors.textPrimary, // Light mode icon color
        ),
        title: const Text(
          'Members',
          style: TextStyle(
            fontSize: 20,
            color: TColors.textPrimary, // Light mode text color
          ),
        ),
      ),
      body: FutureBuilder<List<Collaborator>>(
        future: _fetchCollaborators(), // Fetch collaborators first
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No members found.'));
          }

          final collaborators = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: collaborators.length,
            itemBuilder: (context, index) {
              final collaborator = collaborators[index];

              // For the first member, show "Idea owner"
              final isIdeaOwner = index == 0;
              final matchingSkills = isIdeaOwner
                  ? [
                      "Idea owner"
                    ] // Only show "Idea owner" for the first member
                  : collaborator.skills
                      .where((skill) => ideaSkills.contains(skill))
                      .toList();

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CollaboratorProfileScreen(
                        userId: collaborator.uid,
                        showBackButton: true, // Pass true to show the back button
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: TColors.lightContainer, // Light mode container color
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: TColors.borderPrimary), // Light mode border
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(collaborator.profilePhotoUrl),
                          radius: 30,
                        ),
                        title: Text(
                          '${collaborator.firstName} ${collaborator.lastName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TColors.textPrimary, // Light mode text color
                            fontSize: 18,
                          ),
                        ),
                        subtitle: matchingSkills.isNotEmpty
                            ? GestureDetector(
                                // Prevent the scroll on the skill tags from triggering the profile navigation
                                onTap: () {},
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: matchingSkills.map((skill) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: SkillTagWidget(skills: [skill]),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              )
                            : const Text(
                                'No matching skills',
                                style: TextStyle(
                                    color: TColors
                                        .textSecondary), // Light mode secondary text color
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 10);
            },
          );
        },
      ),
    );
  }

  // Fetch all collaborators based on memberIds
  Future<List<Collaborator>> _fetchCollaborators() async {
    List<Collaborator> collaborators = [];
    for (String memberId in memberIds) {
      final collaborator = await repository.fetchCollaborator(memberId);
      if (collaborator != null) {
        collaborators.add(collaborator);
      }
    }
    return collaborators;
  }
}
