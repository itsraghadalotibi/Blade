class ToDoStep {
  final String title;
  final String description;

  ToDoStep({required this.title, required this.description});
}

class Project {
  final String id;
  final String name;
  final String status;

  Project({
    required this.id,
    required this.name,
    required this.status,
  });

  factory Project.fromFirestore(Map<String, dynamic> data, String id) {
    return Project(
      id: id,
      name: data['name'] as String,
      status: data['status'] as String,
    );
  }
}
