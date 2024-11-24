import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../GithubPoints/bloc/git_hub_points_bloc.dart';
import '../../../announcement/src/announcement_model.dart';
import '../../../announcement/src/announcement_repository.dart';
import '../../../investment_request/screens/investment_request_form.dart';
import '../../../investment_request/src/investment_request_model.dart';
import '../../../investment_request/src/investment_request_repository.dart';
import '../../../project_info/screens/project_screen.dart';
import '../../../../utils/constants/colors.dart';
import 'no_result_widget.dart'; // Import the new widget
import 'package:collection/collection.dart';
class ProjectsWidget extends StatefulWidget {
  final List<Idea> projects;
  final bool showDiscoverText;

  ProjectsWidget({
    required this.projects,
    this.showDiscoverText = true,
  });

  @override
  _ProjectsWidgetState createState() => _ProjectsWidgetState();
}

class _ProjectsWidgetState extends State<ProjectsWidget> {
  bool isExpanded = false;

  // State variables for investment requests
  Map<String, bool> _isInvestmentRequestPending = {};
  Map<String, String> _investmentButtonText = {};
  Map<String, int> _numPreviousRequests = {};
  Map<String, InvestmentRequestModel?> _existingInvestmentRequest = {};
  Map<String, List<InvestmentRequestModel>> _investmentRequests = {};
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      _fetchInvestmentRequestStatus();
    }
  }

  void _fetchInvestmentRequestStatus() async {
    if (currentUserId == null) return;
    final String userId = currentUserId!;

    // Fetch all investment requests by the user
    final allInvestmentRequests = await InvestmentRequestRepository()
        .getInvestmentRequestsBySupporter(userId);

    // Group investment requests by projectId
    Map<String, List<InvestmentRequestModel>> requestsByProject = {};

    for (var req in allInvestmentRequests) {
      final projectId = req.projectId;
      if (!requestsByProject.containsKey(projectId)) {
        requestsByProject[projectId] = [];
      }
      requestsByProject[projectId]!.add(req);
    }

    setState(() {
      for (var project in widget.projects) {
        final projectId = project.id!;
        final investmentRequests = requestsByProject[projectId] ?? [];

        if (investmentRequests.isNotEmpty) {
          // Sort requests by creation date
          investmentRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          // Use firstWhereOrNull to find the pending request
          final existingRequest = investmentRequests.firstWhereOrNull(
              (req) => req.status == 'Pending');

          final isPending = existingRequest != null;
          final buttonText = isPending ? 'Pending' : 'Invest';

          // Calculate number of previous requests excluding 'Pending'
          int previousRequestsCount = investmentRequests
              .where((req) => req.status != 'Pending')
              .length;

          _isInvestmentRequestPending[projectId] = isPending;
          _investmentButtonText[projectId] = buttonText;
          _existingInvestmentRequest[projectId] = existingRequest;
          _investmentRequests[projectId] = investmentRequests;
          _numPreviousRequests[projectId] = previousRequestsCount;
        } else {
          _isInvestmentRequestPending[projectId] = false;
          _investmentButtonText[projectId] = 'Invest';
          _existingInvestmentRequest[projectId] = null;
          _investmentRequests[projectId] = [];
          _numPreviousRequests[projectId] = 0;
        }
      }
    });
  }

  bool _doesTextOverflow(
      String text, TextStyle style, double maxWidth, int maxLines) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  void _handleSendInvestment(Idea project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvestmentRequestFormScreen(
          projectId: project.id!,
          projectTitle: project.title,
        ),
      ),
    ).then((_) {
      // After returning from the InvestmentRequestFormScreen, refresh the investment request status
      _fetchInvestmentRequestStatus();
    });
  }

  void _confirmCancelInvestmentRequest(String projectId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Cancel Investment Request"),
          content: const Text(
              "Are you sure you want to cancel your investment request?"),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _cancelInvestmentRequest(projectId);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _cancelInvestmentRequest(String projectId) async {
    final existingRequest = _existingInvestmentRequest[projectId];
    if (existingRequest == null) return;

    try {
      await InvestmentRequestRepository()
          .cancelInvestmentRequest(existingRequest.id);

      setState(() {
        _isInvestmentRequestPending[projectId] = false;
        _investmentButtonText[projectId] = 'Invest';
        _existingInvestmentRequest[projectId]?.status = 'Cancelled';
        _fetchInvestmentRequestStatus(); // Refresh the status
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Investment request cancelled.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showDiscoverText && widget.projects.isNotEmpty)
          const Text(
            'Discover Blade Projects',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        const SizedBox(height: 12),
        widget.projects.isEmpty
            ? const NoResultWidget(message: 'No projects found.')
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.projects.length,
                itemBuilder: (context, index) {
                  final project = widget.projects[index];
                  final projectId = project.id!;
                  final bool isCompleted = project.status == 'completed';
                  final Color statusColor = isCompleted
                      ? const Color(0xFF6C757D)
                      : const Color(0xFF148fff);

                  final bool exceedsMaxLines = _doesTextOverflow(
                    project.description,
                    TextStyle(
                      color: isDarkMode ? Colors.white : TColors.black,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                    313.0,
                    4,
                  );

                  final isPending =
                      _isInvestmentRequestPending[projectId] ?? false;
                  final buttonText =
                      _investmentButtonText[projectId] ?? 'Invest';
                  final previousRequestsCount =
                      _numPreviousRequests[projectId] ?? 0;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectScreen(
                            canSendComment: false,
                            idea: project,
                            repository: AnnouncementRepository(),
                            canJoin: false,
                            useInvestButton: true,
                            gitHubPointsBloc: BlocProvider.of<GitHubPointsBloc>(context), 
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: isDarkMode ? TColors.container : TColors.white,
                        border: isDarkMode
                            ? null
                            : Border.all(color: TColors.borderPrimary),
                        borderRadius: BorderRadius.circular(23),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                project.title,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : TColors.black,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(48),
                                ),
                                child: Text(
                                  isCompleted ? 'Completed' : 'Ongoing',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Description
                          Text(
                            project.description,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : TColors.black,
                              fontSize: 13.9,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
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
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          // Invest Button
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isPending
                                    ? Colors.amber[800]
                                    : TColors.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                if (isPending) {
                                  _confirmCancelInvestmentRequest(projectId);
                                } else {
                                  _handleSendInvestment(project);
                                }
                              },
                              child: Text(
                                buttonText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // Previous Requests Count
                          if (previousRequestsCount > 0) ...[
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                '$previousRequestsCount previous requests',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}