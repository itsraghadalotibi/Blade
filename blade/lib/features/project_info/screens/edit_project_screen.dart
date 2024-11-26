import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/constants/colors.dart';
import '../../announcement/src/announcement_model.dart';
import '../../announcement/src/announcement_repository.dart';
import '../../newPost/screens/post.dart';

class EditProjectScreen extends StatefulWidget {
  final Idea idea;
  final AnnouncementRepository repository;

  const EditProjectScreen({
    Key? key,
    required this.idea,
    required this.repository,
  }) : super(key: key);

  @override
  _EditProjectScreenState createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ideanameController = TextEditingController();
  final TextEditingController _ideadescriptionController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  List<String> tags = [];
  List<String> options = [];
  String? _skillsError;
  Color _messageColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers with existing idea data
    _ideanameController.text = widget.idea.title;
    _ideadescriptionController.text = widget.idea.description;
    _numberController.text = (widget.idea.maxMembers - 1).toString();
    tags = List<String>.from(widget.idea.skills);

    fetchSkills();
  }

  Future<void> fetchSkills() async {
    try {
      final skillsSnapshot = await FirebaseFirestore.instance.collection('skills').get();
      final skills = skillsSnapshot.docs.map((doc) => doc['name'] as String).toList();

      setState(() {
        options = skills;
      });
    } catch (e) {
      print('Error fetching skills: $e');
      // Optionally, handle the error in the UI
    }
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      if (tags.isEmpty) {
        setState(() {
          _skillsError = 'Please select at least one skill';
          _messageColor = Colors.red;
        });
        return;
      }

      // Validate that maxMembers is not less than current members
      int newMaxMembers = int.parse(_numberController.text);
      int currentMembers = widget.idea.members.length;

      if (newMaxMembers < currentMembers) {
        setState(() {
          _skillsError =
              'Maximum members cannot be less than current members ($currentMembers)';
          _messageColor = Colors.red;
        });
        return;
      }

      setState(() {
        _skillsError = null;
        _messageColor = Colors.grey;
      });

      // Update the idea with new values
      Idea updatedIdea = Idea(
        id: widget.idea.id,
        title: _ideanameController.text,
        description: _ideadescriptionController.text,
        maxMembers: newMaxMembers + 1,
        members: widget.idea.members,
        isJoined: widget.idea.isJoined,
        skills: tags,
        status: widget.idea.status,
      );

      try {
        await widget.repository.updateIdea(updatedIdea);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: TColors.success,
            behavior: SnackBarBehavior.floating,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.check_mark_circled_solid,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Project edited Successfully!',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            showCloseIcon: true,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        print('Error updating idea: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save changes')),
        );
      }
    }
  }

  void _deleteProject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        // Determine the theme brightness
        Brightness brightness = Theme.of(context).brightness;

        // Set background and text colors based on theme
        Color backgroundColor;

        if (brightness == Brightness.dark) {
          backgroundColor = Colors.grey[850]!; // Dark grey for dark theme
        } else {
          backgroundColor = Colors.grey[200]!; // Light grey for light theme
        }

        return AlertDialog(
          backgroundColor: backgroundColor,
          title: const Text('Delete Project'),
          content: const Text(
              'Are you sure you want to delete this project? This action cannot be undone.'),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await widget.repository.deleteIdea(widget.idea.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: TColors.success,
            behavior: SnackBarBehavior.floating,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.check_mark_circled_solid,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Project deleted Successfully!',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            showCloseIcon: true,
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst); // Go back to the main screen
      } catch (e) {
        print('Error deleting idea: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete project')),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    // Check if there are unsaved changes
    bool hasUnsavedChanges = _ideanameController.text != widget.idea.title ||
        _ideadescriptionController.text != widget.idea.description ||
        int.parse(_numberController.text) != (widget.idea.maxMembers - 1) ||
        !listEquals(tags, widget.idea.skills);

    if (!hasUnsavedChanges) {
      // No unsaved changes, allow pop
      return true;
    }

    // Show confirmation dialog
    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard Changes?'),
            content: const Text('Are you sure you want to discard your changes?'),
            actions: <Widget>[
              OutlinedButton(
                style: OutlinedButton.styleFrom(
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Determine the minimum number of members
    int currentMembers = widget.idea.members.length;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Project'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Project Name
                TextFormField(
                  controller: _ideanameController,
                  style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Project Name*',
                    labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black),
                    border: const OutlineInputBorder(),
                    errorStyle: const TextStyle(color: Colors.red),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a project name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Project Description
                TextFormField(
                  controller: _ideadescriptionController,
                  maxLines: 5,
                  maxLength: 250,
                  style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Project Description*',
                    labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black),
                    border: const OutlineInputBorder(),
                    errorStyle: const TextStyle(color: Colors.red),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please describe your idea';
                    } else if (value.length < 20) {
                      return 'At least 20 characters required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Number of Members
                Row(
                  children: [
                    const Text('Number of Members:',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    NumberStepper(
                      initialNumber: int.parse(_numberController.text),
                      minValue: currentMembers - 1,
                      // Set minimum to current number of members
                      onNumberChanged: (newNumber) {
                        setState(() {
                          _numberController.text = newNumber.toString();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Skills
                const Text(
                  'Skills*',
                  //style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return options.where((String option) {
                      return option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selectedTag) {
                    setState(() {
                      if (!tags.contains(selectedTag)) {
                        tags.add(selectedTag);
                        _messageColor = Colors.grey;
                      }
                    });
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Search and add more skills',
                        hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey
                                : Colors.black54),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.transparent,
                        suffixIcon: textEditingController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  textEditingController.clear();
                                  setState(() {}); // Update the UI to hide the 'X' icon
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {}); // Update the UI to show/hide the 'X' icon
                      },
                    );
                  },
                  optionsViewBuilder: (BuildContext context,
                      AutocompleteOnSelected<String> onSelected,
                      Iterable<String> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: Container(
                          width: MediaQuery.of(context).size.width - 32,
                          color: isDarkMode ? Colors.grey[850] : Colors.white,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return ListTile(
                                title: Text(
                                  option,
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                onTap: () {
                                  onSelected(option);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Scrollable Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: tags.map((skill) {
                      return FilterChip(
                        label: Text(
                          skill,
                          style: TextStyle(
                              color:
                                  isDarkMode ? Colors.white : Colors.black),
                        ),
                        selected: tags.contains(skill),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              tags.add(skill);
                              _messageColor = Colors.grey;
                            } else {
                              tags.remove(skill);
                            }
                          });
                        },
                        backgroundColor:
                            isDarkMode ? TColors.dark : TColors.light,
                        selectedColor: const Color(0xFFFD5336),
                        showCheckmark: true,
                        checkmarkColor: Colors.white,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                if (_skillsError != null)
                  Text(
                    _skillsError!,
                    style: TextStyle(color: _messageColor, fontSize: 13),
                  ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 18.0),
                          side: BorderSide(
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    // Save Changes Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 18.0),
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ),
                    // Delete Project Button (Optional)
                  ],
                ),
                const SizedBox(height: 24.0),
                // SizedBox(
                //   width: double.infinity,
                //   child: OutlinedButton(
                //     onPressed: _deleteProject,
                //     style: OutlinedButton.styleFrom(
                //       foregroundColor: Colors.red,
                //       side: const BorderSide(color: Colors.red),
                //       padding: const EdgeInsets.symmetric(
                //           horizontal: 24.0, vertical: 18.0),
                //     ),
                //     child: const Row(
                //       mainAxisAlignment: MainAxisAlignment.center, // Centers the content
                //       children: [
                //         Icon(
                //           Icons.delete, // You can choose a different icon if preferred
                //           color: Colors.red, // Ensures the icon matches the text color
                //         ),
                //         SizedBox(width: 8.0), // Provides space between icon and text
                //         Text('Delete Project'),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}