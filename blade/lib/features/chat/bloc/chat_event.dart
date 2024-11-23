import 'package:blade_app/features/chat/src/chat_message_model.dart';

import '../src/chat_room_model.dart';

abstract class ChatEvent {}

class LoadChatRooms extends ChatEvent {
  final String userId;

  LoadChatRooms(this.userId);
}

class LoadMessages extends ChatEvent {
  final String chatRoomId;

  LoadMessages(this.chatRoomId);
}

class SendMessage extends ChatEvent {
  final String chatRoomId;
  final ChatMessage message;

  SendMessage(this.chatRoomId, this.message);
}

class MarkMessagesAsRead extends ChatEvent {
  final String chatRoomId;
  final String userId;

  MarkMessagesAsRead(this.chatRoomId, this.userId);
}
class ChatRoomsUpdated extends ChatEvent {
  final List<ChatRoom> chatRooms;

  ChatRoomsUpdated(this.chatRooms);
}