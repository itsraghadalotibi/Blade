import 'dart:io';

import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:blade_app/features/profile/bloc/repository/project_idea_repository.dart';
import 'package:blade_app/features/project_info/src/post_model.dart';
import 'package:blade_app/utils/constants/sizes.dart';
import 'package:blade_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewPost extends StatefulWidget {
  final List<Idea>? ideas;
  final PostModel? post;
  const NewPost({super.key, this.ideas, this.post});

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  Idea? selectedIdea;
  late ProjectIdeaRepository projectIdeaRepository;
  @override
  void initState() {
    super.initState();
    projectIdeaRepository = ProjectIdeaRepository();
    selectedIdea = widget.ideas?.first;
    currentImages = widget.post?.images ?? [];
    title = TextEditingController(text: widget.post?.title ?? "");
    caption = TextEditingController(text: widget.post?.messgae ?? "");
  }

  final ImagePicker picker = ImagePicker();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController title;
  late TextEditingController caption;
  List<File> imagesFile = [];
  List<String> currentImages = [];
  List<String> deletedImages = [];
  bool isPress = false;

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        imagesFile.add(File(pickedFile.path));
      });
    }
  }

  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter post title';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
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
                        lable("Select Project*"),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(
                                  TSizes.inputFieldRadius)),
                          child: DropdownButton<Idea>(
                            value: selectedIdea,
                            items: widget.ideas!
                                .map((i) => DropdownMenuItem(
                                      value: i,
                                      child: Text(i.title),
                                    ))
                                .toList(),
                            onChanged: (i) {
                              setState(() {
                                selectedIdea = i;
                              });
                            },
                            isExpanded: true,
                            underline: const SizedBox(),
                            dropdownColor: Theme.of(context).cardColor,
                          ),
                        ),
                      ],
                      lable("Images (Optional)"),
                      SizedBox(
                          height: 100,
                          child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ...currentImages.map((i) {
                                    return Stack(
                                      children: [
                                        Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 100),
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image.network(
                                                i,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const SizedBox(),
                                              )),
                                        ),
                                        Positioned(
                                            top: -10,
                                            left: -10,
                                            child: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    deletedImages.add(i);
                                                    currentImages.removeWhere(
                                                      (f) => i == f,
                                                    );
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.cancel,
                                                  color: Colors.red,
                                                ))),
                                      ],
                                    );
                                  }),
                                  ...imagesFile.map((i) {
                                    return Stack(
                                      children: [
                                        Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 100),
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image.file(
                                                i,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    const SizedBox(),
                                              )),
                                        ),
                                        Positioned(
                                            top: -10,
                                            left: -10,
                                            child: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    imagesFile.removeWhere(
                                                      (f) => i == f,
                                                    );
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.cancel,
                                                  color: Colors.red,
                                                ))),
                                      ],
                                    );
                                  }),
                                  GestureDetector(
                                    onTap: pickImage,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: const Icon(Icons.add),
                                    ),
                                  )
                                ],
                              ))),
                      // lable("Title*"),
                      // CustomTextField(
                      //   hint: "Add a title",
                      //   validator: validateTitle,
                      //   label: null, controller: title),
                      lable("Description"),
                      CustomTextField(
                        validator: validateTitle,
                        showCounter: true,
                        maxLength: 500,
                        hint:
                            "What is the latest update for ${selectedIdea?.title}?",
                        label: null,
                        controller: caption,
                        maxLines: 7,
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
                            horizontal: 20, vertical: 12)),
                    // icon: Icon(widget.post == null ? Icons.add : Icons.edit),
                    onPressed: isPress
                        ? null
                        : () async {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                isPress = true;
                              });
                              if (caption.text.trim() == "") return;
                              if (widget.post == null) {
                                await projectIdeaRepository.sendNewPost(
                                    PostModel(
                                      images: currentImages,
                                      title: title.text,
                                      messgae: caption.text,
                                      upPosts: [],
                                      idea: selectedIdea,
                                    ),
                                    imagesFile,
                                    []);
                                Navigator.pop(context, "DONE");
                              } else {
                                await projectIdeaRepository.updatePost(
                                    widget.post!.copyWith(
                                      images: currentImages,
                                      title: title.text,
                                      messgae: caption.text,
                                    ),
                                    imagesFile,
                                    deletedImages);
                                Navigator.pop(context, "DONE");
                              }
                            }
                          },
                    label: isPress
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Text(widget.post != null ? "Save changes" : "Post")))
          ],
        ),
      ),
    );
  }

  Widget lable(String text) => Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        child: Text(
          text,
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 20),
        ),
      );
}
