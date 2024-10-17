// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:blade_app/features/announcement/src/announcement_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../announcement/src/announcement_model.dart';
import '../../announcement/widgets/skill_tag_widget.dart';
import '../../profile/bloc/screens/collaborator_profile_screen.dart';

class OffersTab extends StatefulWidget {
  final Idea idea;
  final AnnouncementRepository repository;
  final Function(String) addNewMember;

  const OffersTab({
    super.key,
    required this.idea,
    required this.repository, 
    required this.addNewMember,
  });

  @override
  State<OffersTab> createState() => _OffersTabState();
}

class _OffersTabState extends State<OffersTab> {
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<Collaborator>>(
      future: _fetchCollaborators(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No Join Requests found.'));
        }
        final int maxMembers = widget.idea.maxMembers;
        final int currentMembers = widget.idea.members.length;
        final bool isFull = (currentMembers - 1) >= maxMembers;
        if (isFull) {
          return const Center(child: Text('This Project Is Full'));
        }

        final collaborators = snapshot.data!;

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: collaborators.length,
          itemBuilder: (context, index) {
            final collaborator = collaborators[index];


            final matchingSkills = collaborator.skills
                    .where((skill) => widget.idea.skills.contains(skill))
                    .toList();

            return GestureDetector(
              onTap: () {
                // Navigate to the collaborator's profile
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
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey[850]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: isDarkMode
                      ? null
                      : Border.all(color: Colors.grey),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(collaborator.profilePhotoUrl),
                        radius: 30,
                      ),
                      title: Text(
                        '${collaborator.firstName} ${collaborator.lastName}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: matchingSkills.isNotEmpty
                          ? GestureDetector(
                              onTap: () {}, // Prevent scrolling issue
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: matchingSkills.map((skill) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: SkillTagWidget(skills: [skill]),
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                          : Text(
                              'No matching skills',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.grey[600],
                              ),
                            ),
                    ),
                      AcceptRejectButtons(onAccept: ()async{
                        // setState(() {
                        //   isPress = true;
                        // });
                        // Reject join request
                        await widget.repository.rejectJoinRequest(widget.idea.id!, collaborator.uid);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Rejected ${collaborator.firstName} ${collaborator.lastName}')),
                        );
                        Navigator.popUntil(context, (route) => route.isFirst);
                        setState(() {});
                      },onReject: ()async{
                        // setState(() {
                        //   isPress = true;
                        // });
                        // Accept join request
                        await widget.repository.acceptJoinRequest(widget.idea, collaborator.uid);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Accepted ${collaborator.firstName} ${collaborator.lastName}')),
                        );
                        widget.addNewMember(collaborator.uid);
                        setState(() {});
                      },
                      )
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(height: 10);
          },
        );
      },
    );
  }

  // Fetch collaborators based on memberIds
  Future<List<Collaborator>> _fetchCollaborators() async {
    List<Collaborator> collaborators = [];

      final querySnapshot = await FirebaseFirestore.instance
          .collection('join_requests')
          .where('ideaId', isEqualTo: widget.idea.id)
          .where('status', isEqualTo:'pending')
          .get();
    print(querySnapshot.docs.length);
    for (String memberId in querySnapshot.docs.map((doc)=>doc["userId"])) {
      final collaborator = await widget.repository.fetchCollaborator(memberId);
      if (collaborator != null) {
        collaborators.add(collaborator);
      }
    }
    return collaborators;
  }
}

class AcceptRejectButtons extends StatefulWidget {
  final Function() onAccept;
  final Function() onReject;

  const AcceptRejectButtons({
    super.key,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<AcceptRejectButtons> createState() => _AcceptRejectButtonsState();
}

class _AcceptRejectButtonsState extends State<AcceptRejectButtons> {
  bool isPress = false;
  @override
  Widget build(BuildContext context) {
    if(isPress)return const SizedBox();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async{
            setState(() {
              isPress = true;
            });
            await widget.onAccept();
            setState(() {
              isPress = false;
            });
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(10),
            backgroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: const Text(
            'REJECT',
            style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () async{
            setState(() {
              isPress = true;
            });
            await widget.onReject();
            setState(() {
              isPress = false;
            });
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(10),
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            side: BorderSide.none, 
          ),
          child: const Text(
            'ACCEPT',
            style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}