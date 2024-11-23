import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../widgets/message_bubble.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../src/chat_message_model.dart';
import '../src/chat_repository.dart';
import 'package:image/image.dart' as img; // For image conversion
import 'package:path_provider/path_provider.dart'; // To get temporary directory

class ChatRoomScreen extends StatefulWidget {
  final String chatRoomId;
  final String chatRoomName;
  final String userId;

  const ChatRoomScreen({
    Key? key,
    required this.chatRoomId,
    required this.chatRoomName,
    required this.userId,
  }) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isButtonEnabled = false;
  File? _selectedImage;
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _isButtonEnabled = _messageController.text.trim().isNotEmpty ||
            _selectedImage != null ||
            _selectedFile != null;
      });
    });

    // Mark messages as read when the screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ChatBloc>()
          .add(MarkMessagesAsRead(widget.chatRoomId, widget.userId));
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose(); // Dispose the controller
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty ||
        _selectedImage != null ||
        _selectedFile != null) {
      String? imageUrl;
      String? fileUrl;

      try {
        // Upload image if selected
        if (_selectedImage != null) {
          String fileName = _selectedImage!.path.split('/').last;
          final storageRef = FirebaseStorage.instance.ref().child(
              'chat_images/${DateTime.now().millisecondsSinceEpoch}_$fileName');
          final uploadTask = storageRef.putFile(
            _selectedImage!,
            SettableMetadata(contentType: 'image/jpeg'), // Set content type
          );
          final snapshot = await uploadTask.whenComplete(() {});
          imageUrl = await snapshot.ref.getDownloadURL();
          print('Image URL: $imageUrl');
        }

        // Upload file if selected
        if (_selectedFile != null) {
          String originalFileName = _selectedFile!.path.split('/').last;
          String? contentType = _getContentType(originalFileName);

          final storageRef = FirebaseStorage.instance.ref().child(
              'chat_files/$originalFileName'); // Use the original file name

          final uploadTask = storageRef.putFile(
            _selectedFile!,
            SettableMetadata(contentType: contentType),
          );
          final snapshot = await uploadTask.whenComplete(() {});
          fileUrl = await snapshot.ref.getDownloadURL();
          print('File URL: $fileUrl');
        }

        final message = ChatMessage(
          id: '', // Firebase will auto-generate this if using Firestore
          senderId: widget.userId,
          text: _messageController.text.trim(),
          imageUrl: imageUrl,
          fileUrl: fileUrl,
          timestamp: DateTime.now(),
          readBy: [],
        );

        // Send the message
        context.read<ChatBloc>().add(SendMessage(widget.chatRoomId, message));

        // Reset the inputs
        _messageController.clear();
        setState(() {
          _selectedImage = null;
          _selectedFile = null;
          _isButtonEnabled = false;
        });

        // Scroll to bottom after sending the message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } catch (e) {
        print('Error in _sendMessage: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Check if the image is HEIC
      if (pickedFile.path.toLowerCase().endsWith('.heic')) {
        try {
          // Convert to JPEG
          final bytes = await pickedFile.readAsBytes();
          final image = img.decodeImage(bytes);
          if (image != null) {
            final jpgBytes = img.encodeJpg(image, quality: 80);
            final tempDir = await getTemporaryDirectory();
            final jpgFile = File('${tempDir.path}/temp_image.jpg');
            await jpgFile.writeAsBytes(jpgBytes);
            imageFile = jpgFile;
          } else {
            throw Exception('Failed to decode HEIC image.');
          }
        } catch (e) {
          print('Error converting HEIC to JPEG: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to process image. Please select a different image.')),
          );
          return;
        }
      }

      setState(() {
        _selectedImage = imageFile;
        _isButtonEnabled = true;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _isButtonEnabled = true;
      });
    }
  }

  String _formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('EEE, MMM d, yyyy').format(date);
    }
  }

  String? _getContentType(String fileName) {
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return 'application/pdf';
    } else if (fileName.toLowerCase().endsWith('.doc') ||
        fileName.toLowerCase().endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    } else if (fileName.toLowerCase().endsWith('.ppt') ||
        fileName.toLowerCase().endsWith('.pptx')) {
      return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    } else if (fileName.toLowerCase().endsWith('.xls') ||
        fileName.toLowerCase().endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    } else if (fileName.toLowerCase().endsWith('.txt')) {
      return 'text/plain';
    } else if (fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (fileName.toLowerCase().endsWith('.png')) {
      return 'image/png';
    } else {
      return 'application/octet-stream'; // Default binary type
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(chatRepository: context.read())
        ..add(LoadMessages(widget.chatRoomId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.chatRoomName),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatFeatureState>(
                builder: (context, state) {
                  if (state is ChatMessagesLoaded) {
                    return StreamBuilder<List<ChatMessage>>(
                      stream: state.messages,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final messages = snapshot.data!;
                        if (messages.isEmpty) {
                          return const Center(child: Text("No messages yet."));
                        }

                        // Build messageWidgets...
                        List<Widget> messageWidgets = [];
                        String? lastMessageDate;

                        for (int i = 0; i < messages.length; i++) {
                          final message = messages[i];
                          final messageDate = DateFormat('yyyy-MM-dd')
                              .format(message.timestamp);

                          if (lastMessageDate != messageDate) {
                            // Add date separator
                            messageWidgets.add(
                              Center(
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _formatDateSeparator(message.timestamp),
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                            lastMessageDate = messageDate;
                          }

                          // Add message bubble
                          messageWidgets.add(
                            MessageBubble(
                              message: message,
                              isOwnMessage: message.senderId == widget.userId,
                            ),
                          );
                        }

                        // Scroll to bottom after frame is built
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.jumpTo(
                                _scrollController.position.maxScrollExtent);
                          }
                        });

                        return ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          children: messageWidgets,
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    Image.file(
                      _selectedImage!,
                      height: 100,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImage = null;
                            _isButtonEnabled =
                                _messageController.text.trim().isNotEmpty ||
                                    _selectedFile != null;
                          });
                        },
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child:
                              Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_selectedFile != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.insert_drive_file, color: Colors.grey),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              _selectedFile!.path.split('/').last,
                              style: const TextStyle(color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFile = null;
                            _isButtonEnabled =
                                _messageController.text.trim().isNotEmpty ||
                                    _selectedImage != null;
                          });
                        },
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child:
                              Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _pickImage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _pickFile,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _isButtonEnabled ? _sendMessage : null,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
