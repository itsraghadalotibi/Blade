import 'dart:async';

import 'package:bloc/bloc.dart';
import '../src/chat_repository.dart';
import '../src/chat_room_model.dart';
import 'chat_event.dart';
import 'chat_state.dart';
class ChatBloc extends Bloc<ChatEvent, ChatFeatureState> {
  final ChatRepository chatRepository;
  StreamSubscription<List<ChatRoom>>? _chatRoomsSubscription;

  ChatBloc({required this.chatRepository}) : super(ChatLoading()) {
    // Handle loading chat rooms
    on<LoadChatRooms>((event, emit) async {
      emit(ChatLoading());
      try {
        await _chatRoomsSubscription?.cancel(); // Cancel any previous subscription

        _chatRoomsSubscription = chatRepository
            .getChatRoomsStream(event.userId)
            .listen((chatRooms) {
          add(ChatRoomsUpdated(chatRooms));
        });
      } catch (e) {
        emit(ChatError('Failed to load chat rooms.'));
      }
    });

    // Handle updated chat rooms
    on<ChatRoomsUpdated>((event, emit) {
      emit(ChatRoomsLoaded(event.chatRooms));
    });
    // Handle loading messages
    on<LoadMessages>((event, emit) async {
      try {
        final messagesStream = chatRepository.getMessagesStream(event.chatRoomId);
        emit(ChatMessagesLoaded(messages: messagesStream));
      } catch (e) {
        emit(ChatError("Failed to load messages: $e"));
      }
    });

    // Handle sending a message
    on<SendMessage>((event, emit) async {
      try {
        await chatRepository.sendMessage(event.chatRoomId, event.message);
      } catch (e) {
        emit(ChatError('Failed to send message.'));
      }
    });

    // Handle marking messages as read
    on<MarkMessagesAsRead>((event, emit) async {
      try {
        await chatRepository.markMessagesAsRead(event.chatRoomId, event.userId);
      } catch (e) {
        emit(ChatError('Failed to mark messages as read.'));
      }
    });
  }
  @override
  Future<void> close() {
    _chatRoomsSubscription?.cancel();
    return super.close();
  }
}
