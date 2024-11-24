import 'dart:io';

import 'package:blade_app/features/announcement/src/announcement_repository.dart';
import 'package:blade_app/features/profile/bloc/repository/profile_repository.dart';
import 'package:blade_app/features/profile/bloc/repository/project_idea_repository.dart';
import 'package:blade_app/features/profile/bloc/src/collaborator_profile_model.dart';
import 'package:blade_app/features/project_info/screens/post_card_widget.dart';
import 'package:blade_app/features/project_info/screens/posts_tab.dart';
import 'package:blade_app/features/project_info/screens/project_screen.dart';
import 'package:blade_app/utils/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:blade_app/features/project_info/screens/new_post.dart';
import 'package:blade_app/features/project_info/src/post_model.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:timeago_flutter/timeago_flutter.dart' as timeago;

import '../../GithubPoints/bloc/git_hub_points_bloc.dart';
import '../../GithubPoints/bloc/git_hub_points_event.dart';
import '../../announcement/src/announcement_model.dart';

// ignore: must_be_immutable
class PostComments extends StatefulWidget {
  final List<String> upPosts;
  PostModel upPost;
  final CollaboratorProfileModel? profile;
  PostComments(
      {super.key, required this.upPosts, required this.upPost, this.profile});

  @override
  State<PostComments> createState() => _PostCommentsState();
}

class _PostCommentsState extends State<PostComments> {
  late ProjectIdeaRepository projectIdeaRepository;
  late AnnouncementRepository announcementRepository;
  late ProfileRepository profileRepository;
  CollaboratorProfileModel? profile;
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  File? image;
  TextEditingController controller = TextEditingController();
  List<Idea> projects = []; // Define the projects list here

  @override
  void initState() {
    super.initState();
    projectIdeaRepository = ProjectIdeaRepository();
    announcementRepository = AnnouncementRepository();
    profileRepository = ProfileRepository();
    profile = widget.profile;
    timeago.setLocaleMessages('en', MyCustomMessages());
    if (widget.upPost.idea == null) {
      announcementRepository.getIdeaById(widget.upPost.ideaId!).then((idea) {
        widget.upPost.idea = idea;
        setState(() {});
      });
    }
    if (profile == null) {
      profileRepository.getCollaboratorProfile(uid!).then((profile) {
        this.profile = profile;
        setState(() {});
      });
    }
  }

  List<PostModel> threedPosts = [];
  List<PostModel> posts = [];
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // return FutureBuilder<List<PostModel>>(
    // future: _fetchPostModels(),
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[990] : TColors.white,
      appBar: AppBar(
        title: const Text("Post"),
        actions: (widget.upPost.idea != null)
            ? [
                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10)
                //   ),
                //   onPressed: (){
                //   Navigator.of(context).push(MaterialPageRoute(builder: (context){
                //     return ProjectScreen(idea: widget.upPost.idea!, repository: AnnouncementRepository(), canJoin: false, onJoinRequestSent: null);
                //   }));
                // },child: Text("Project Card"),),
                IconButton(
                    tooltip: "Project Card",
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return ProjectScreen(
                            idea: widget.upPost.idea!,
                            repository: AnnouncementRepository(),
                            canJoin: false,
                            onJoinRequestSent: null, 
                            gitHubPointsBloc: BlocProvider.of<GitHubPointsBloc>(context), 
                            );
                      }));
                    },
                    icon: const Icon(Icons.open_in_new))
              ]
            : null,
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: projectIdeaRepository.streamPosts(null, uid, widget.upPost),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            threedPosts = snapshot.data!.where((post) {
              return (widget.upPost.idea?.members ?? [])
                      .contains(post.uid) && // if the user is member in project
                  widget.upPosts.length ==
                      1; // if this screen is the first screen opened after HoemPage or postTab
            }).toList();

            posts = snapshot.data!.where((post) {
              return !(widget.upPost.idea?.members ?? [])
                  .contains(post.uid); // if the user is not member in project
            }).toList();
            posts.sort((a, b) => a.date!.compareTo(b.date!));
            threedPosts.sort((a, b) => a.date!.compareTo(b.date!));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      PostWidget(
                          fromHome: true,
                          refersh: (post) => setState(() {
                                widget.upPost.likes = post.likes;
                                widget.upPost.marks = post.marks;
                              }),
                          projectRepository: projectIdeaRepository,
                          uid: uid,
                          isStaticPost: true,
                          upPosts: const [],
                          withLine: threedPosts.isNotEmpty,
                          post: widget.upPost,
                          isDarkMode: isDarkMode,
                          isPostOwner: widget.upPost.uid == uid,
                          onEditPost: () async =>
                              await onEditPost(widget.upPost),
                          onDeletePost: () async =>
                              await onDeletePost(widget.upPost)),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Center(child: CircularProgressIndicator())
                      else if (!snapshot.hasData || snapshot.data!.isEmpty)
                        const Center(child: Text('No Comments found.')),
                      ListView.separated(
                        primary: false,
                        shrinkWrap: true,
                        itemCount: threedPosts.length,
                        itemBuilder: (context, index) {
                          final post = threedPosts[index];

                          final isPostOwner = post.uid == uid;

                          return Container(
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey[990]
                                    : TColors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: isDarkMode
                                    ? null
                                    : Border.all(
                                        color: const Color.fromARGB(
                                            255, 238, 238, 238)),
                              ),
                              child: PostWidget(
                                fromHome: false,
                                projectRepository: projectIdeaRepository,
                                uid: uid,
                                upPosts: widget.upPosts,
                                withLine: index != threedPosts.length - 1,
                                onNaviagte: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PostComments(
                                                upPosts: [post.id!],
                                                upPost: post,
                                                profile: profile,
                                              )));
                                },
                                onEditPost: () async => await onEditPost(post),
                                onDeletePost: () async =>
                                    await onDeletePost(post),
                                post: post,
                                isDarkMode: isDarkMode,
                                isPostOwner: isPostOwner,
                              ));
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox();
                        },
                      ),
                      ListView.separated(
                        primary: false,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16.0),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];

                          final isPostOwner = post.uid == uid;

                          return Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey[990]
                                    : TColors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: isDarkMode
                                    ? null
                                    : Border.all(
                                        color: const Color.fromARGB(
                                            255, 238, 238, 238)),
                              ),
                              child: PostWidget(
                                fromHome: false,
                                projectRepository: projectIdeaRepository,
                                uid: uid,
                                upPosts: const [],
                                withLine: false,
                                onNaviagte: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PostComments(
                                                upPosts: [post.id!],
                                                upPost: post,
                                                profile: profile,
                                              )));
                                },
                                onEditPost: () async => await onEditPost(post),
                                onDeletePost: () async =>
                                    await onDeletePost(post),
                                post: post,
                                isDarkMode: isDarkMode,
                                isPostOwner: isPostOwner,
                              ));
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 15,
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
              ReplayWidget(
                  controller: controller,
                  image: image,
                  profile: profile,
                  onPressed: (image, message) async =>
                      onSendPost(image, message)),
            ],
          );
        },
      ),
    );
  }

  Future<void> _fetchProjects() async {
    try {
      // Replace "currentUserId" with the actual user ID if available
      projects = await announcementRepository.fetchIdeas("currentUserId");
      setState(() {}); // Update the UI with fetched projects
    } catch (e) {
      print("Error fetching projects: $e");
    }
  }

onSendPost(File? image, String message, [List<PostModel>? posts]) async {
  if (widget.upPost.idea?.id == null) {
    print("Error: ideaId is null.");
    return; // Handle this scenario gracefully
  }

  await projectIdeaRepository.sendNewPost(
    PostModel(
      ideaId: widget.upPost.idea?.id, // Set ideaId explicitly
      upPost: widget.upPost.id,
      upPosts: widget.upPosts,
      uid: uid,
      messgae: message,
    ),
    image == null ? [] : [image], // Second argument
    widget.upPosts, // Third argument
    BlocProvider.of<GitHubPointsBloc>(context), // Fourth argument
  );

  setState(() {
    widget.upPost.comments = widget.upPost.comments! + 1;
    controller.text = "";
    image = null;
  });
}

  onEditPost(PostModel post) async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NewPost(
                post: post,
              )),
    );
    if (res != null && res == "DONE") {
      // setState(() {});
      showSnakbar(
          icon: Icons.check,
          color: TColors.success,
          title: 'Post updated Succesfully.');
    }
  }

  onDeletePost(PostModel post) {
    showDialog(
        context: context,
        builder: (context) {
          return DeleteDialog(onPressed: () async {
            Navigator.pop(context);
            int count =
                await projectIdeaRepository.deletePost(post, widget.upPosts,BlocProvider.of<GitHubPointsBloc>(context));
            widget.upPost.comments = widget.upPost.comments! - count;
            setState(() {});
            // setState(() {});
            showSnakbar(
                icon: Icons.check,
                color: TColors.success,
                title: 'Post deleted successfully.');
          });
        });
  }

  showSnakbar(
      {required IconData icon, required Color color, required String title}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color, // Success background color
        behavior: SnackBarBehavior.floating,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon, // Success icon
              color: Colors.white,
            ),
            const SizedBox(width: 8), // Space between icon and text
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class ReplayWidget extends StatefulWidget {
  final CollaboratorProfileModel? profile;
  final Function(File?, String) onPressed;
  File? image;
  TextEditingController controller;
  ReplayWidget({
    Key? key,
    this.profile,
    required this.onPressed,
    required this.image,
    required this.controller,
  }) : super(key: key);

  @override
  State<ReplayWidget> createState() => _ReplayWidgetState();
}

class _ReplayWidgetState extends State<ReplayWidget> {
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        widget.image = File(pickedFile.path);
      });
    }
  }

  bool isPress = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Divider(
            height: 0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: widget.profile?.profilePhotoUrl != null &&
                          widget.profile!.profilePhotoUrl!.isNotEmpty
                      ? NetworkImage(widget.profile!.profilePhotoUrl!)
                      : const AssetImage('assets/images/content/user.png')
                          as ImageProvider,
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                    child: TextField(
                  maxLines: 3,
                  minLines: 1,
                  maxLength: 500,
                  buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          required maxLength}) =>
                      const SizedBox(),
                  controller: widget.controller,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: InputDecoration(
                      hintText: "Post your reply",
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      enabledBorder:
                          const OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          const OutlineInputBorder(borderSide: BorderSide.none),
                      suffixIconConstraints:
                          const BoxConstraints(maxHeight: 80, maxWidth: 80),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Stack(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: widget.image == null
                                    ? IconButton(
                                        onPressed: pickImage,
                                        icon: const Icon(
                                          Icons.image_outlined,
                                        ))
                                    : Image.file(
                                        widget.image!,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const SizedBox(),
                                      )),
                            if (widget.image != null)
                              Positioned(
                                  top: -10,
                                  left: -10,
                                  child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          widget.image = null;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      ))),
                          ],
                        ),
                      )),
                )),
                const SizedBox(
                  width: 5,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 10)),
                    onPressed: () async {
                      if (widget.image == null &&
                          widget.controller.text.trim() == "") {
                        widget.controller.text = "";
                        return;
                      }
                      setState(() {
                        isPress = true;
                      });
                      await widget.onPressed(
                          widget.image, widget.controller.text);
                      try {
                        setState(() {
                          isPress = false;
                        });
                      } catch (e) {}
                    },
                    child: isPress
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : const Text("Reply"))
              ],
            ),
            // const Divider(),
          )
        ],
      ),
    );
  }
}
