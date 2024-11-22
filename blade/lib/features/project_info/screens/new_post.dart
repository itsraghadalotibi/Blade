import 'dart:io';

import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:blade_app/features/profile/bloc/repository/project_idea_repository.dart';
import 'package:blade_app/features/project_info/src/post_model.dart';
import 'package:blade_app/utils/constants/sizes.dart';
import 'package:blade_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../GithubPoints/bloc/git_hub_points_bloc.dart';

class NewPost extends StatefulWidget {
  final List<Idea>? ideas;
  final PostModel? post;

  const NewPost({Key? key, this.ideas, this.post}) : super(key: key);

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  Idea? selectedIdea;
  late ProjectIdeaRepository projectIdeaRepository;
  final ImagePicker picker = ImagePicker();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController title;
  late TextEditingController caption;

  List<File> imagesFile = [];
  List<String> currentImages = [];
  List<String> deletedImages = [];
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    projectIdeaRepository = ProjectIdeaRepository();
    selectedIdea = widget.ideas?.first;
    currentImages = widget.post?.images ?? [];
    title = TextEditingController(text: widget.post?.title ?? "");
    caption = TextEditingController(text: widget.post?.messgae ?? "");
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagesFile.add(File(pickedFile.path));
      });
    }
  }

  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a post title';
    }
    return null;
  }

  Future<void> submitPost() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedIdea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a project")),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      if (widget.post == null) {
        // Creating a new post
        await projectIdeaRepository.sendNewPost(
          PostModel(
            images: currentImages,
            title: title.text,
            messgae: caption.text,
            upPosts: [],
            idea: selectedIdea,
            ideaId: selectedIdea?.id,
          ),
          imagesFile,
          [],
          BlocProvider.of<GitHubPointsBloc>(context),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post created successfully!")),
        );
      } else {
        // Updating an existing post
        await projectIdeaRepository.updatePost(
          widget.post!.copyWith(
            images: currentImages,
            title: title.text,
            messgae: caption.text,
          ),
          imagesFile,
          deletedImages,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post updated successfully!")),
        );
      }

      Navigator.pop(context, "DONE");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedIdea != null) ...[
                        label("Select Project*"),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius:
                                BorderRadius.circular(TSizes.inputFieldRadius),
                          ),
                          child: DropdownButton<Idea>(
                            value: selectedIdea,
                            items: widget.ideas!
                                .map((idea) => DropdownMenuItem(
                                      value: idea,
                                      child: Text(idea.title),
                                    ))
                                .toList(),
                            onChanged: (idea) {
                              setState(() {
                                selectedIdea = idea;
                              });
                            },
                            isExpanded: true,
                            underline: const SizedBox(),
                            dropdownColor: Theme.of(context).cardColor,
                          ),
                        ),
                      ],
                      label("Images (Optional)"),
                      SizedBox(
                        height: 100,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ...currentImages.map((url) => buildImagePreview(
                                    url,
                                    onRemove: () {
                                      setState(() {
                                        deletedImages.add(url);
                                        currentImages.remove(url);
                                      });
                                    },
                                  )),
                              ...imagesFile.map((file) => buildImagePreview(
                                    file.path,
                                    isLocalFile: true,
                                    onRemove: () {
                                      setState(() {
                                        imagesFile.remove(file);
                                      });
                                    },
                                  )),
                              GestureDetector(
                                onTap: pickImage,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: const Icon(Icons.add),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      label("Description"),
                      CustomTextField(
                        controller: caption,
                        hint:
                            "What is the latest update for ${selectedIdea?.title}?",
                        maxLines: 7,
                        maxLength: 500,
                        showCounter: true, label: '',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: isSubmitting ? null : submitPost,
                child: isSubmitting
                    ? const CircularProgressIndicator()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.post != null ? "Save Changes" : "Post"),
                          const SizedBox(width: 8), // Space between text and icon
                          const Icon(Icons.send),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget label(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  Widget buildImagePreview(String imagePath,
      {bool isLocalFile = false, required VoidCallback onRemove}) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          constraints: const BoxConstraints(maxWidth: 100),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: isLocalFile
                ? Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Positioned(
          top: -10,
          left: -10,
          child: IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.cancel, color: Colors.red),
          ),
        ),
      ],
    );
  }
}
