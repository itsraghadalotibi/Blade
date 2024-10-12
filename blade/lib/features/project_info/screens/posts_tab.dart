import 'package:flutter/material.dart';
import '../../announcement/src/announcement_repository.dart';

class PostsTab extends StatelessWidget {
  final String? ideaId;
  final AnnouncementRepository repository;

  const PostsTab({Key? key, required this.ideaId, required this.repository})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement logic to fetch and display posts related to the ideaId
    return Center(
      child: Text('Posts coming soon!', style: TextStyle(fontSize: 18)),
    );
  }
}
