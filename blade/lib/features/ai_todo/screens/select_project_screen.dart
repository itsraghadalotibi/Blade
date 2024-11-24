import 'package:flutter/material.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';
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
  int _currentPageIndex = 0; // Track the currently focused page index

  @override
  void initState() {
    super.initState();
    _ongoingIdeasFuture = _projectIdeaRepository.fetchOngoingIdeas();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

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

          // Generate card widgets
          final List<Widget> cards = List.generate(ideas.length, (index) {
            if (index == _currentPageIndex) {
              // Focused card: Display full details
              return ProjectIdeaCardWidget(
                idea: ideas[index],
                repository: _projectIdeaRepository,
                announcementRepository: _announcementRepository,
                refreshIdeasInProfile: null,
                cardGradient: const LinearGradient(
                  colors: [Color.fromARGB(255, 14, 97, 176), Color.fromARGB(255, 69, 142, 187)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              );
            } else {
              // Non-focused cards: Only display the title with background gradient
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 14, 97, 176), Color.fromARGB(255, 69, 142, 187)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  ideas[index].title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              );
            }
          });

          // Generate titles
          final List<String> titles = ideas.map((idea) => idea.title).toList();

          return Center(
            child: VerticalCardPager(
              titles: titles,
              images: cards,
              textStyle: const TextStyle(
                color: Colors.transparent, // Hide text by default
                fontWeight: FontWeight.bold,
              ),
              onPageChanged: (page) {
                if (page != null) {
                  setState(() {
                    _currentPageIndex = page.toInt(); // Safely convert double to int
                  });
                  print("Current Page: $page");
                }
              },
              onSelectedItem: (index) {
                // Navigate to AiTodoScreen when a card is selected
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AiTodoScreen(
                      ideaId: ideas[index].id!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
