import 'package:flutter/material.dart';
import '../../announcement/src/announcement_model.dart';
import '../../announcement/src/announcement_repository.dart';
import '../../profile/bloc/repository/project_idea_repository.dart';
import '../../profile/bloc/screens/project_idea_card_widget.dart';
import 'ai_todo_screen.dart';

class SelectProjectScreen extends StatefulWidget {
  const SelectProjectScreen({Key? key}) : super(key: key);

  @override
  State<SelectProjectScreen> createState() => _SelectProjectScreenState();
}

class _SelectProjectScreenState extends State<SelectProjectScreen> {
  final AnnouncementRepository _announcementRepository = AnnouncementRepository();
  final ProjectIdeaRepository _projectIdeaRepository = ProjectIdeaRepository();
  late Future<List<Idea>> _ongoingIdeasFuture;

  @override
  void initState() {
    super.initState();
    _ongoingIdeasFuture = _projectIdeaRepository.fetchOngoingIdeas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Which to BluePrint?"),
      ),
      body: FutureBuilder<List<Idea>>(
        future: _ongoingIdeasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No ongoing projects found"));
          }

          final ideas = snapshot.data!;

          return ListView.builder(
            itemCount: ideas.length,
            itemBuilder: (context, index) {
              final idea = ideas[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to AiTodoScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AiTodoScreen(
                        ideaId: idea.id!,
                      ),
                    ),
                  );
                },
                child: ProjectIdeaCardWidget(
                  idea: idea,
                  repository: _projectIdeaRepository,
                  announcementRepository: _announcementRepository,
                  refreshIdeasInProfile: null,
                  cardGradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 14, 97, 176),
                      Color.fromARGB(255, 69, 142, 187)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
