import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostModel {
  String? id;
  String? uid;
  Collaborator? user;
  String? ideaId;
  String? messgae;
  DateTime? date;
  PostModel({
    this.uid,
    this.ideaId,
    this.messgae,
    this.date,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'ideaId': ideaId,
      'messgae': messgae,
      'date': (date ?? DateTime.now()).toString(),
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map,String documentId) {
    return PostModel(
      id: documentId,
      uid: map['uid'] != null ? map['uid'] as String : null,
      ideaId: map['ideaId'] != null ? map['ideaId'] as String : null,
      messgae: map['messgae'] != null ? map['messgae'] as String : null,
      date: map['date'] != null ? DateTime.parse(map['date']) : null
    );
  }

}
