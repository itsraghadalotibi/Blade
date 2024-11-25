// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostModel {
  String? id;
  String? uid;
  Collaborator? user;
  String? ideaId;
  Idea? idea;
  String? title;
  String? messgae;
  DateTime? date;
  List<String>? images;
  List<String>? likes;
  List<String>? marks;
  int? comments;
  String? upPost;
  List<String>? upPosts; // for delte all connected posts
  PostModel({
    this.uid,
    this.ideaId,
    this.idea,
    this.messgae,
    this.title,
    this.date,
    this.id,
    this.images,
    this.upPost,
    this.likes,
    this.marks,
    this.comments,
    this.upPosts,
  });

Map<String, dynamic> toMap(bool forUpdate) {
  return <String, dynamic>{
    'uid': FirebaseAuth.instance.currentUser!.uid,
    'messgae': messgae,
    if(!forUpdate)...{
      'ideaId': ideaId, // Use ideaId directly
      'date': (date ?? DateTime.now()).toString(),
    },
    'images': images,
    'upPost': upPost ?? "0",
    'upPosts': upPosts ?? [],
    'likes': likes ?? [],
    'marks': marks ?? [],
    'comments': comments ?? 0,
  };
}

  factory PostModel.fromMap(Map<String, dynamic> map,String documentId) {
    return PostModel(
      id: documentId,
      uid: map['uid'] != null ? map['uid'] as String : null,
      ideaId: map['ideaId'] != null ? map['ideaId'] as String : null,
      // title: map['title'] != null ? map['title'] as String : null,
      messgae: map['messgae'] != null ? map['messgae'] as String : null,
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      images: List<String>.from(map['images'] ?? []),
      likes: List<String>.from(map['likes'] ?? []),
      marks: List<String>.from(map['marks'] ?? []),
      comments: map['comments'] != null ? map['comments'] as int : null,
      upPosts: List<String>.from(map['upPosts'] ?? []),
      upPost: map['upPost'] != null ? map['upPost'] as String : null,
    );
  }


  PostModel copyWith({
    String? id,
    String? uid,
    Collaborator? user,
    Idea? idea,
    String? title,
    String? messgae,
    DateTime? date,
    List<String>? images,
    String? upPost,
    List<String>? likes,
    List<String>? marks,
    List<String>? upPosts,
    int? comments
  }) {
    return PostModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      idea: idea ?? this.idea,
      title: title ?? this.title,
      messgae: messgae ?? this.messgae,
      date: date ?? this.date,
      images: images ?? this.images,
      upPost: upPost ?? this.upPost,
      upPosts: upPosts ?? this.upPosts,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      marks: marks ?? this.marks,
    );
  }
}
