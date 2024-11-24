import 'package:blade_app/features/project_info/screens/posts_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../GithubPoints/bloc/git_hub_points_bloc.dart';

class PostBookmarks extends StatelessWidget {
  const PostBookmarks({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Bookmarks"),
      ),
      body: PostsTab(
        canSendComment: true,
        fromHome: true,
        getBookMarks: true,
        gitHubPointsBloc: BlocProvider.of<GitHubPointsBloc>(context),
        )
    );
  }
}