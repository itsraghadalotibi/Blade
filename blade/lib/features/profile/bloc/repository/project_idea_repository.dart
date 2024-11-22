// Path: lib/features/profile/repository/project_idea_repository.dart

import 'dart:io';
import 'package:blade_app/features/project_info/src/post_model.dart';
import 'package:path/path.dart';
import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import '../../../GithubPoints/bloc/git_hub_points_bloc.dart';
import '../../../GithubPoints/bloc/git_hub_points_event.dart';
import '../src/collaborator_profile_model.dart';

class ProjectIdeaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
    Future<List<Idea>> fetchOngoingIdeas() async {
    try {
      // Fetch all projects with the "ongoing" status
      final projectSnapshot = await _firestore
          .collection('ideas')
          .where('status', isEqualTo: 'ongoing')
          .get();

      // Map the Firestore documents to a list of `Idea` objects
      return projectSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Idea.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print("Error fetching ongoing ideas: $e");
      return [];
    }
  }

  Future<void> logLikesForOngoingProjects() async {
    try {
      // Fetch all ongoing projects
      final projectSnapshot = await _firestore
          .collection('ideas')
          .where('status', isEqualTo: 'ongoing') // Adjust 'status' if needed
          .get();

      for (var project in projectSnapshot.docs) {
        final projectId = project.id;
        print("Project ID: $projectId, Project Title: ${project.data()['title']}");

        // Fetch all posts related to this project
        final postsSnapshot = await _firestore
            .collection('posts')
            .where('ideaId', isEqualTo: projectId)
            .get();

        int totalLikes = 0;

        for (var postDoc in postsSnapshot.docs) {
          final List<dynamic> likes = postDoc.data()['likes'] ?? [];
          totalLikes += likes.length;
          print("Post ID: ${postDoc.id}, Likes Count: ${likes.length}");
        }

        print("Total Likes for Project $projectId: $totalLikes");
      }
    } catch (e) {
      print("Error logging likes for ongoing projects: $e");
    }
  }
  // Fetch ideas where the user is the owner (i.e., userId is the first member in the 'members' array)
  Future<List<Idea>> fetchIdeasByOwner(String userId, String status) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('ideas')
          .where('status', isEqualTo: status)
          .where('members',
              arrayContains: userId) // Check if the user is in the members list
          .get();
      final allJoinRequests = (await FirebaseFirestore.instance
              .collection('join_requests')
              .where('status', isEqualTo: "pending")
              .where('ideaId', whereIn: snapshot.docs.map((d) => d.id).toList())
              .get())
          .docs;
      // Map Firestore documents to Idea model and filter by the owner (userId at index 0)
      List<Idea> ideas = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final members = List<String>.from(data['members']);

            // Only return ideas where the user is at index 0 (the owner)
            if ((members.isNotEmpty && members[0] == userId) ||
                status != 'open') {
              return Idea(
                  id: doc.id,
                  status: data['status'],
                  title: data['title'],
                  description: data['description'],
                  skills: List<String>.from(data['skills']),
                  members: members,
                  maxMembers: data['maxMembers'],
                  requestCount: allJoinRequests
                      .where((d) => d["ideaId"] == doc.id)
                      .length);
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
      List<Idea> ideas = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Idea.fromMap(data, doc.id);
      }).toList();

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
        String name =
            DateFormat("${basename(imageFiles[i].path)}-yyyy-MM-dd-mm-ss")
                .format(DateTime.now());
        Reference imageRef =
            _firebaseStorage.ref().child('post_images/$name.jpg');
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

  Future<void> plusMinuseCommentsNumber(List<String> posts, int number) async {
    for (var post in posts) {
      await _firestore
          .collection('posts')
          .doc(post)
          .update(<String, dynamic>{"comments": FieldValue.increment(number)});
    }
  }

  // Send New Post
  Future<void> sendNewPost(
      PostModel post, List<File> imageFiles, List<String> upPosts, GitHubPointsBloc gitHubPointsBloc) async {
    try {
      post.images ??= [];
      post.images?.addAll((await uploadPostImages(imageFiles)));
      await _firestore.collection('posts').add(post.toMap());
          // Dispatch the event to update points
        gitHubPointsBloc.add(NewPostCreatedEvent(post.ideaId!));
      if (upPosts.isNotEmpty) {
        await plusMinuseCommentsNumber(upPosts, 1);
      }
    } catch (e) {
      print('Error updating idea: $e');
      throw Exception('Failed to add post');
    }
  }

  // Update Post
  Future<void> updatePost(
      PostModel post, List<File> imageFiles, List<String> deletedImages) async {
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
  Future<int> deletePost(PostModel post, List<String> upPosts) async {
    try {
      await deletePostImages(post.images ?? []);
      await _firestore.collection('posts').doc(post.id).delete();
      int removedItems = 1;
      var snapshots = await _firestore
          .collection('posts')
          .where("upPosts", arrayContains: post.id!)
          .get();
      for (var document in snapshots.docs) {
        await document.reference.delete();
        removedItems++;
      }

      if (upPosts.isNotEmpty) {
        await plusMinuseCommentsNumber(upPosts, removedItems * -1);
      }
      return removedItems;
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // Fetch all collaborators by idea members
  Future<List<Collaborator>?> fetchIdeaCollaborators(Idea idea) async {
    try {
      List<Collaborator> result = [];
      final snapshot = await _firestore
          .collection('collaborators')
          .where('uid', whereIn: idea.members)
          .get();
      for (var i = 0; i < snapshot.docs.length; i++) {
        print(snapshot.docs[i].data());
        result.add(Collaborator.fromMap(snapshot.docs[i].data()));
      }
      return result;
    } catch (e) {
      throw Exception('Failed to load collaborators: $e');
    }
  }

  // Fetch all posts by ideaId or uid
  Future<List<PostModel>?> fetchPosts(String? ideaId, String? uid) async {
    try {
      List<PostModel> result = [];
      QuerySnapshot<Map<String, dynamic>>? snapshot;
      if (ideaId == null) {
        snapshot = await _firestore
            .collection('posts')
            .where('uid', isEqualTo: uid)
            // .orderBy("date",descending: true)
            .get();
      } else {
        snapshot = await _firestore
            .collection('posts')
            .where('ideaId', isEqualTo: ideaId)
            // .orderBy("date",descending: true)
            .get();
      }
      // snapshot.docs.sort((a, b) => DateTime.parse(b.data()["date"]).compareTo(DateTime.parse(a.data()["date"])),);
      for (var i = 0; i < snapshot.docs.length; i++) {
        result.add(
            PostModel.fromMap(snapshot.docs[i].data(), snapshot.docs[i].id));
      }
      result.sort((a, b) => b.date!.compareTo(a.date!));
      return result;
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  // fetch posts as stream with ideaId for postsTab or with userId for HomePage
  // or with upPost for PostComments
  Stream<List<PostModel>> streamPosts(Idea? idea, String? uid,
      [PostModel? post]) {
    final posts = (post != null
            ? _firestore
                .collection('posts')
                .where('upPost', isEqualTo: post.id)
                .snapshots()
            : idea != null
                ? _firestore
                    .collection('posts')
                    .where('ideaId', isEqualTo: idea.id)
                    .where('upPost', isEqualTo: "0")
                    .snapshots()
                : _firestore
                    .collection('posts')
                    // .where('uid', isEqualTo: uid)
                    .where('upPost', isEqualTo: "0")
                    .snapshots())
        .map((p) => p.docs
            .map((doc) => PostModel.fromMap(doc.data(), doc.id))
            .toList());

    final collaborators = (idea != null
            ? _firestore
                .collection('collaborators')
                .where('uid', whereIn: idea.members)
                .snapshots()
            : _firestore
                .collection('collaborators')
                // .where('uid', isEqualTo: uid)
                .snapshots())
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Collaborator.fromMap(doc.data()))
          .toList();
    });

    final ideas = (idea != null
        ? _firestore
            .collection('ideas')
            .doc(idea.id)
            .snapshots()
            .map((doc) => [Idea.fromMap(doc.data()!, doc.id)])
        : _firestore
            .collection('ideas')
            // .where('members', arrayContains: uid)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => Idea.fromMap(doc.data(), doc.id))
                .toList()));

    // Combine both streams
    return Rx.combineLatest3<List<PostModel>, List<Collaborator>, List<Idea>,
        List<PostModel>>(
      posts,
      collaborators,
      ideas,
      (posts, collaborators, ideas) {
        return posts.map((post) {
          // Set isJoined flag based on join requests
          post.user = collaborators.firstWhere((c) => c.uid == post.uid);
          post.idea = ideas.firstWhere((i) => i.id == post.ideaId);
          return post;
        }).toList();
      },
    );
  }

Stream<List<PostModel>> streamBookmarksPosts(String? uid) {
  final posts = _firestore
      .collection('posts')
      .where('marks', arrayContains: uid)
      .snapshots()
      .map((p) => p.docs
          .map((doc) => PostModel.fromMap(doc.data(), doc.id))
          .toList());

  final collaborators = _firestore
      .collection('collaborators')
      .snapshots() // Fetch all collaborators to ensure that we can map each post
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => Collaborator.fromMap(doc.data()))
        .toList();
  });

  // Combine both streams
  return Rx.combineLatest2<List<PostModel>, List<Collaborator>,
      List<PostModel>>(
    posts,
    collaborators,
    (posts, collaborators) {
      return posts.map((post) {
        // Attempt to find the collaborator based on the post's uid
        post.user = collaborators.firstWhere(
          (c) => c.uid == post.uid,
          orElse: () => Collaborator(
            uid: post.uid ?? 'unknown_uid', // Ensure a non-null uid
            firstName: 'Unknown',
            lastName: 'User',
            profilePhotoUrl: '', // Optional default photo URL
            skills: [], // Default empty skills list
          ),
        );
        return post;
      }).toList();
    },
  );
}

  Future<void> addLikeOrMark(String postId, String field, String uid) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        field: FieldValue.arrayUnion([uid])
      });
    } catch (e) {
      throw Exception('Failed to add $field: $e');
    }
  }

  Future<void> removeLikeOrMark(String postId, String field, String uid) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        field: FieldValue.arrayRemove([uid])
      });
    } catch (e) {
      throw Exception('Failed to remove $field: $e');
    }
  }
  
}
