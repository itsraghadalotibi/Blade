import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import 'post_repo.dart';

class FirebasePostRepository implements PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new post
  @override
  Future<void> createPost(PostModel post) async {
    try {
      await _firestore.collection('posts').doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception('Error creating post: $e');
    }
  }

  // Fetch post by ID
  @override
  Future<PostModel?> getPostById(String postId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('posts').doc(postId).get();
      if (doc.exists) {
        return PostModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching post: $e');
    }
  }

  // Fetch all posts by a user
  @override
  Future<List<PostModel>> getPostsByUserId(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => PostModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

  // Delete a post by ID
  @override
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw Exception('Error deleting post: $e');
    }
  }
}
