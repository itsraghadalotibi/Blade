import 'package:flutter/material.dart';
import '../src/announcement_repository.dart';
import '../widgets/skill_tag_widget.dart';
import '../src/announcement_model.dart';

class MembersScreen extends StatelessWidget {
  final List<String> memberIds;
  final List<String> ideaSkills;
  final AnnouncementRepository repository;

  const MembersScreen({
    required this.memberIds,
    required this.ideaSkills,
    required this.repository,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF848484),
        ),
        title: const Text(
          'Members',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<List<Collaborator>>(
        future: _fetchCollaborators(),  // Fetch collaborators first
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
              final matchingSkills = collaborator.skills
                  .where((skill) => ideaSkills.contains(skill))
                  .toList();

              return Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(collaborator.profilePhotoUrl),
                    radius: 30,
                  ),
                  title: Text(
                    '${collaborator.firstName} ${collaborator.lastName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: matchingSkills.isNotEmpty
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: matchingSkills.map((skill) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: SkillTagWidget(skills: [skill]),
                              );
                            }).toList(),
                          ),
                        )
                      : const Text(
                          'No matching skills',
                          style: TextStyle(color: Colors.white70),
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
