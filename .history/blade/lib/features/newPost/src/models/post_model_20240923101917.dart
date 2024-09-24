
import '../entities/post_entity.dart';

class PostModel extends PostEntity {
  PostModel({
    required String id,
    required String ideaName,
    required String ideaDescription,
    required String number,
    required List<String> tags,
    required String userId,
  }) : super(
          id: id,
          ideaName: ideaName,
          ideaDescription: ideaDescription,
          number: number,
          tags: tags,
          userId: userId,
        );

  // Convert the post to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ideaName': ideaName,
      'ideaDescription': ideaDescription,
      'number': number,
      'tags': tags,
      'userId': userId,
    };
  }

  // Create a PostModel from JSON
  static PostModel fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      ideaName: json['ideaName'] ?? '',
      ideaDescription: json['ideaDescription'] ?? '',
      number: json['number'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      userId: json['userId'] ?? '',
    );
  }
}
