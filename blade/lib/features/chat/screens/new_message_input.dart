// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../bloc/chat_bloc.dart';
// import '../src/chat_message_model.dart';

// class NewMessageInput extends StatefulWidget {
//   final String roomId;
//   final String userId;

//   NewMessageInput({required this.roomId, required this.userId});

//   @override
//   _NewMessageInputState createState() => _NewMessageInputState();
// }

// class _NewMessageInputState extends State<NewMessageInput> {
//   final TextEditingController _controller = TextEditingController();

//   void _sendMessage() {
//     final content = _controller.text.trim();
//     if (content.isEmpty) return;

//     final message = ChatMessage(
//       senderId: widget.userId,
//       content: content,
//       timestamp: DateTime.now(),
//     );

//     context.read<ChatBloc>().add(SendMessage(roomId: widget.roomId, message: message));
//     _controller.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 hintText: 'Type a message...',
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.send),
//             onPressed: _sendMessage,
//           ),
//         ],
//       ),
//     );
//   }
// }
