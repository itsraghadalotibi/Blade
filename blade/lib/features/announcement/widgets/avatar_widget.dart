import 'package:flutter/material.dart';
import '../src/announcement_repository.dart';
import '../src/announcement_model.dart';

class AvatarWidget extends StatelessWidget {
  final String userId;
  final AnnouncementRepository repository;

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
            radius: 15, // Adjusted for your avatar size needs
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
