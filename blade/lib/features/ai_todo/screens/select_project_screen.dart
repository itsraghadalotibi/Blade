import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../announcement/src/announcement_model.dart';
import '../../announcement/src/announcement_repository.dart';
import '../../profile/bloc/repository/project_idea_repository.dart';
import 'ai_todo_screen.dart';
import '../../GithubPoints/bloc/git_hub_points_bloc.dart';

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

          // Fetch and sort the ideas alphabetically
          final ideas = snapshot.data!..sort((a, b) => a.title.compareTo(b.title));

          return ListView.builder(
            itemCount: ideas.length,
            itemBuilder: (context, index) {
              final idea = ideas[index];
              return ProjectIdeaCardWidget(
                idea: idea,
                repository: _projectIdeaRepository,
                announcementRepository: _announcementRepository,
                refreshIdeasInProfile: null,
                cardGradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 14, 97, 176),
                    Color.fromARGB(255, 69, 142, 187),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProjectIdeaCardWidget extends StatefulWidget {
  final Idea idea;
  final ProjectIdeaRepository repository;
  final AnnouncementRepository announcementRepository;
  final Function()? refreshIdeasInProfile;
  final Gradient cardGradient;

  const ProjectIdeaCardWidget({
    super.key,
    required this.idea,
    required this.repository,
    required this.announcementRepository,
    required this.refreshIdeasInProfile,
    required this.cardGradient,
  });

  @override
  _ProjectIdeaCardWidgetState createState() => _ProjectIdeaCardWidgetState();
}

class _ProjectIdeaCardWidgetState extends State<ProjectIdeaCardWidget> {
  bool isExpanded = false;
  bool isLoading = true;
  String? fetchedRepoUrl;

  @override
  void initState() {
    super.initState();
    _fetchRepoUrlIfNeeded();
    _listenToPointsUpdates();
  }

  void _listenToPointsUpdates() {
    FirebaseFirestore.instance
        .collection('ideas')
        .doc(widget.idea.id)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        setState(() {
          widget.idea.points = snapshot.data()!['points'] ?? 0;
        });
      }
    });
  }

  Future<void> _fetchRepoUrlIfNeeded() async {
    if (widget.idea.repoUrl == null || widget.idea.repoUrl!.isEmpty) {
      final fetchedIdea = await widget.announcementRepository.getIdeaById(widget.idea.id!);

      if (fetchedIdea != null && fetchedIdea.repoUrl != null) {
        if (mounted) {
          setState(() {
            fetchedRepoUrl = fetchedIdea.repoUrl;
          });
        }
      }
    } else {
      fetchedRepoUrl = widget.idea.repoUrl;
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    final textStyle = TextStyle(
      fontSize: screenWidth * 0.04 * textScaleFactor,
      fontWeight: FontWeight.w400,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AiTodoScreen(ideaId: widget.idea.id!),
          ),
        ).then((_) {
          widget.refreshIdeasInProfile?.call();
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.05,
        ),
        child: Container(
          width: screenWidth * 0.9,
          decoration: BoxDecoration(
            gradient: widget.cardGradient,
            borderRadius: BorderRadius.circular(23),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.idea.title,
                              style: TextStyle(
                                fontSize: screenWidth * 0.055 * textScaleFactor,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final span = TextSpan(
                            text: widget.idea.description,
                            style: textStyle.copyWith(color: Colors.white),
                          );

                          final tp = TextPainter(
                            text: span,
                            maxLines: 4,
                            textAlign: TextAlign.left,
                            textDirection: TextDirection.ltr,
                          );

                          tp.layout(maxWidth: constraints.maxWidth);
                          bool exceedsMaxLines = tp.didExceedMaxLines;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.idea.description,
                                style: textStyle.copyWith(color: Colors.white),
                                maxLines: isExpanded ? null : 4,
                                overflow: isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                              ),
                              if (exceedsMaxLines)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isExpanded = !isExpanded;
                                    });
                                  },
                                  child: Text(
                                    isExpanded ? "Show less" : "Show more",
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 169, 168, 168),
                                      fontSize: screenWidth * 0.04 * textScaleFactor,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      if (widget.idea.status == 'ongoing')
                        Row(
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              icon: FaIcon(FontAwesomeIcons.github, color: Colors.white),
                              onPressed: fetchedRepoUrl != null && fetchedRepoUrl!.isNotEmpty
                                  ? () async {
                                      final repoUrl = fetchedRepoUrl!;
                                      if (await canLaunchUrl(Uri.parse(repoUrl))) {
                                        await launchUrl(Uri.parse(repoUrl),
                                            mode: LaunchMode.externalApplication);
                                      } else {
                                        print('Could not launch $repoUrl');
                                      }
                                    }
                                  : null,
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: (widget.idea.points / 500).clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey[200],
                                  color: Colors.greenAccent,
                                  minHeight: 8.0,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "${widget.idea.points} points",
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
  }
}
