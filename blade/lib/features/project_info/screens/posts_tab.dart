// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:blade_app/features/profile/bloc/screens/collaborator_profile_screen.dart';
import 'package:blade_app/features/project_info/src/post_model.dart';
import 'package:blade_app/utils/constants/colors.dart';
import 'package:blade_app/utils/constants/sizes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../announcement/src/announcement_repository.dart';

class PostsTab extends StatefulWidget {
  final Idea? idea;
  final AnnouncementRepository repository;
  final Function(String) showSnakbar;

  const PostsTab({super.key, required this.idea, required this.repository, required this.showSnakbar});

  @override
  State<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab> {
  Future<List<PostModel>>? futrueMembers;
  @override
  void initState() {
    super.initState();
    futrueMembers = _fetchPostModels();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<PostModel>>(
      future: _fetchPostModels(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No Posts found.'));
        }

        final posts = snapshot.data!;

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];

            final isPostOwner = post.uid == FirebaseAuth.instance.currentUser?.uid;

            return Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[850] : TColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: isDarkMode
                      ? null
                      : Border.all(
                          color: const Color.fromARGB(255, 238, 238, 238)),
                ),
                child: PostWidget(
                  onEditPost: ()async{
                    addUpdatePostDialog(context: context, post: post, isDarkMode: isDarkMode,buttonText: "Update", onPressed: (post)async{
                      await widget.repository.updatePost(post);
                      setState(() {});
                      widget.showSnakbar('Post updated successfully.');
                    });
                  },
                  onDeletePost: (){
                    showDialog(
                      context: context, 
                      builder: (context){
                        return DelteeDialog(onPressed: ()async{
                          Navigator.pop(context);
                          await widget.repository.deletePost(post.id!);
                          setState(() {});
                          widget.showSnakbar('Post deleted successfully.');
                        });
                      }
                    );
                  },
                  post: post, isDarkMode: isDarkMode, isPostOwner: isPostOwner,));
          },
          separatorBuilder: (context, index) {
            return const SizedBox(height: 10);
          },
        );
      },
    );
  }

  // Fetch posts with users
  Future<List<PostModel>> _fetchPostModels() async {
    List<PostModel>? posts = await widget.repository.fetchPosts(widget.idea!.id!);
    final collaborators = await widget.repository.fetchIdeaCollaborators(widget.idea!);
    for (var i = 0; i < posts!.length; i++) {
      posts[i].user = collaborators?.firstWhere((c)=>c.uid == posts[i].uid);
    }
    return posts;
  }
}

addUpdatePostDialog({required BuildContext context, required PostModel post,required bool isDarkMode,required Function(PostModel) onPressed,required String buttonText}){
  showDialog(
    context: context, 
    builder: (context){
      return AddUpdateDialog(
        title: buttonText == "Update" ? "Update Post" : "New Post",
        isDarkMode: isDarkMode, post: post, onPressed: onPressed, buttonText: buttonText);
    }
  );
}
class PostWidget extends StatelessWidget {
  final PostModel post;
  final bool isDarkMode;
  final bool isPostOwner;
  final Function() onEditPost;
  final Function() onDeletePost;
  const PostWidget({
    super.key,
    required this.post, required this.isDarkMode, required this.isPostOwner, required this.onEditPost, required this.onDeletePost,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CollaboratorProfileScreen(
                    userId: post.user!.uid,
                    showBackButton: true,
                  ),
                ),
              );
            },
            child: CircleAvatar(
              radius: 30,
              backgroundImage: post.user?.profilePhotoUrl != null &&
                      post.user!.profilePhotoUrl.isNotEmpty
                  ? NetworkImage(post.user!.profilePhotoUrl)
                  : const AssetImage('assets/images/content/user.png')
                      as ImageProvider,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${post.user?.firstName ?? ""} ${post.user?.lastName ?? ""}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5,),
                Text(
                  post.messgae ?? "",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8,),
                Text(
                  DateFormat("yyyy-MM-dd").format(post.date!),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        if(isPostOwner)
          PopupMenuButton(
            onSelected: (v)async{
              if(v==0){
                await onEditPost();
              }
              if(v==1){
                await onDeletePost();
              }
            },
            itemBuilder: (context) {
              return const[
                PopupMenuItem(
                  value: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit',
                        style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.edit)
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delete',
                        style: TextStyle(color: Colors.red,fontSize: 12,fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.delete,color: Colors.red,)
                    ],
                  ),
                ),
              ];
            },
          )
        ],
      ),
    );
  }
}

class AddUpdateDialog extends StatefulWidget {
  final bool isDarkMode;
  final PostModel post;
  final Function(PostModel) onPressed;
  final String buttonText;
  final String title;

  const AddUpdateDialog({super.key, required this.isDarkMode, required this.post, required this.onPressed, required this.buttonText, required this.title});
  @override
  State<StatefulWidget> createState() => AddUpdateDialogState();
}

class AddUpdateDialogState extends State<AddUpdateDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  late TextEditingController textcontroller;
  late String originalMessage;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    textcontroller  = TextEditingController(text: widget.post.messgae);
    originalMessage  = widget.post.messgae!;

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
            Center(
              child: Text(widget.title,style: const TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: textcontroller,
              maxLines: 4,
              onChanged: (v){
                widget.post.messgae = v;
                setState(() {});
              },
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'post',
                hintStyle: TextStyle(
                  color: widget.isDarkMode ? Colors.grey : Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                  borderSide: BorderSide(width: 1, color: widget.isDarkMode ? Colors.white : TColors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                  borderSide: BorderSide(width: 1, color: widget.isDarkMode ? Colors.white : TColors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                  borderSide: const BorderSide(width: 2, color: TColors.borderPrimary),
                ),
                errorStyle: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                backgroundColor: Theme.of(context).primaryColor
              ),
              onPressed: textcontroller.text==originalMessage? Navigator.of(context).pop : ()async{
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.pop(context);
                await widget.onPressed(widget.post);}, child: Text(textcontroller.text==originalMessage?"Close": widget.buttonText))
          ],
        ),
      ),
    ),
          )
    );
  }
}


class DelteeDialog extends StatefulWidget {
  final Function() onPressed;

  const DelteeDialog({super.key,  required this.onPressed});
  @override
  State<StatefulWidget> createState() => DelteeDialogState();
}

class DelteeDialogState extends State<DelteeDialog>
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
