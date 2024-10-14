import 'package:blade_app/features/announcement/src/announcement_repository.dart';
import 'package:flutter/material.dart';
import '../../announcement/src/announcement_model.dart';
import '../../announcement/widgets/skill_tag_widget.dart';
import '../../profile/bloc/screens/collaborator_profile_screen.dart';




class MembersTab extends StatelessWidget {
  final Idea idea;
  final AnnouncementRepository repository;

  const MembersTab({
    Key? key,
    required this.idea,
    required this.repository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<Collaborator>>(
      future: _fetchCollaborators(),
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

            // For the first member, show "Project Owner"
            final isProjectOwner = index == 0;
            final matchingSkills = isProjectOwner
                ? ["Project Owner"]
                : collaborator.skills
                    .where((skill) => idea.skills.contains(skill))
                    .toList();

            return GestureDetector(
              onTap: () {
                // Navigate to the collaborator's profile
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CollaboratorProfileScreen(
                      userId: collaborator.uid,
                      showBackButton: true,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey[850]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: isDarkMode
                      ? null
                      : Border.all(color: Colors.grey),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(collaborator.profilePhotoUrl),
                        radius: 30,
                      ),
                      title: Text(
                        '${collaborator.firstName} ${collaborator.lastName}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: matchingSkills.isNotEmpty
                          ? GestureDetector(
                              onTap: () {}, // Prevent scrolling issue
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: matchingSkills.map((skill) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: SkillTagWidget(skills: [skill]),
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                          : Text(
                              'No matching skills',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.grey[600],
                              ),
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
    );
  }

  // Fetch collaborators based on memberIds
  Future<List<Collaborator>> _fetchCollaborators() async {
    List<Collaborator> collaborators = [];
    for (String memberId in idea.members) {
      final collaborator = await repository.fetchCollaborator(memberId);
      if (collaborator != null) {
        collaborators.add(collaborator);
      }
    }
    return collaborators;
  }
}