import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:blade_app/features/profile/bloc/repository/project_idea_repository.dart';
import 'package:blade_app/features/project_info/src/post_model.dart';
import 'package:blade_app/utils/constants/sizes.dart';
import 'package:blade_app/widgets/custom_text_field.dart';

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
  final ProjectIdeaRepository projectIdeaRepository = ProjectIdeaRepository();
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
await projectIdeaRepository.sendNewPost(
  PostModel(
    images: currentImages,
    title: title.text,
    messgae: caption.text,
    upPosts: [],
    idea: selectedIdea,
    ideaId: selectedIdea?.id,
  ),
  imagesFile, // List<File> for images to upload
  deletedImages, // List<String> for deleted image URLs
  BlocProvider.of<GitHubPointsBloc>(context), // GitHub points bloc or other missing parameter
);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post created successfully!")),
        );
      } else {
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

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard Changes?'),
            content:
                const Text('Are you sure you want to discard your changes?'),
            actions: <Widget>[
              OutlinedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 12.0),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 12.0),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Discard'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
                                ...currentImages.map((i) => _buildImagePreview(i)),
                                ...imagesFile.map((i) => _buildFilePreview(i)),
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
                          validator: validateTitle,
                          showCounter: true,
                          maxLength: 500,
                          hint:
                              "What is the latest update for ${selectedIdea?.title}?",
                          label: null,
                          controller: caption,
                          maxLines: 7,
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: isSubmitting ? null : submitPost,
                  icon: isSubmitting
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.save),
                  label: Text(widget.post != null ? "Save changes" : "Post"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget label(String text) => Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          text,
          style: const TextStyle(fontSize: 20),
        ),
      );

  Widget _buildImagePreview(String imageUrl) {
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 100),
          padding: const EdgeInsets.only(right: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              imageUrl,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),
        ),
        Positioned(
          top: -10,
          left: -10,
          child: IconButton(
            onPressed: () {
              setState(() {
                deletedImages.add(imageUrl);
                currentImages.remove(imageUrl);
              });
            },
            icon: const Icon(Icons.cancel, color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePreview(File file) {
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 100),
          padding: const EdgeInsets.only(right: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(
              file,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),
        ),
        Positioned(
          top: -10,
          left: -10,
          child: IconButton(
            onPressed: () {
              setState(() {
                imagesFile.remove(file);
              });
            },
            icon: const Icon(Icons.cancel, color: Colors.red),
          ),
        ),
      ],
    );
  }
}
