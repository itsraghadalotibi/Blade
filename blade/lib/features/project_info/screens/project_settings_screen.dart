import 'package:flutter/material.dart';
import '../../announcement/src/announcement_model.dart';
import '../../announcement/src/announcement_repository.dart';
import 'edit_project_screen.dart';
import 'change_project_status_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectSettingsScreen extends StatelessWidget {
  final Idea idea;
  final AnnouncementRepository repository;

  const ProjectSettingsScreen({
    Key? key,
    required this.idea,
    required this.repository,
  }) : super(key: key);

  // Function to delete the idea and save the title in join_requests.
  Future<void> deleteIdea(BuildContext context) async {
    try {
      final String? ideaId = idea.id; // ID of the idea being deleted
      final String ideaTitle = idea.title; // Title of the idea being deleted

      // Step 1: Fetch all join_requests related to the idea.
      final joinRequests = await FirebaseFirestore.instance
          .collection('join_requests')
          .where('ideaId', isEqualTo: ideaId)
          .get();

      // Step 2: Update the title field in each join_request.
      for (var request in joinRequests.docs) {
        await request.reference.update({'title': ideaTitle}); // Save title
      }

      // Step 3: Delete the idea document from the `ideas` collection.
      await FirebaseFirestore.instance.collection('ideas').doc(ideaId).delete();

      // Step 4: Notify the user of successful deletion with a styled SnackBar.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Project deleted successfully!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top: 10, left: 10, right: 10),
            showCloseIcon: true,
          ),
        );

        // Step 5: Navigate back.
        Navigator.pop(context);
      }
    } catch (e) {
      // Handle errors gracefully.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to delete the project. Please try again later.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top: 10, left: 10, right: 10),
            showCloseIcon: true,
          ),
        );
      }
      print('Error deleting idea: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isEditDisabled = idea.status == 'ongoing';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Edit Project Details ListTile
          ListTile(
            leading: Icon(
              Icons.edit,
              color: isEditDisabled
                  ? Colors.grey
                  : (isDarkMode ? Colors.white : Colors.black),
            ),
            title: Text(
              'Edit Project Details',
              style: TextStyle(
                color: isEditDisabled
                    ? Colors.grey
                    : (isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            onTap: isEditDisabled
                ? () {
                    // SnackBar explaining why editing is disabled
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Cannot edit project while it is ongoing.',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                        showCloseIcon: true,
                      ),
                    );
                  }
                : () async {
                    // Navigate to EditProjectScreen and await the result
                    final bool? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProjectScreen(
                          idea: idea,
                          repository: repository,
                        ),
                      ),
                    );
                    if (result == true && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
            trailing: isEditDisabled
                ? const Tooltip(
                    message: 'Cannot edit project while it is ongoing.',
                    child: Icon(Icons.info, color: Colors.grey),
                  )
                : null,
          ),

          // Change Project Status ListTile
          ListTile(
            leading: const Icon(Icons.change_circle),
            title: const Text('Change Project Status'),
            onTap: () async {
              final bool? result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeProjectStatusScreen(
                    idea: idea,
                    repository: repository,
                  ),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context);
              }
            },
          ),

          // Delete Project ListTile
          ListTile(
            leading: Icon(
              Icons.delete,
              color: Colors.red.shade700,
            ),
            title: const Text(
              'Delete Project',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              // Confirm deletion with the user.
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Deletion'),
                    content: Text(
                      'Are you sure you want to delete the project "${idea.title}"? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );

              // If user confirms, proceed with deletion.
              if (confirm == true) {
                await deleteIdea(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

