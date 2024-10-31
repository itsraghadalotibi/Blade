// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostModel {
  String? id;
  String? uid;
  Collaborator? user;
  String? ideaId;
  String? title;
  String? messgae;
  DateTime? date;
  List<String>? images;
  PostModel({
    this.uid,
    this.ideaId,
    this.messgae,
    this.title,
    this.date,
    this.id,
    this.images,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'ideaId': ideaId,
      // 'title': title,
      'messgae': messgae,
      'date': (date ?? DateTime.now()).toString(),
      'images':images
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
    );
  }


  PostModel copyWith({
    String? id,
    String? uid,
    Collaborator? user,
    String? ideaId,
    String? title,
    String? messgae,
    DateTime? date,
    List<String>? images,
  }) {
    return PostModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      ideaId: ideaId ?? this.ideaId,
      title: title ?? this.title,
      messgae: messgae ?? this.messgae,
      date: date ?? this.date,
      images: images ?? this.images,
    );
  }
}
