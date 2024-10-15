import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../announcement/src/announcement_model.dart';
import '../../announcement/src/announcement_repository.dart';
import '../bloc/project_bloc.dart';
import 'edit_project_screen.dart';
import 'change_project_status_screen.dart';

class ProjectSettingsScreen extends StatelessWidget {
  final Idea idea;
  final AnnouncementRepository repository;

  const ProjectSettingsScreen({
    Key? key,
    required this.idea,
    required this.repository,
  }) : super(key: key);

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
                        content:
                            Text('Cannot edit project while it is ongoing.'),
                        backgroundColor: Colors.red,
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

                    if (result == true) {
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
          ListTile(
            leading: const Icon(Icons.change_circle),
            title: const Text('Change Project Status'),
            onTap: () async {
  final projectBloc = BlocProvider.of<ProjectBloc>(context);
  final bool? result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: projectBloc, // Pass the existing bloc
        child: ChangeProjectStatusScreen(
          idea: idea,
          repository: repository,
        ),
      ),
    ),
  );
  if (result == true) {
    Navigator.pop(context);
  }
},
          ),
        ],
      ),
    );
  }
}
