import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  List<String> topSkills = [];
  String? _skillsError;
  Color _messageColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers with existing idea data
    _ideanameController.text = widget.idea.title;
    _ideadescriptionController.text = widget.idea.description;
    _numberController.text = widget.idea.maxMembers.toString();
    tags = List<String>.from(widget.idea.skills);

    fetchSkills();
  }

  Future<void> fetchSkills() async {
    try {
      final skillsSnapshot = await FirebaseFirestore.instance.collection('skills').get();
      final skills = skillsSnapshot.docs.map((doc) => doc['name'] as String).toList();

      setState(() {
        options = skills;
        topSkills = skills.take(6).toList();
      });
    } catch (e) {
      print('Error fetching skills: $e');
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
      setState(() {
        _skillsError = null;
        _messageColor = Colors.grey;
      });

      // Update the idea with new values
      Idea updatedIdea = Idea(
        id: widget.idea.id,
        title: _ideanameController.text,
        description: _ideadescriptionController.text,
        maxMembers: int.parse(_numberController.text),
        members: widget.idea.members,
        isJoined: widget.idea.isJoined,
        skills: tags,
        status: widget.idea.status,
      );

      try {
        await widget.repository.updateIdea(updatedIdea);
        Navigator.pop(context); // Go back to the project screen
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
// Light text for contrast
      } else {
        backgroundColor = Colors.grey[200]!; // Light grey for light theme
// Dark text for contrast
      }
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: const Text('Delete Project'),
          content: const Text('Are you sure you want to delete this project? This action cannot be undone.'),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
              
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                side: const BorderSide(color:  Colors.red),
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
        Navigator.popUntil(context, (route) => route.isFirst); // Go back to the main screen
      } catch (e) {
        print('Error deleting idea: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete project')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project'),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Project Name
              TextFormField(
                controller: _ideanameController,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Project Name*',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
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
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Project Description*',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  border: const OutlineInputBorder(),
                  errorStyle: const TextStyle(color: Colors.red),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe your idea';
                  } else if (value.length < 50) {
                    return 'At least 50 characters required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Number of Members
              Row(
                children: [
                  const Text('Number of Members:', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  NumberStepper(
                    initialNumber: int.parse(_numberController.text),
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
              Text(
                'Skills*',
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return options.where((String option) {
                    return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selectedTag) {
                  setState(() {
                    if (!tags.contains(selectedTag)) {
                      tags.add(selectedTag);
                      _messageColor = Colors.grey;
                    }
                    if (!topSkills.contains(selectedTag)) {
                      topSkills.add(selectedTag);
                    }
                  });
                },
                fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                    FocusNode focusNode, VoidCallback onFieldSubmitted) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search and add more skills',
                      hintStyle: TextStyle(color: isDarkMode ? Colors.grey : Colors.black54),
                      border: const OutlineInputBorder(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: topSkills.map((skill) {
                  return FilterChip(
                    label: Text(skill, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
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
                    backgroundColor: isDarkMode ? Colors.grey[500] : Colors.white70,
                    selectedColor: const Color(0xFFFD5336),
                    showCheckmark: true,
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel Button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    
                    child: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                    ),
                  ),
                  // Save Changes Button
                  ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      side: const BorderSide(color:  Colors.green),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                    ),
                    child: const Text('Save Changes'),
                  ),
                  // Delete Project Button
                ],
              ),
              const SizedBox(height: 24.0),
              
                Center(
                  child: OutlinedButton(
                        onPressed: _deleteProject,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color:  Colors.red),
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                        ),
                        child: const Text('Delete Project'),
                      ),
                ),
              
            ],
          ),
        ),
      ),
    );
  }
}
