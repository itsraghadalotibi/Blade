import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_message_model.dart';
import 'chat_room_model.dart';
class ChatRepository {
  final FirebaseFirestore firestore;

  ChatRepository({required this.firestore});

  Future<List<ChatRoom>> getChatRooms(String userId) async {
    final querySnapshot = await firestore
        .collection('chatRooms')
        .where('members', arrayContains: userId)
        .get();

    return querySnapshot.docs
        .map((doc) => ChatRoom.fromFirestore(doc.data(), doc.id))
        .toList();
  }
  Stream<List<ChatRoom>> getChatRoomsStream(String userId) {
    return firestore
        .collection('chatRooms')
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return ChatRoom.fromFirestore(doc.data(), doc.id);
            }).toList());
  }

  Stream<List<ChatMessage>> getChatMessages(String chatRoomId) {
    return firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc.data(), doc.id)).toList());
  }
  Stream<List<ChatMessage>> getMessagesStream(String chatRoomId) {
    return firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false) 
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return ChatMessage.fromFirestore(doc.data(), doc.id);
            }).toList());
  }

  Future<void> sendMessage(String chatRoomId, ChatMessage message) async {
    final chatRoomRef = firestore.collection('chatRooms').doc(chatRoomId);
    final messageRef = chatRoomRef.collection('messages').doc();

    // Start a batch
    final batch = firestore.batch();

    // Add the message
    batch.set(messageRef, message.toFirestore());

    // Update the chatRoom's lastMessage and lastMessageTime
    batch.update(chatRoomRef, {
      'lastMessage': message.text.isNotEmpty
          ? message.text
          : (message.imageUrl != null ? 'Image' : 'File'),
      'lastMessageTime': Timestamp.fromDate(message.timestamp),

    });

    // Update the unreadCounts for other members
    final chatRoomDoc = await chatRoomRef.get();
    final chatRoomData = chatRoomDoc.data();

    if (chatRoomData != null) {
      final Map<String, dynamic> unreadCounts =
          Map<String, dynamic>.from(chatRoomData['unreadCounts'] ?? {});

      final List<dynamic> members = chatRoomData['members'] ?? [];

      for (String memberId in members) {
        if (memberId != message.senderId) {
          // Increment unread count for this member
          unreadCounts[memberId] = (unreadCounts[memberId] ?? 0) + 1;
        }
      }

      // Update unreadCounts in chatRoom
      batch.update(chatRoomRef, {'unreadCounts': unreadCounts});
    }

    // Commit the batch
    await batch.commit();
  }

  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    final chatRoomRef = firestore.collection('chatRooms').doc(chatRoomId);

    final messagesSnapshot = await chatRoomRef.collection('messages').get();

    final batch = firestore.batch();

    for (var doc in messagesSnapshot.docs) {
      final data = doc.data();
      final List<dynamic> readBy = data['readBy'] ?? [];
      if (!readBy.contains(userId)) {
        // Update 'readBy' array to include the userId
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([userId])
        });
      }
    }

    // Reset unread count for the user in chatRoom's 'unreadCounts' field
    batch.update(chatRoomRef, {
      'unreadCounts.$userId': 0,
    });

    // Commit the batch
    await batch.commit();
  }
}