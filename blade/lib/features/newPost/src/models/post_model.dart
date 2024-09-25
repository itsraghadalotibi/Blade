// import '../entities/post_entity.dart';

// class PostModel extends PostEntity {
//   PostModel({
//     required String id,
//     required String ideaName,  // Matches 'title' in ideas
//     required String ideaDescription,  // Matches 'description' in ideas
//     required String number,  // Matches 'maxMembers' in ideas
//     required List<String> tags,  // Matches 'skills' in ideas
//     required String userId,  // Assuming 'userId' is stored in ideas
//   }) : super(
//           id: id,
//           ideaName: ideaName,
//           ideaDescription: ideaDescription,
//           number: number,
//           tags: tags,
//           userId: userId,
//         );

//   // Convert the post to JSON for Firestore
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': ideaName,  // Use 'title' field in 'ideas'
//       'description': ideaDescription,  // Use 'description' field in 'ideas'
//       'maxMembers': number,  // Use 'maxMembers' field in 'ideas'
//       'skills': tags,  // Use 'skills' field in 'ideas'
//       'userId': userId,
//     };
//   }

//   // Create a PostModel from JSON
//   static PostModel fromJson(Map<String, dynamic> json) {
//     return PostModel(
//       id: json['id'] ?? '',
//       ideaName: json['title'] ?? '',  // Map 'title' to ideaName
//       ideaDescription: json['description'] ?? '',  // Map 'description' to ideaDescription
//       number: json['maxMembers'] ?? '',  // Map 'maxMembers' to number
//       tags: List<String>.from(json['skills'] ?? []),  // Map 'skills' to tags
//       userId: json['userId'] ?? '',
//     );
//   }
// }
