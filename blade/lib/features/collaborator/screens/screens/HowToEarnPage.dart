// HowToEarnPage.dart
import 'package:flutter/material.dart';

class HowToEarnPage extends StatelessWidget {
  const HowToEarnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("How to Earn"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildChallengeTile(
              points: "15",
              description: "Boost your contributions by committing your first 10 lines of code!",
              icon: Icons.bolt,
              emoji: "🚀",
            ),
            _buildChallengeTile(
              points: "30",
              description: "Power up your progress by adding 30 lines of code across multiple commits!",
              icon: Icons.code,
              emoji: "💥",
            ),
            _buildChallengeTile(
              points: "10",
              description: "Join the conversation! Earn points every time you comment on a pull request.",
              icon: Icons.chat_bubble_outline,
              emoji: "💬",
            ),
            _buildChallengeTile(
              points: "40",
              description: "Problem solved! Close an issue with a fix and earn big rewards.",
              icon: Icons.build,
              emoji: "🛠️",
            ),
            _buildChallengeTile(
              points: "10",
              description: "Share your journey! Add a new post to a project and watch the XP roll in.",
              icon: Icons.campaign,
              emoji: "📢",
            ),
            _buildChallengeTile(
              points: "5",
              description: "Get social! Earn XP for every reaction your posts receive.",
              icon: Icons.fireplace,
              emoji: "🔥",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeTile({required String points, required String description, required IconData icon, required String emoji}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star, // Star icon
                        color: Colors.amber, // Set color to yellow/gold for the star
                        size: 20, // Adjust size as needed
                      ),
                      const SizedBox(width: 4), // Space between icon and text
                      Text(
                        "$points point",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
