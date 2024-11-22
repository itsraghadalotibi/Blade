import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../announcement/src/announcement_repository.dart';
import '../../../announcement/widgets/avatar_stack_widget.dart';

class LeaderboardWidget extends StatefulWidget {
  final List<Team> teams;
  final AnnouncementRepository repository;

  const LeaderboardWidget({
    super.key,
    required this.teams,
    required this.repository,
  });

  @override
  _LeaderboardWidgetState createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  bool _showAllProjects = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Leaderboard',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Top Projects',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Podium Section
          _buildPodiumSection(),
          const SizedBox(height: 20),
          // Leaderboard List
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _showAllProjects
                        ? widget.teams.length
                        : (widget.teams.length > 5 ? 5 : widget.teams.length),
                    itemBuilder: (context, index) {
                      final team = widget.teams[index];
                      return _buildTeamItem(context, team, index + 1);
                    },
                  ),
                ),
                if (widget.teams.length > 5)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _showAllProjects = !_showAllProjects;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                      ),
                      child: Text(
                        _showAllProjects ? 'Show Less' : 'Show More',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build Podium Section
  Widget _buildPodiumSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Second Place
        _buildPodiumItem(
          projectName: widget.teams.length > 1 ? widget.teams[1].name : 'N/A',
          color: Colors.grey,
          avatarUrl: 'assets/images/badges/silver.png',
        ),
        // First Place
        _buildPodiumItem(
          projectName: widget.teams.isNotEmpty ? widget.teams[0].name : 'N/A',
          color: Colors.amber,
          avatarUrl: 'assets/images/badges/gold.png',
          isTop: true,
        ),
        // Third Place
        _buildPodiumItem(
          projectName: widget.teams.length > 2 ? widget.teams[2].name : 'N/A',
          color: Colors.brown,
          avatarUrl: 'assets/images/badges/bronz.png',
        ),
      ],
    );
  }

  Widget _buildPodiumItem({
    required String projectName,
    required Color color,
    required String avatarUrl,
    bool isTop = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: isTop ? 30 : 25,
          backgroundImage: AssetImage(avatarUrl),
        ),
        const SizedBox(height: 8),
        Text(
          projectName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: isTop ? 100 : 80,
          width: 70,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  // Widget to build each team item
  Widget _buildTeamItem(BuildContext context, Team team, int rank) {
    Color getBackgroundColor(int rank) {
      switch (rank) {
        case 1:
          return const Color(0xFFFFD700).withOpacity(0.2);
        case 2:
          return const Color(0xFFC0C0C0).withOpacity(0.2);
        case 3:
          return const Color(0xFFCD7F32).withOpacity(0.2);
        default:
          return const Color.fromARGB(255, 208, 208, 208).withOpacity(0.2);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: getBackgroundColor(rank),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: rank == 1
                            ? const Color(0xFFFFD700)
                            : rank == 2
                                ? const Color(0xFFC0C0C0)
                                : rank == 3
                                    ? const Color(0xFFCD7F32)
                                    : const Color.fromARGB(255, 90, 90, 90),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$rank',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      team.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AvatarStackWidget(
                userIds: team.members,
                repository: widget.repository,
                screenWidth: MediaQuery.of(context).size.width,
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: LinearProgressIndicator(
                value: team.progress / 100,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Team {
  final String name;
  final List<String> members;
  final double progress;
  final int points;

  Team({
    required this.name,
    required this.members,
    required this.progress,
    required this.points,
  });

  factory Team.fromFirestore(Map<String, dynamic> data) {
    return Team(
      name: data['title'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      points: data['points'] ?? 0,
      progress: (data['points'] ?? 0) / 500 * 100,
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  final AnnouncementRepository repository;

  const LeaderboardScreen({super.key, required this.repository});

Future<List<Team>> _fetchTopTeams() async {
  try {
    print('Fetching top teams...');
    final snapshot = await FirebaseFirestore.instance
        .collection('ideas')
        .where('status', isEqualTo: 'ongoing') // Fetch only ongoing projects
        .orderBy('points', descending: true) // Order by points (highest first)
        .get();

    print('Query successful. Documents fetched: ${snapshot.docs.length}');

    final teams = snapshot.docs.map((doc) {
      final data = doc.data();

      // Log `isJoined` value for debugging
      print('Document data: ${data['title']} - isJoined: ${data['isJoined']}');
      
      return Team.fromFirestore(data);
    }).toList();

    print('Teams processed: ${teams.map((team) => 'Name: ${team.name}, Points: ${team.points}').toList()}');
    return teams;
  } catch (e, stackTrace) {
    print('Error fetching top teams: $e');
    print('Stack trace: $stackTrace');
    return [];
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: FutureBuilder<List<Team>>(
        future: _fetchTopTeams(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final teams = snapshot.data ?? [];
          return LeaderboardWidget(teams: teams, repository: repository);
        },
      ),
    );
  }
}
