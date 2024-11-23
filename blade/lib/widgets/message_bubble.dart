import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http; // For downloading files
import 'package:open_filex/open_filex.dart'; // For opening files
import 'package:path_provider/path_provider.dart'; // For temporary directory
import 'package:photo_view/photo_view.dart';
import '../features/chat/src/chat_message_model.dart';
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isOwnMessage;
  final List<String>? members; // List of chat members for group chats
  final List<String>? readBy;  // List of users who have read the message

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isOwnMessage,
    this.members,
    this.readBy,
  }) : super(key: key);

  bool _isImageFile(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    return imageExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }
  
  Future<Map<String, String>> getUserDetails(String userId) async {
    try {
      // Check in the supporters collection
      final userDoc = await FirebaseFirestore.instance
          .collection('supporters')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final firstName = data?['firstName'] ?? '';
        final lastName = data?['lastName'] ?? '';
        final profilePhotoUrl = data?['profilePhotoUrl'] ??
            'https://via.placeholder.com/150'; // Default profile photo

        return {
          'name': '$firstName $lastName'.trim(),
          'profilePhotoUrl': profilePhotoUrl,
        };
      }

      // Check in the collaborators collection
      final collaboratorDoc = await FirebaseFirestore.instance
          .collection('collaborators')
          .doc(userId)
          .get();

      if (collaboratorDoc.exists) {
        final data = collaboratorDoc.data();
        final firstName = data?['firstName'] ?? '';
        final lastName = data?['lastName'] ?? '';
        final profilePhotoUrl = data?['profilePhotoUrl'] ??
            'https://via.placeholder.com/150'; // Default profile photo

        return {
          'name': '$firstName $lastName'.trim(),
          'profilePhotoUrl': profilePhotoUrl,
        };
      }
      if(userId == 'system') {
        return {
        'name' : 'Blade System',
        'profilePhotoUrl' : 'https://firebasestorage.googleapis.com/v0/b/blade-87cf7.appspot.com/o/profile_images%2Flogo-blackBG.png?alt=media&token=e73a5048-facd-44e0-93de-b743ef168599',

      };
      }

      // Default fallback
      return {
        'name': 'Unknown User',
        'profilePhotoUrl': 'https://via.placeholder.com/150',
      };
    } catch (e) {
      print('Error fetching user details: $e');
      return {
        'name': 'Unknown User',
        'profilePhotoUrl': 'https://via.placeholder.com/150',
      };
    }
  }

  // Helper method to extract the file name and extension
  String _getShortFileName(String fileUrl) {
    try {
      Uri uri = Uri.parse(fileUrl);
      String path = uri.path; // e.g., '/v0/b/myapp.appspot.com/o/chat_files%2Fsome_filename.ext'
      // Extract the encoded file path after '/o/'
      int index = path.indexOf('/o/');
      if (index != -1) {
        String encodedFilePath = path.substring(index + 3); // skip '/o/'
        String filePath = Uri.decodeFull(encodedFilePath); // e.g., 'chat_files/some_filename.ext'
        String fileName = filePath.split('/').last; // 'some_filename.ext'
        // Shorten the file name if necessary
        if (fileName.length > 20) {
          String name = fileName.substring(0, 15);
          String extension = fileName.split('.').last;
          fileName = '$name...$extension';
        }
        return fileName;
      } else {
        return 'File';
      }
    } catch (e) {
      print('Error parsing file URL: $e');
      return 'File';
    }
  }

  IconData _getFileIcon(String fileName) {
    String extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'mp4':
      case 'avi':
        return Icons.videocam;
      case 'mp3':
      case 'wav':
        return Icons.audiotrack;
      case 'txt':
        return Icons.note;
      default:
        return Icons.insert_drive_file;
    }
  }

@override
  Widget build(BuildContext context) {
    final bubbleColor = isOwnMessage
        ? Colors.green[400]
        : Colors.grey[200];
    final textColor = isOwnMessage ? Colors.white : Colors.black;

    return FutureBuilder<Map<String, String>>(
      future: getUserDetails(message.senderId),
      builder: (context, snapshot) {
        final senderName = snapshot.data?['name'] ?? 'Loading...';
        final profilePhotoUrl =
            snapshot.data?['profilePhotoUrl'] ?? 'https://via.placeholder.com/150';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Row(
            mainAxisAlignment: isOwnMessage
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isOwnMessage)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(profilePhotoUrl),
                ),
              if (!isOwnMessage) const SizedBox(width: 8),
              Flexible(
                child: IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: isOwnMessage
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (!isOwnMessage)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            senderName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: isOwnMessage
                                ? const Radius.circular(12)
                                : Radius.zero,
                            bottomRight: isOwnMessage
                                ? Radius.zero
                                : const Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 14.0),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message.imageUrl != null)
                               GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ImageViewerScreen(
                                        imageUrl: message.imageUrl!,
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    message.imageUrl!,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Text('Failed to load image'),
                                  ),
                                ),
                              ),
                            if (message.fileUrl != null)
                              GestureDetector(
                                onTap: () async {
                                  try {
                                    // Get temporary directory
                                    final tempDir = await getTemporaryDirectory();
                                    String fileName = _getShortFileName(message.fileUrl!);
                                    final filePath = '${tempDir.path}/$fileName';

                                    // Download the file
                                    final response = await http.get(Uri.parse(message.fileUrl!));
                                    final file = File(filePath);
                                    await file.writeAsBytes(response.bodyBytes);

                                    // Open the file
                                    await OpenFilex.open(filePath);
                                  } catch (e) {
                                    print('Error opening file: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Could not open file')),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  margin: const EdgeInsets.only(top: 8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getFileIcon(message.fileUrl!),
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Text(
                                          _getShortFileName(message.fileUrl!),
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if ((message.text ?? '').isNotEmpty)
                              Text(
                                message.text!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: textColor.withOpacity(0.7),
                                    ),
                                  ),
                                  if (readBy != null &&
                                      readBy!.contains(message.senderId))
                                    const Icon(Icons.done_all,
                                        color: Colors.blue, size: 14),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;

  const ImageViewerScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      // Background color set to black for better image contrast
      backgroundColor: isDarkMode? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode? Colors.black : Colors.white,
        //iconTheme: const IconThemeData(color: Colors.white), // White back button
        elevation: 0,
      ),
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Text(
            'Failed to load image',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}