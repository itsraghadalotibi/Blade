  // blade/lib/features/announcement/src/announcement_model.dart

  class Idea {
    String? id; // Add the id field
    final String title;
    final String description;
    final int maxMembers;
    final List<String> members; // Will store user IDs
    final List<String> skills;
    bool? isJoined;
    int? requestCount;
    String status;
    final String? repoUrl; // To store the GitHub repository URL
    int points; // Add points field



    Idea({
      this.id, // Include id in the constructor
      required this.title,
      required this.description,
      required this.maxMembers,
      required this.members,
      required this.skills,
      required this.status,
      this.repoUrl,
      this.isJoined,
      this.requestCount,
      this.points = 0, 
    });

    // Factory constructor to create an Idea from Firestore data
    factory Idea.fromMap(Map<String, dynamic> data, String documentId) {
      return Idea(
        id: documentId, // Assign the document ID from Firestore
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        maxMembers: data['maxMembers'] ?? 0,
        members: List<String>.from(data['members'] ?? []),
        skills: data['skills'] != null && data['skills'] is List
            ? List<String>.from(data['skills'])
            : [],
        status: data['status'] ?? 'open',
        repoUrl: data['repoUrl'] ?? '', 
        isJoined: data['isJoined'] ?? false,
        requestCount: data['requestCount'],
        points: data['points'] ?? 0, // Load points from Firestore
      );
    }

    Idea copyWith({
      String? id,
      String? title,
      String? description,
      String? status,
      bool? isJoined,
      List<String>? members,
      int? points,
      double? progress,
    }) {
      return Idea(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        status: status ?? this.status,
        members: members ?? this.members,
        isJoined: isJoined ?? this.isJoined,
        maxMembers: maxMembers,
        skills: skills,
        repoUrl: repoUrl, // Retain the repoUrl when copying
      );
    }

    // Convert Idea to map (for saving to Firestore)
    Map<String, dynamic> toMap() {
      return {
        'title': title,
        'description': description,
        'maxMembers': maxMembers,
        'members': members,
        'skills': skills,
        'status': status,
        'repoUrl': repoUrl, // Include the repoUrl in the map
        'isJoined': isJoined,
        'requestCount': requestCount,
        'points': points, // Save points to Firestore
      };
    }
  }

  class Collaborator {
    final String uid;
    final String firstName;
    final String lastName;
    final String profilePhotoUrl;
    final List<String> skills;
    

    Collaborator({
      required this.uid,
      required this.firstName,
      required this.lastName,
      required this.profilePhotoUrl,
      required this.skills,
    });

    factory Collaborator.fromMap(Map<String, dynamic> data) {
      return Collaborator(
        uid: data['uid'] ?? '',
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        profilePhotoUrl: data['profilePhotoUrl'] ?? '',
        skills: data['skills'] != null && data['skills'] is List
            ? List<String>.from(data['skills'])
            : [],
      );
    }
  }

  class Member {
    final String name;
    final List<String> skills;
    final String imageUrl;

    Member({
      required this.name,
      required this.skills,
      required this.imageUrl,
    });
  }
