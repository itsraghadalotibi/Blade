import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';
import '../../../utils/constants/colors.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../src/chat_repository.dart';
import '../src/chat_room_model.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final String userId;

  const ChatListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChatBloc(chatRepository: context.read<ChatRepository>())
            ..add(LoadChatRooms(userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Chats"),
          centerTitle: true,
        ),
        body: BlocBuilder<ChatBloc, ChatFeatureState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChatRoomsLoaded) {
              final chatRooms = state.chatRooms;
              if (chatRooms.isEmpty) {
                return const Center(
                  child: Text(
                    "No chats available.",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                );
              }

              return ListView.builder(
                itemCount: chatRooms.length,
                itemBuilder: (context, index) {
                  final chatRoom = chatRooms[index];
                  final unreadCount = chatRoom.unreadCounts[userId] ?? 0;

                  // Format the time
                  String timeString = '';
                  if (chatRoom.lastMessageTime != null) {
                    final now = DateTime.now();
                    final lastMsgDate = chatRoom.lastMessageTime!;
                    if (now.difference(lastMsgDate).inDays == 0) {
                      // Same day, show time
                      timeString = DateFormat('HH:mm').format(lastMsgDate);
                    } else {
                      // Different day, show date
                      timeString = DateFormat('MMM d').format(lastMsgDate);
                    }
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        chatRoom.name.isNotEmpty
                            ? chatRoom.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: TColors.primary,
                        ),
                      ),
                    ),
                    title: Text(
                      chatRoom.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      chatRoom.lastMessage ?? 'No messages yet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (timeString.isNotEmpty)
                Text(
                  timeString,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              if (unreadCount > 0)
                const SizedBox(height: 4),
              if (unreadCount > 0)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => ChatBloc(
                              chatRepository: context.read<ChatRepository>(),
                            ),
                            child: ChatRoomScreen(
                              chatRoomId: chatRoom.id,
                              chatRoomName: chatRoom.name,
                              userId: userId,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            } else if (state is ChatError) {
              return Center(
                child: Text(
                  state.error,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
