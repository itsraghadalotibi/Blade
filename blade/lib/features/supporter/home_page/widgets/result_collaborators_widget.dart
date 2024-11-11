import 'package:flutter/material.dart';
import '../../../announcement/src/announcement_model.dart';
import '../../../../utils/constants/colors.dart';
import 'package:blade_app/features/profile/bloc/screens/collaborator_profile_screen.dart';
import 'no_result_widget.dart'; // Import the new widget

class ResultCollaboratorsWidget extends StatelessWidget {
  final List<Collaborator> collaborators;

  const ResultCollaboratorsWidget({
    Key? key,
    required this.collaborators,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (collaborators.isEmpty) {
      return NoResultWidget(message: 'No collaborator found.');
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: collaborators.length,
      itemBuilder: (context, index) {
        final collaborator = collaborators[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CollaboratorProfileScreen(
                  userId: collaborator.uid,
                  showBackButton: true,
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? TColors.container : TColors.white,
              borderRadius: BorderRadius.circular(23),
              border: isDarkMode ? null : Border.all(color: TColors.borderPrimary),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(collaborator.profilePhotoUrl),
                  radius: 30,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${collaborator.firstName} ${collaborator.lastName}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : TColors.textPrimary,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Text(
                      //   'Collaborator',
                      //   style: TextStyle(
                      //     color: isDarkMode ? Colors.white70 : TColors.textSecondary,
                      //     fontSize: 14,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 10),
    );
  }
}
