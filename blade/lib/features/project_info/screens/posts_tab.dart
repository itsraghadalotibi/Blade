// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:blade_app/features/profile/bloc/repository/project_idea_repository.dart';
import 'package:blade_app/features/project_info/screens/new_post.dart';
import 'package:blade_app/features/project_info/screens/post_card_widget.dart';
import 'package:blade_app/features/project_info/screens/post_comments.dart';
import 'package:blade_app/features/project_info/src/post_model.dart';
import 'package:blade_app/utils/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago_flutter/timeago_flutter.dart' as timeago;

import '../../GithubPoints/bloc/git_hub_points_bloc.dart';
import '../../announcement/src/announcement_repository.dart';

class PostsTab extends StatefulWidget {
  final Idea? idea;
  final bool getBookMarks;
  final bool fromHome;
  final bool scrollable;
  final GitHubPointsBloc gitHubPointsBloc; 
    final bool canSendComment;



  const PostsTab({super.key,
   this.idea,
   this.getBookMarks = false, 
   required this.fromHome, 
   this.scrollable = true,
   required this.gitHubPointsBloc, 
   required this.canSendComment
   });

  @override
  State<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab> {
  late ProjectIdeaRepository projectIdeaRepository;
  late AnnouncementRepository repository;
  @override
  void initState() {
    super.initState();
    projectIdeaRepository = ProjectIdeaRepository();
    repository = AnnouncementRepository();
    timeago.setLocaleMessages('en', MyCustomMessages());
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
  return const Center(child: Text('User not logged in.'));
}


    // return FutureBuilder<List<PostModel>>(
      // future: _fetchPostModels(),
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: StreamBuilder<List<PostModel>>(
    stream: widget.getBookMarks
    ? projectIdeaRepository.streamBookmarksPosts(uid) ?? Stream.empty()
    : projectIdeaRepository.streamPosts(widget.idea, uid) ?? Stream.empty(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Posts found.'));
          }
      
          final posts = snapshot.data!;
          posts.sort((a, b) => b.date!.compareTo(a.date!));    
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              if (post == null) {
          return const SizedBox(); // Safely skip null posts
        }

              final isPostOwner = post.uid == uid;
      
              return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[990] : TColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: isDarkMode
                        ? null
                        : Border.all(
                            color: const Color.fromARGB(255, 238, 238, 238)),
                  ),
                  child: PostWidget(
                    fromHome: widget.fromHome,
                    projectRepository: projectIdeaRepository,
                    uid: uid,
                    upPosts: const [],
                    withLine: false,
                    onNaviagte: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>PostComments(upPosts: [post.id!], upPost: post,canSendComment: widget.canSendComment,)));
                    },
                    onEditPost: ()async{
                      var res = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewPost(post: post,)),
                      );
                      if(res != null && res == "DONE"){
                        // setState(() {});
                        showSnakbar( icon: Icons.check, color: TColors.success, title: 'Post updated Succesfully.');
                      }
                    },
                    onDeletePost: (){
                      showDialog(
                        context: context, 
                        builder: (context){
                          return DeleteDialog(onPressed: ()async{
                            Navigator.pop(context);
                           await projectIdeaRepository.deletePost(post, [], widget.gitHubPointsBloc); // Pass the bloc
                            // setState(() {});
                            showSnakbar( icon: Icons.check, color: TColors.success, title: 'Post deleted successfully.');
                          });
                        }
                      );
                    },
                    post: post, isDarkMode: isDarkMode, isPostOwner: isPostOwner,));
            },
            separatorBuilder: (context, index) {
              return const Divider(height: 15,);
            },
          );
        },
      ),
    );
  }
  showSnakbar(
    {
    required IconData icon,
    required Color color,
    required String title}) {
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


  // Fetch posts with users
  Future<List<PostModel>> fetchPostModels() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    List<PostModel>? posts = await projectIdeaRepository.fetchPosts(widget.idea?.id,uid);
    List<Collaborator?>? collaborators = [];
    if(widget.idea != null){
      collaborators = await projectIdeaRepository.fetchIdeaCollaborators(widget.idea!);
    }else{
      collaborators.add(await repository.fetchCollaborator(uid!));
    }
  for (var i = 0; i < posts!.length; i++) {
    posts[i].user = collaborators?.firstWhere(
      (c) => c?.uid == posts[i].uid,
      orElse: () => null, // Provide a default if not found
    );
  }
    return posts;
  }
}

class DeleteDialog extends StatefulWidget {
  final Function() onPressed;

  const DeleteDialog({super.key,  required this.onPressed});
  @override
  State<StatefulWidget> createState() => DeleteDialogState();
}

class DeleteDialogState extends State<DeleteDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);


    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: Dialog(
    elevation: 20,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    insetPadding: const EdgeInsets.all(30),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Center(
              child: Text("Are you sure you want to delete the post?",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
            ),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(10),
                    backgroundColor: Colors.transparent
                  ),
                  onPressed:Navigator.of(context).pop, child: const Text("Cancel")),
                const SizedBox(width: 15,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(10),
                    backgroundColor: Colors.red
                  ),
                  onPressed: widget.onPressed, child: const Text("Delete")),
              ],
            )
          ],
        ),
      ),
    ),
          )
    );
  }
}

class MyCustomMessages implements timeago.LookupMessages {
  @override String prefixAgo() => '';
  @override String prefixFromNow() => '';
  @override String suffixAgo() => '';
  @override String suffixFromNow() => '';
  @override String lessThanOneMinute(int seconds) => 'now';
  @override String aboutAMinute(int minutes) => '${minutes}m';
  @override String minutes(int minutes) => '${minutes}m';
  @override String aboutAnHour(int minutes) {
    if(minutes >= 60) {
      return '${minutes ~/ 60}h';
    }
    return '${minutes}m';
  }
  @override String hours(int hours) => '${hours}h';
  @override String aDay(int hours) => '${hours}h';
  @override String days(int days) => '${days}d';
  @override String aboutAMonth(int days) => '${days}d';
  @override String months(int months) => '${months}mo';
  @override String aboutAYear(int year) => '${year}y';
  @override String years(int years) => '${years}y';
  @override String wordSeparator() => ' ';
}