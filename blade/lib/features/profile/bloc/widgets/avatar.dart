// Path: lib/features/profile/widgets/avatar.dart

import 'package:flutter/material.dart';
import '../repository/project_idea_repository.dart';
import '../src/collaborator_profile_model.dart'; // Correct import for CollaboratorProfileModel

class AvatarWidget extends StatelessWidget {
  final String userId;
  final ProjectIdeaRepository repository;

  AvatarWidget({required this.userId, required this.repository});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CollaboratorProfileModel?>(
      future:
          repository.fetchCollaborator(userId), // Use CollaboratorProfileModel
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return CircleAvatar(
            backgroundImage: NetworkImage(
                snapshot.data!.profilePhotoUrl ?? 'assets/images/user.png'),
            radius: 15, // Adjust the radius based on your design
          );
        }

        return const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person),
        );
      },
    );
  }
}
