// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:blade_app/features/announcement/src/announcement_repository.dart';
import 'package:blade_app/features/profile/bloc/repository/project_idea_repository.dart';
import 'package:blade_app/features/profile/bloc/screens/collaborator_profile_screen.dart';
import 'package:blade_app/features/project_info/screens/project_screen.dart';
import 'package:blade_app/features/project_info/src/post_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago_flutter/timeago_flutter.dart' as timeago;

class PostWidget extends StatefulWidget {
  final PostModel post;
  final ProjectIdeaRepository projectRepository;
  final List<String> upPosts;
  final bool isDarkMode;
  final bool isPostOwner;
  final bool withLine;
  final bool isStaticPost;
  final bool fromHome;
  final String? uid;
  final Function()? onNaviagte;
  final Function() onEditPost;
  final Function() onDeletePost;
  final Function(PostModel)? refersh;
  const PostWidget(
      {super.key,
      required this.post,
      required this.isDarkMode,
      required this.isPostOwner,
      required this.fromHome,
      required this.onEditPost,
      required this.onDeletePost,
      required this.withLine,
      required this.upPosts,
      required this.uid,
      this.refersh,
      this.onNaviagte,
      this.isStaticPost = false, 
      required this.projectRepository});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isPress = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CollaboratorProfileScreen(
                          userId: widget.post.user!.uid,
                          showBackButton: true,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: widget.post.user?.profilePhotoUrl != null &&
                            widget.post.user!.profilePhotoUrl.isNotEmpty
                        ? NetworkImage(widget.post.user!.profilePhotoUrl)
                        : const AssetImage('assets/images/content/user.png')
                            as ImageProvider,
                  ),
                ),
                if (widget.withLine)
                  Expanded(
                      child: Container(
                    width: 2,
                    color: widget.isDarkMode ?  Colors.white : Colors.black,
                  ))
              ],
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: GestureDetector(
                onTap: widget.onNaviagte,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.post.user?.firstName ?? ""} ${widget.post.user?.lastName ?? ""}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: widget.isDarkMode ? Colors.white : Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        // if(!isStaticPost)
                        timeago.Timeago(
                          builder: (context, text) {
                            return Tooltip(
                                message: DateFormat("yyyy-MM-dd hh:mm a")
                                    .format(widget.post.date!),
                                child: Text(text));
                          },
                          date: widget.post.date!,
                        ),
                      ],
                    ),
                    // const SizedBox(height: 8,),
                    Text(
                      widget.post.messgae ?? "",
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                    if (widget.post.images!.isNotEmpty) ...[
                      const SizedBox(
                        height: 10,
                      ),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(widget.post.images!.first)),
                    ],
                    const SizedBox(
                      height: 5,
                    ),
                    // if(widget.fromHome && widget.post.upPost == "0" && widget.post.idea != null)
                    // SizedBox(
                    //   height: 80,
                    //   child: Card(
                    //     elevation: 5,
                    //     color: widget.isDarkMode ? Colors.black  : Colors.white,
                    //     child: ListTile(
                    //       trailing: IconButton(onPressed: (){
                    //         Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    //           return ProjectScreen(idea: widget.post.idea!, repository: AnnouncementRepository(), canJoin: false, onJoinRequestSent: null);
                    //         }));
                    //       }, icon: const Icon(Icons.open_in_new)),
                    //       title: Text("${widget.post.idea?.title}"),
                    //       subtitle: Text("${widget.post.idea?.description}",
                    //       overflow: TextOverflow.ellipsis,
                    //       maxLines: 2,),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () async{
                                    if(!isPress){
                                      isPress = true;
                                      PostModel copyPost = widget.post.copyWith();
                                      if(widget.post.likes!.contains(widget.uid)){
                                        await widget.projectRepository.removeLikeOrMark(widget.post.id!, "likes", widget.uid!);
                                        copyPost.likes?.removeWhere((l)=>l==widget.uid);
                                      }else{
                                        await widget.projectRepository.addLikeOrMark(widget.post.id!, "likes", widget.uid!);
                                        widget.post.likes!.add(widget.uid!);
                                      }
                                      widget.refersh?.call(copyPost);
                                      isPress = false;
                                    }
                                  },
                                  icon:  Icon(
                                    widget.post.likes!.contains(widget.uid) ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                    color: widget.post.likes!.contains(widget.uid) ? Colors.red : null,
                                  )),
                              if (widget.post.likes?.isNotEmpty ?? false)
                                Text("${widget.post.likes?.length}"),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: ()=>widget.onNaviagte?.call(),
                                  icon: const Icon(CupertinoIcons.text_bubble)),
                              if ((widget.post.comments ?? 0) > 0)
                                Text("${widget.post.comments}"),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () async{
                                    if(!isPress){
                                      isPress = true;
                                      PostModel copyPost = widget.post.copyWith();
                                      if(widget.post.marks!.contains(widget.uid)){
                                        await widget.projectRepository.removeLikeOrMark(widget.post.id!, "marks", widget.uid!);
                                        copyPost.marks?.removeWhere((l)=>l==widget.uid);
                                      }else{
                                        await widget.projectRepository.addLikeOrMark(widget.post.id!, "marks", widget.uid!);
                                        widget.post.marks!.add(widget.uid!);
                                      }
                                      widget.refersh?.call(copyPost);
                                      isPress = false;
                                    }
                                  },
                                  icon: Icon(
                                    widget.post.marks!.contains(widget.uid) ? Icons.bookmark : Icons.bookmark_outline,
                                    color: widget.post.marks!.contains(widget.uid) ? Colors.blue : null,
                                    )),
                              if (widget.post.marks?.isNotEmpty ?? false)
                                Text("${widget.post.marks?.length}"),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            if (widget.isPostOwner)
              PopupMenuButton(
                // icon: Icon(Icons.more_horiz),
                onSelected: (v) async {
                  if (v == 0) {
                    await widget.onEditPost();
                  }
                  if (v == 1) {
                    await widget.onDeletePost();
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Edit',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
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
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                          )
                        ],
                      ),
                    ),
                  ];
                },
              )
          ],
        ),
      ),
    );
  }
}
