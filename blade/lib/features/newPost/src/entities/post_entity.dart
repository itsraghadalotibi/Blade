class PostEntity {
  final String id;
  final String ideaName;
  final String ideaDescription;
  final String number;
  final List<String> tags;
  final String userId;  // The ID of the user who created the post

  PostEntity({
    required this.id,
    required this.ideaName,
    required this.ideaDescription,
    required this.number,
    required this.tags,
    required this.userId,
  });
}
