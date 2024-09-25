// Path: lib/features/profile/widgets/avatar.dart

import 'package:flutter/material.dart';
import '../repository/project_idea_repository.dart';

class AvatarWidget extends StatelessWidget {
  final String userId;
  final ProjectIdeaRepository repository;

  AvatarWidget({required this.userId, required this.repository});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Collaborator?>(
      future: repository.fetchCollaborator(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return CircleAvatar(
            backgroundImage: NetworkImage(snapshot.data!.profilePhotoUrl),
            radius: 15, // Adjust the radius based on your design
          );
        }

        return CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person),
        );
      },
    );
  }
}
