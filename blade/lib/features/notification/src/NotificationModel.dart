import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool read;
  final String? status;
  final String? userId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.read = false,
    this.status,
    this.userId,
  });

  // Factory method to create an instance of NotificationModel from Firebase data
  factory NotificationModel.fromMap(
      Map<String, dynamic> data, String documentId) {
    return NotificationModel(
      id: documentId,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      read: data['read'] ?? false,
      status: data['status'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  // Method to convert NotificationModel instance to a map for saving to Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'read': read,
      'status': status,
      'userId': userId,
    };
  }
}
