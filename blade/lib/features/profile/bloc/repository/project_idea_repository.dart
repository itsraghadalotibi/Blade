// Path: lib/features/profile/repository/project_idea_repository.dart

import 'dart:io';
import 'package:blade_app/features/project_info/src/post_model.dart';
import 'package:path/path.dart';
import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import '../src/collaborator_profile_model.dart';

class ProjectIdeaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Fetch ideas where the user is the owner (i.e., userId is the first member in the 'members' array)
  Future<List<Idea>> fetchIdeasByOwner(String userId,String status) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('ideas')
          .where('status',isEqualTo: status)
          .where('members',
              arrayContains: userId) // Check if the user is in the members list
          .get();
      final allJoinRequests = (await FirebaseFirestore.instance
          .collection('join_requests')
          .where('status', isEqualTo: "pending")
          .where('ideaId', whereIn: snapshot.docs.map((d)=>d.id).toList())
          .get()).docs;
      // Map Firestore documents to Idea model and filter by the owner (userId at index 0)
      List<Idea> ideas = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final members = List<String>.from(data['members']);

            // Only return ideas where the user is at index 0 (the owner)
            if ((members.isNotEmpty && members[0] == userId) || status != 'open') {
              return Idea(
                id: doc.id,
                status: data['status'],
                title: data['title'],
                description: data['description'],
                skills: List<String>.from(data['skills']),
                members: members,
                maxMembers: data['maxMembers'],
                requestCount: allJoinRequests.where((d)=>d["ideaId"] == doc.id).length
              );
            }
            return null;
          })
          .where((idea) => idea != null)
          .cast<Idea>()
          .toList();

      return ideas;
    } catch (e) {
      print('Error fetching ideas for owner: $e');
      return [];
    }
  }

  // Fetch ideas for dropdown button
  Future<List<Idea>> fetchIdeasForDropdownButton(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('ideas')
          .where('members',
              arrayContains: userId) // Check if the user is in the members list
          .get();
      List<Idea> ideas = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Idea.fromMap(data,doc.id);
          })
          .toList();

      return ideas;
    } catch (e) {
      print('Error fetching ideas for owner: $e');
      return [];
    }
  }

  // Fetch individual collaborator (used in AvatarWidget)
  Future<CollaboratorProfileModel?> fetchCollaborator(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('collaborators').doc(userId).get();
      if (doc.exists) {
        return CollaboratorProfileModel.fromMap(
            doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching collaborator: $e');
      return null;
    }
  }

  // Upload post images to Firebase Storage
  Future<List<String>> uploadPostImages(List<File> imageFiles) async {
    try {
      List<String> result = [];
      for (var i = 0; i < imageFiles.length; i++) {
        String name = DateFormat("${basename(imageFiles[i].path)}-yyyy-MM-dd-mm-ss").format(DateTime.now());
        Reference imageRef = _firebaseStorage.ref().child('post_images/$name.jpg');
        UploadTask uploadTask = imageRef.putFile(imageFiles[i]);
        await uploadTask.whenComplete(() {});
        String downloadUrl = await imageRef.getDownloadURL();
        result.add(downloadUrl);
      }
      return result;
    } catch (e) {
      return [];
    }
  }

  // Delete post images
  Future<bool> deletePostImages(List<String> deletedImages) async {
    try {
      for (var i = 0; i < deletedImages.length; i++) {
        Reference imageRef = _firebaseStorage.refFromURL(deletedImages[i]);
        await imageRef.delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Send New Post
  Future<void> sendNewPost(PostModel post,List<File> imageFiles) async {
    try {
      post.images ??= [];
      post.images?.addAll((await uploadPostImages(imageFiles)));
      await _firestore.collection('posts').add(post.toMap());
    } catch (e) {
      print('Error updating idea: $e');
      throw Exception('Failed to add post');
    }
  }

    // Update Post
  Future<void> updatePost(PostModel post,List<File> imageFiles,List<String> deletedImages) async {
    try {
      await deletePostImages(deletedImages);
      post.images ??= [];
      post.images?.addAll((await uploadPostImages(imageFiles)));
      await _firestore.collection('posts').doc(post.id).update(post.toMap());
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

    // Delete Post
  Future<void> deletePost(PostModel post) async {
    try {
      await deletePostImages(post.images??[]);
      await _firestore.collection('posts').doc(post.id).delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
}
