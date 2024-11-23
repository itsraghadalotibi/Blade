import 'package:cloud_firestore/cloud_firestore.dart';
class ChatRoom {
  final String id;
  final String name;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, dynamic> unreadCounts;
  final List<String> members;

  ChatRoom({
    required this.id,
    required this.name,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCounts,
    required this.members,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      name: json['name'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
      unreadCounts: _convertUnreadCounts(json['unreadCounts']),
      members: List<String>.from(json['members'] ?? []),
    );
  }

  // From Firestore
  factory ChatRoom.fromFirestore(Map<String, dynamic> json, String documentId) {
    return ChatRoom(
      id: documentId,
      name: json['name'] ?? 'Unnamed Room',
      lastMessage: json['lastMessage'],
      lastMessageTime: (json['lastMessageTime'] as Timestamp?)?.toDate(),
      unreadCounts: _convertUnreadCounts(json['unreadCounts']),
      members: List<String>.from(json['members'] ?? []),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'unreadCounts': _convertUnreadCountsBack(unreadCounts),
      'members': members,
    };
  }

  // Helper: Convert Firestore map to a Dart map
  static Map<String, dynamic> _convertUnreadCounts(dynamic unreadCounts) {
    if (unreadCounts is Map<String, dynamic>) {
      return unreadCounts;
    }
    return {};
  }

  // Helper: Convert Dart map back to Firestore map
  static Map<String, dynamic> _convertUnreadCountsBack(
      Map<String, dynamic> unreadCounts) {
    return unreadCounts;
  }
}