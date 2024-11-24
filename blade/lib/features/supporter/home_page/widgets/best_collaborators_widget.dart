import 'package:flutter/material.dart';
import '../../../announcement/src/announcement_model.dart';
import 'package:blade_app/features/profile/bloc/screens/collaborator_profile_screen.dart';
import '../../../../utils/constants/colors.dart';

class BestCollaboratorsWidget extends StatelessWidget {
  final List<Collaborator> collaborators;

  BestCollaboratorsWidget({required this.collaborators});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Best Collaborators',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: collaborators.length,
            itemBuilder: (context, index) {
              final collaborator = collaborators[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GroupCard(
                  collaborator: collaborator,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class GroupCard extends StatelessWidget {
  final Collaborator collaborator;

  GroupCard({required this.collaborator});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        // Navigate to the Collaborator Profile when the card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CollaboratorProfileScreen(
              userId: collaborator.uid,
              showBackButton: true, // Pass true to show back button
            ),
          ),
        );
      },
      child: Container(
        width: 164,
        height: 211,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isDarkMode ? TColors.container : TColors.white,
          border: isDarkMode
              ? null // No border in dark mode
              : Border.all(color: TColors.borderPrimary), // Light mode border
          borderRadius: BorderRadius.circular(23), // Border radius
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Wrap the profile image with GestureDetector for navigation
            GestureDetector(
              onTap: () {
                // Navigate to the Collaborator Profile when the image is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CollaboratorProfileScreen(
                      userId: collaborator.uid,
                      showBackButton: true, // Pass true to show back button
                    ),
                  ),
                );
              },
              child: Container(
                width: 69,
                height: 69,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(collaborator.profilePhotoUrl),
                    fit: BoxFit.cover,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                children: [
                  Text(
                    collaborator.firstName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : TColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    collaborator.lastName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : TColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
