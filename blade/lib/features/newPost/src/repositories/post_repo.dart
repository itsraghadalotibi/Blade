import '../models/post_model.dart';

abstract class PostRepository {
  Future<void> createPost(PostModel post);
  Future<PostModel?> getPostById(String postId);
  Future<List<PostModel>> getPostsByUserId(String userId);
  Future<void> deletePost(String postId);
}
