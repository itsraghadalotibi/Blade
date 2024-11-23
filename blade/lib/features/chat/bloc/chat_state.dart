import '../src/chat_message_model.dart';
import '../src/chat_room_model.dart';


abstract class ChatFeatureState {}

class ChatLoading extends ChatFeatureState {}

class ChatRoomsLoaded extends ChatFeatureState {
  final List<ChatRoom> chatRooms;

  ChatRoomsLoaded(this.chatRooms);
}

class ChatMessagesLoaded extends ChatFeatureState {
  final Stream<List<ChatMessage>> messages;

  ChatMessagesLoaded({required this.messages});
}

class ChatError extends ChatFeatureState {
  final String error;

  ChatError(this.error);
}
