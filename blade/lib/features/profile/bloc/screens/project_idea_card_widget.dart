import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:blade_app/features/announcement/src/announcement_repository.dart';
import 'package:blade_app/features/project_info/screens/project_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../utils/constants/colors.dart';
import '../../../GithubPoints/bloc/git_hub_points_bloc.dart';
import '../repository/project_idea_repository.dart';
import '../widgets/avatar_stack.dart';
import '../widgets/skill_tag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    _listenToPointsUpdates(); // Start listening to Firestore updates
  }

  void _listenToPointsUpdates() {
    FirebaseFirestore.instance
        .collection('ideas')
        .doc(widget.idea.id)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        setState(() {
          widget.idea.points = snapshot.data()!['points'] ?? 0; // Update points dynamically
        });
      }
    });
  }

  Future<void> _fetchRepoUrlIfNeeded() async {
    if (widget.idea.repoUrl == null || widget.idea.repoUrl!.isEmpty) {
      print("Fetching repo URL for project: ${widget.idea.title}");

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
            builder: (_) => ProjectScreen(
              canJoin: false,
              idea: widget.idea,
              repository: widget.announcementRepository,
              onJoinRequestSent: null,
              gitHubPointsBloc: BlocProvider.of<GitHubPointsBloc>(context), 
            ),
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
                          Flexible( // Ensure title doesn't overflow
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
                          SizedBox(width: screenWidth * 0.02),
                          SizedBox(
                            width: screenWidth * 0.2,
                            height: screenWidth * 0.1,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: AvatarStack(
                                userIds: widget.idea.members,
                                screenWidth: screenWidth,
                                repository: widget.repository,
                              ),
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
                                  value: (widget.idea.points / 500).clamp(0.0, 1.0), // Clamp to prevent overflow
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
