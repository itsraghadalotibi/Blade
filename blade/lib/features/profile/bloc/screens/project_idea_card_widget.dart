import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:blade_app/features/announcement/src/announcement_repository.dart';
import 'package:blade_app/features/project_info/screens/project_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../utils/constants/colors.dart';
import '../../../GithubPoints/bloc/git_hub_points_bloc.dart';
import '../../../GithubPoints/bloc/git_hub_points_event.dart';
import '../../../GithubPoints/bloc/git_hub_points_state.dart';
import '../repository/project_idea_repository.dart';
import '../widgets/avatar_stack.dart';
import '../widgets/skill_tag.dart';

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
  late GitHubPointsBloc _gitHubPointsBloc;
  bool isLoading = true;
  String? fetchedRepoUrl;

  @override
  void initState() {
    super.initState();

    _gitHubPointsBloc = GitHubPointsBloc();

    _fetchRepoUrlIfNeeded();
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
      if (fetchedRepoUrl != null && fetchedRepoUrl!.isNotEmpty) {
        _gitHubPointsBloc.add(FetchGitHubPointsEvent(fetchedRepoUrl!));
      }
    }
  }

  @override
  void dispose() {
    _gitHubPointsBloc.close();
    super.dispose();
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

    return BlocProvider.value(
      value: _gitHubPointsBloc,
      child: BlocBuilder<GitHubPointsBloc, GitHubPointsState>(
        builder: (context, state) {
          double progressValue = 0.0;
          if (state is GitHubPointsLoaded) {
            progressValue = state.progress;
          }

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
                                Expanded(
                                  child: Text(
                                    widget.idea.title,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.055 * textScaleFactor,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
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
                                            color: const Color.fromARGB(255, 255, 255, 255),
                                            fontSize: screenWidth * 0.04 * textScaleFactor,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            if (widget.idea.members[0] ==
                                    FirebaseAuth.instance.currentUser?.uid &&
                                widget.idea.requestCount != null &&
                                widget.idea.requestCount != 0) ...[
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                "Number of requests is ${widget.idea.requestCount!}",
                                style: textStyle.copyWith(color: Colors.white),
                              ),
                            ],
                            SizedBox(height: screenHeight * 0.01),
                            SizedBox(
                              height: screenHeight * 0.05,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: widget.idea.skills
                                      .map((skill) => SkillTagWidget(skills: [skill]))
                                      .toList(),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            if (widget.idea.status == 'ongoing')
                              Row(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: FaIcon(FontAwesomeIcons.github, color: Colors.white),
                                    onPressed: fetchedRepoUrl != null && fetchedRepoUrl!.isNotEmpty
                                        ? () async {
                                            final repoUrl = fetchedRepoUrl!;
                                            print("Repo URL being launched: $repoUrl");
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
                                        value: progressValue,
                                        backgroundColor: Colors.grey[200],
                                        color: Colors.greenAccent,
                                        minHeight: 8.0,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      "${(progressValue * 500).toInt()}/500",
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
      ),
    );
  }
}
