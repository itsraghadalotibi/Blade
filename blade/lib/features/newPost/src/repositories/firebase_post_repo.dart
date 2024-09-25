// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/post_model.dart';
// import 'post_repo.dart';  // Rename this to idea_repo.dart after renaming

// class FirebaseIdeaRepository implements IdeaRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Create a new idea in the 'ideas' collection
//   @override
//   Future<void> createIdea(PostModel post) async {  // This should match the interface method name
//     try {
//       await _firestore.collection('ideas').doc(post.id).set(post.toJson());
//     } catch (e) {
//       throw Exception('Error creating idea: $e');
//     }
//   }

//   @override
//   Future<PostModel?> getIdeaById(String postId) async {
//     try {
//       DocumentSnapshot doc = await _firestore.collection('ideas').doc(postId).get();
//       if (doc.exists) {
//         return PostModel.fromJson(doc.data() as Map<String, dynamic>);
//       }
//       return null;
//     } catch (e) {
//       throw Exception('Error fetching idea: $e');
//     }
//   }

//   @override
//   Future<List<PostModel>> getIdeasByUserId(String userId) async {
//     try {
//       QuerySnapshot querySnapshot = await _firestore
//           .collection('ideas')
//           .where('userId', isEqualTo: userId)
//           .get();

//       return querySnapshot.docs
//           .map((doc) => PostModel.fromJson(doc.data() as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       throw Exception('Error fetching ideas: $e');
//     }
//   }

//   @override
//   Future<void> deleteIdea(String postId) async {
//     try {
//       await _firestore.collection('ideas').doc(postId).delete();
//     } catch (e) {
//       throw Exception('Error deleting idea: $e');
//     }
//   }
// }
