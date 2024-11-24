import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/ai_todo_list_item.dart';

class AiTodoScreen extends StatelessWidget {
  final String ideaId;

  static const List<Color> itemColors = [
    Color(0xFFFD5336), // Primary
    Color(0xFF4FE3C2), // Secondary
    Color(0xFF148fff), // Accent
  ];

  const AiTodoScreen({Key? key, required this.ideaId}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchTodoList() async {
    final doc = await FirebaseFirestore.instance
        .collection('ideas')
        .doc(ideaId)
        .collection('todoLists')
        .doc('generatedToDoList')
        .get();

    if (doc.exists) {
      final data = doc.data();
      final steps = data?['steps'] as List<dynamic>? ?? [];
      return steps.map((step) => step as Map<String, dynamic>).toList();
    } else {
      throw Exception("To-do list not found for idea ID: $ideaId");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF212121) : Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDarkMode
              ? const Color.fromARGB(255, 187, 185, 185) // Dark mode icon color
              : Colors.black, // Light mode icon color
        ),
        title: Text(
          'Project Generated Blueprint',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchTodoList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No to-do list found.',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            );
          }

          final steps = snapshot.data!;
          return ListView.builder(
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              final color = itemColors[index % itemColors.length];
              return AiTodoListItem(
                title: step['title'] ?? 'No Title',
                description: step['description'] ?? 'No Description',
                backgroundColor: color,
                stepNumber: index + 1,
              ).animate().fade(duration: 700.ms).slide();
            },
          );
        },
      ),
    );
  }
}
