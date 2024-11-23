import 'package:cloud_firestore/cloud_firestore.dart';
class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final String? imageUrl;
  final String? fileUrl;
  final DateTime timestamp;
  final List<String> readBy;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.imageUrl,
    this.fileUrl,
    required this.timestamp,
    required this.readBy,
  });

  factory ChatMessage.fromFirestore(Map<String, dynamic> json, String documentId) {
    return ChatMessage(
      id: documentId,
      senderId: json['senderId'],
      text: json['text'] ?? '',
      imageUrl: json['imageUrl'],
      fileUrl: json['fileUrl'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'timestamp': timestamp,
      'readBy': readBy,
    };
  }
}