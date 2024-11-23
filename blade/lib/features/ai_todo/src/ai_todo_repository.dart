// ai_todo_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ai_todo_model.dart';

class AiTodoRepository {
  final String apiKey = 'I6MQ7ijtdeLIBPk1wuEPaD1LN7ghIGtqx7bUWwtM';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<List<ToDoStep>> generateToDoList(String ideaId, String projectDescription) async {
  // Check if a to-do list already exists for this idea
  final docRef = firestore
      .collection('ideas')
      .doc(ideaId)
      .collection('todoLists')
      .doc('generatedToDoList');

  final docSnapshot = await docRef.get();
  if (docSnapshot.exists) {
    print("To-do list already exists for idea ID: $ideaId. Skipping generation.");
    throw Exception('To-do list already generated for this idea.');
  }

  // Generate the to-do list if it doesn't exist
  final response = await http.post(
    Uri.parse('https://api.cohere.ai/generate'),
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json'
    },
    body: jsonEncode({
      'model': 'command-light',
      'prompt': 'Generate a high-level list of features and steps for achieving this project idea in a way that team members can understand the goals. Each step should include a title and a description. Format the response as follows: \n\nStep 1: (Title of Step 1)\nDescription for Step 1\n\nStep 2: (Title of Step 2)\nDescription for Step 2\n\nProject idea: $projectDescription',
      'max_tokens': 300,
      'temperature': 0.7,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final String stepsText = data['text']?.trim() ?? "";

    if (stepsText.isEmpty) {
      print("Error: No text found in API response.");
      throw Exception('No to-do list generated');
    }

    // Parse the steps into a list of `ToDoStep` objects
    List<ToDoStep> steps = parseSteps(stepsText);

    // Save the parsed steps to Firestore
    await saveToDoListToFirestore(ideaId, projectDescription, steps);

    return steps;
  } else {
    print("Error: HTTP ${response.statusCode} - ${response.body}");
    throw Exception('Failed to generate to-do list');
  }
}



Future<void> saveToDoListToFirestore(String ideaId, String description, List<ToDoStep> steps) async {
  final toDoList = steps.map((step) => {
    'title': step.title,
    'description': step.description,
  }).toList();

  await firestore
      .collection('ideas')
      .doc(ideaId)
      .collection('todoLists')
      .doc('generatedToDoList')
      .set({
    'description': description,
    'steps': toDoList,
    'createdAt': FieldValue.serverTimestamp(),
  });
}




List<ToDoStep> parseSteps(String stepsText) {
  List<ToDoStep> steps = [];
  List<String> lines = stepsText.split('\n');

  String? title;
  String description = "";

  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty) continue;

    if (line.startsWith("Step")) {
      if (title != null && description.isNotEmpty) {
        steps.add(ToDoStep(
          title: title,
          description: description,
        ));
      }
      
      // New Step: Capture title after "Step N: "
      final parts = line.split(':');
      title = parts.length > 1 ? parts[1].trim() : line;
      description = "";
    } else {
      // Accumulate description lines
      description += (description.isEmpty ? "" : " ") + line;
    }
  }

  // Save the last step if it exists
  if (title != null && description.isNotEmpty) {
    steps.add(ToDoStep(
      title: title,
      description: description,
    ));
  }

  return steps;
}

}
