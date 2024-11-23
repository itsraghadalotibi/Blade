import 'package:blade_app/features/project_info/screens/posts_tab.dart';
import 'package:flutter/material.dart';

class PostBookmarks extends StatelessWidget {
  const PostBookmarks({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Bookmarks"),
      ),
      body: const PostsTab(
        canSendComment: true,
        fromHome: true,
        getBookMarks: true,)
    );
  }
}