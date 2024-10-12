import 'package:blade_app/features/announcement/src/announcement_repository.dart';
import 'package:flutter/material.dart';
import '../../announcement/src/announcement_model.dart';





class MembersTab extends StatelessWidget {
  final Idea idea;
  final AnnouncementRepository repository;

  const MembersTab({Key? key, required this.idea, required this.repository})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Collaborator>>(
      future: _fetchMembers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading members: ${snapshot.error}'),
          );
        } else {
          final members = snapshot.data ?? [];

          if (members.isEmpty) {
            return const Center(
              child: Text('No members found for this project.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(member.profilePhotoUrl ?? ''),
                ),
                title: Text('${member.firstName} ${member.lastName}'),
                // You can add more member details here if needed
              );
            },
          );
        }
      },
    );
  }

  Future<List<Collaborator>> _fetchMembers() async {
    // Fetch collaborator details for each member ID
    List<Collaborator> members = [];
    for (String memberId in idea.members) {
      final member = await repository.fetchCollaborator(memberId);
      if (member != null) {
        members.add(member);
      }
    }
    return members;
  }
}
