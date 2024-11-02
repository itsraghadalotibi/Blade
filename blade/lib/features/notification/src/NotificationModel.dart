import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool read;
  final String? status;
  final String? userId;
  final String? projectName; // Add this field

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.read = false,
    this.status,
    this.userId,
    this.projectName,
  });

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
      projectName: data['projectName'] ?? '', // Retrieve project name
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'read': read,
      'status': status,
      'userId': userId,
      'projectName': projectName, // Include project name in map
    };
  }
}
