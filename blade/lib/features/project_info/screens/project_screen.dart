import 'package:blade_app/features/investment_request/src/investment_request_repository.dart';
import 'package:blade_app/features/project_info/screens/offers_tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/constants/colors.dart';
import '../../../widgets/expandable_text.dart';
import '../../announcement/src/announcement_model.dart';
import '../../announcement/src/announcement_repository.dart';
import '../../announcement/widgets/skill_tag_widget.dart';
import '../../investment_request/bloc/investment_request_bloc.dart';
import '../../investment_request/bloc/investment_request_event.dart';
import '../../investment_request/screens/investment_request_form.dart';
import '../../investment_request/screens/invsetment_request_list.dart';
import '../bloc/project_bloc.dart';
import '../bloc/project_event.dart';
import '../bloc/project_state.dart';
import 'posts_tab.dart';
import 'members_tab.dart';
import 'project_settings_screen.dart';
import 'dollar.dart'; // Import the DollarIcon class
import 'package:url_launcher/url_launcher.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProjectScreen extends StatefulWidget {
  final Idea idea;
  final AnnouncementRepository repository;
  final bool canJoin;
  final Function()? refershIdeasInProfile;
  final Function()? onJoinRequestSent;
  final bool useInvestButton;

  const ProjectScreen({
    super.key,
    required this.idea,
    required this.repository,
    required this.canJoin,
    this.onJoinRequestSent, //Make it optional BC the supporter call does not provide it
    this.refershIdeasInProfile,
    this.useInvestButton = false, // For supporter
  });

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  bool _isRequestPending = false;
  bool _isMember = false;
  String? _joinRequestId;
  String _buttonText = 'Join';
  String? currentUserId;
  String? userType;
  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      _fetchUserType(); // Fetch user type
    }
    _checkJoinRequestStatus();
  }

  // Function to fetch the user type (collaborator or supporter)
  void _fetchUserType() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('collaborators')
          .doc(currentUserId)
          .get();
      if (userDoc.exists) {
        setState(() {
          userType = 'collaborator';
        });
      } else {
        setState(() {
          userType = 'supporter';
        });
      }
    } catch (e) {
      print('Error fetching user type: $e');
    }
  }

  // Check the join request status
  Future<void> _checkJoinRequestStatus() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final String ideaId = widget.idea.id!;

    final snapshot = await FirebaseFirestore.instance
        .collection('join_requests')
        .where('ideaId', isEqualTo: ideaId)
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final status = snapshot.docs.first['status'];
      _joinRequestId = snapshot.docs.first.id;

      setState(() {
        if (status == 'pending') {
          _buttonText = 'Pending...';
          _isRequestPending = true;
        } else if (status == 'accepted') {
          _buttonText = 'Leave Project';
          _isMember = true;
        }
      });
    }
  }

  // Getter for dynamic button background color
  Color get _buttonBackgroundColor {
    if (_isRequestPending) {
      return Colors.amber[800]!; // Grey for pending state
    } else if (widget.useInvestButton) {
      return TColors.primary;
    } else {
      return TColors.primary; // Red for join project
    }
  }

  // Send join request
  Future<void> _sendJoinRequest() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final String ideaId = widget.idea.id!;

    setState(() {
      _buttonText = 'Pending...';
      _isRequestPending = true;
    });

    try {
      final docRef =
          await FirebaseFirestore.instance.collection('join_requests').add({
        'ideaId': ideaId,
        'userId': userId,
        'status': 'pending',
        'timestamp': Timestamp.now(),
      });

      _joinRequestId = docRef.id;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Join request sent successfully!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 3),
          showCloseIcon: true,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() {
        _buttonText = 'Join';
        _isRequestPending = false;
      });
    }
  }

  void _handleSendInvestment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvestmentRequestFormScreen(
          projectId: widget.idea.id!,
          projectTitle: widget.idea.title,
        ),
      ),
    );
  }

  // Function to cancel a join request.
  Future<void> _cancelJoinRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('join_requests')
          .doc(requestId)
          .delete();
      print('Join request $requestId cancelled successfully');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.cancel, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Join request cancelled.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 3),
          showCloseIcon: true,
        ),
      );

      setState(() {
        _buttonText = 'Join';
        _isRequestPending = false;
        _joinRequestId = null;
      });
    } catch (e) {
      print('Error cancelling join request: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error cancelling join request: $e'),
          duration: const Duration(seconds: 3),
          showCloseIcon: true,
        ),
      );
    }
  }

  // Leave project
  Future<void> _leaveProject() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final String ideaId = widget.idea.id!;

    try {
      await widget.repository.removeMemberFromIdea(ideaId, userId);

      if (_joinRequestId != null) {
        await FirebaseFirestore.instance
            .collection('join_requests')
            .doc(_joinRequestId)
            .delete();
        _joinRequestId = null;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.exit_to_app, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You have left the project.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );

      setState(() {
        _isMember = false;
        _buttonText = 'Join';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProjectBloc(
          widget.repository, FirebaseAuth.instance.currentUser?.uid ?? '')
        ..add(FetchProjectDetails(widget.idea.id!)),
      child: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, state) {
          if (state is ProjectLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Loading...')),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is ProjectError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Center(
                child: Text(
                  state.message,
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
            );
          } else if (state is ProjectLoaded) {
            final idea = state.idea;
            final bool isOwner = state.isOwner;
            final bool isDarkMode =
                Theme.of(context).brightness == Brightness.dark;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Project details'),
                centerTitle: true,
                actions: [
                  if (userType == 'collaborator' &&
                      idea.status != 'open' &&
                      (_isMember || isOwner))
                    IconButton(
                      icon: const Icon(Icons.mail), // Use envelope icon
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => InvestmentRequestBloc(
                                repository:
                                    context.read<InvestmentRequestRepository>(),
                              )..add(FetchInvestmentRequests(
                                  projectId: widget
                                      .idea.id!)), // Fetch requests on creation
                              child: InvestmentRequestsListScreen(
                                projectId: widget.idea.id!,
                                isOwner:
                                    isOwner, // pass the `isOwner` parameter if you have it available
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  if (userType == 'collaborator' &&
                      isOwner &&
                      (idea.status == 'open' || idea.status == 'ongoing'))
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectSettingsScreen(
                              idea: idea,
                              repository: widget.repository,
                            ),
                          ),
                        ).then((_) {
                          context
                              .read<ProjectBloc>()
                              .add(FetchProjectDetails(idea.id!));
                        });
                      },
                    ),
                ],
              ),
              resizeToAvoidBottomInset: false,
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  idea.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ExpandableTextWidget(
                                  text: idea.description,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.grey[800],
                                  ),
                                  maxLines: 4,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(idea.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              idea.status[0].toUpperCase() +
                                  idea.status.substring(1),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SkillTagWidget(skills: idea.skills),
                      ),
                    ),
                    if (userType == 'collaborator' &&
                        ((!isOwner && idea.status == 'open') ||
                            widget.useInvestButton)) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonBackgroundColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 36, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if ((_isRequestPending && _joinRequestId != null)) {
                              // Cancel the join request
                              _cancelJoinRequest(_joinRequestId!);
                            } else if (_isMember) {
                              // Leave the project
                              _leaveProject();
                            } else {
                              // Send a join request
                              _sendJoinRequest();
                            }
                          },
                          child: Text(
                            _buttonText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (userType == 'collaborator' &&
                        ((!isOwner && idea.status == 'open') ||
                            widget.useInvestButton)) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonBackgroundColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 36, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if ((_isRequestPending && _joinRequestId != null)) {
                              // Cancel the join request
                              _cancelJoinRequest(_joinRequestId!);
                            } else if (_isMember) {
                              // Leave the project
                              _leaveProject();
                            } else {
                              // Send a join request
                              _sendJoinRequest();
                            }
                          },
                          child: Text(
                            _buttonText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (userType == 'collaborator' &&
                        (_isMember || isOwner)) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                TColors.primary, // Match your app's style
                            padding: const EdgeInsets.symmetric(
                                horizontal: 36, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: idea.repoUrl != null
                              ? () async {
                                  final url = idea.repoUrl!;
                                  if (await canLaunchUrl(Uri.parse(url))) {
                                    await launchUrl(Uri.parse(url));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Could not open GitHub repository.'),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          icon: const FaIcon(
                            FontAwesomeIcons.github, // Official GitHub icon
                            size: 20, // Adjust the size if necessary
                            color: Colors.white, // Match the text color
                          ),
                          label: const Text(
                            'GitHub',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (userType == 'supporter') ...[
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 36, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _handleSendInvestment,
                          child: const Text(
                            'Invest',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: DefaultTabController(
                        length: 2 +
                            (userType == 'collaborator' &&
                                    isOwner &&
                                    idea.status == "open"
                                ? 1
                                : 0),
                        child: Column(
                          children: [
                            TabBar(
                              onTap: (v) {
                                setState(() {
                                  tabIndex = v;
                                });
                              },
                              indicatorColor: Theme.of(context).primaryColor,
                              labelColor: Theme.of(context).primaryColor,
                              unselectedLabelColor:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                              tabs: [
                                const Tab(text: 'Posts'),
                                const Tab(text: 'Members'),
                                if (userType == 'collaborator' &&
                                    isOwner &&
                                    idea.status == "open")
                                  const Tab(text: 'Requests'),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  PostsTab(fromHome: false, idea: idea),
                                  MembersTab(
                                      idea: idea,
                                      repository: widget.repository),
                                  if (userType == 'collaborator' &&
                                      isOwner &&
                                      idea.status == "open")
                                    OffersTab(
                                      idea: idea,
                                      repository: widget.repository,
                                      addNewMember: (id) {
                                        idea.members.add(id);
                                        final bool isFull =
                                            (idea.members.length) >=
                                                idea.maxMembers;
                                        if (isFull) {
                                          idea.status = "ongoing";
                                          widget.repository.updateIdeaStatus(
                                              idea.id!, 'ongoing');
                                        }
                                        setState(() {});
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.green;
      case 'ongoing':
        return Colors.blue;
      case 'completed':
        return Colors.grey[600]!;
      default:
        return Colors.black;
    }
  }
}
