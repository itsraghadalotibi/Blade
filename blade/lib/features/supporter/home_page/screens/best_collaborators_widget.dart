import 'package:flutter/material.dart';
import '../../../announcement/src/announcement_model.dart';

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
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240, // Adjusted to prevent overflow for longer names
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: collaborators.length,
            itemBuilder: (context, index) {
              final collaborator = collaborators[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GroupCard(
                  firstName: collaborator.firstName,
                  lastName: collaborator.lastName,
                  profileImageUrl: collaborator.profilePhotoUrl,
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
  final String firstName;
  final String lastName;
  final String profileImageUrl;

  GroupCard({
    required this.firstName,
    required this.lastName,
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 164,
      height: 211,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile image
          Container(
            width: 69,
            height: 69,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(profileImageUrl),
                fit: BoxFit.cover,
              ),
              shape: BoxShape.circle, // Make sure the profile image is circular
            ),
          ),
          const SizedBox(height: 16),

          // Name and score
          Expanded(
            child: Column(
              children: [
                // Display first name and last name on separate lines
                Column(
                  children: [
                    Text(
                      firstName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF050527),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      lastName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF050527),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(), // Ensures flexible space between name and score
                Text(
                  '1500 Scored',
                  style: TextStyle(
                    color: Color(0xFF8D8DA6),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16), // Space between score and button

          // Contact button
          Container(
            width: 115,
            height: 27,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4fe3c2), // First color
                  Color(0xFF6febf4), // Second color
                ],
                begin: Alignment.center, // Starting point of the gradient
                end: Alignment.bottomRight, // Ending point of the gradient
              ),
              borderRadius: BorderRadius.circular(48), // Rounded corners
            ),
            child: Center(
              child: Text(
                'Contact',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
