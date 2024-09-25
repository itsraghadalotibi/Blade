// Path: lib/features/profile/src/project_idea_model.dart

class Idea {
  final String title;
  final String description;
  final List<String> skills;
  final List<String> members;
  final int maxMembers;

  Idea({
    required this.title,
    required this.description,
    required this.skills,
    required this.members,
    required this.maxMembers,
  });
}
