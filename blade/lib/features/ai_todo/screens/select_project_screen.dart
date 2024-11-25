import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:blade_app/features/announcement/src/announcement_repository.dart';
import 'package:blade_app/features/project_info/screens/project_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../utils/constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ai_todo_screen.dart';

class SelectProjectScreen extends StatefulWidget {
  const SelectProjectScreen({Key? key}) : super(key: key);

  @override
  _SelectProjectScreenState createState() => _SelectProjectScreenState();
}

class _SelectProjectScreenState extends State<SelectProjectScreen> {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  Future<List<Idea>> fetchOngoingIdeas(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('ideas')
        .where('status', isEqualTo: 'ongoing')
        .where('members', arrayContains: userId)
        .get();

    return snapshot.docs.map((doc) => Idea.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Which Project To Blueprint?"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Idea>>(
        future: fetchOngoingIdeas(userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No projects available."));
          }

          final ideas = snapshot.data!;
          return ListView.builder(
            itemCount: ideas.length,
            itemBuilder: (context, index) {
              final idea = ideas[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AiTodoScreen(ideaId: idea.id),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 14, 97, 176),
                          Color.fromARGB(255, 69, 142, 187),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            idea.title,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            idea.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              IconButton(
                                icon: const FaIcon(
                                  FontAwesomeIcons.github,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  if (idea.repoUrl != null &&
                                      await canLaunchUrl(Uri.parse(idea.repoUrl!))) {
                                    await launchUrl(Uri.parse(idea.repoUrl!),
                                        mode: LaunchMode.externalApplication);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Cannot launch repository URL'),
                                      ),
                                    );
                                  }
                                },
                              ),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: (idea.points / 500).clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey[200],
                                  color: Colors.greenAccent,
                                  minHeight: 8.0,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "${idea.points} points",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Idea {
  final String id;
  final String title;
  final String description;
  final String? repoUrl;
  final int points;

  Idea({
    required this.id,
    required this.title,
    required this.description,
    this.repoUrl,
    required this.points,
  });

  static Idea fromMap(Map<String, dynamic> map, String id) {
    return Idea(
      id: id,
      title: map['title'],
      description: map['description'],
      repoUrl: map['repoUrl'],
      points: map['points'] ?? 0,
    );
  }
}
