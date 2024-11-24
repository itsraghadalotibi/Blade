// ai_todo_event.dart

import 'package:equatable/equatable.dart';

abstract class AiTodoEvent extends Equatable {
  const AiTodoEvent();

  @override
  List<Object> get props => [];
}

class GenerateToDoList extends AiTodoEvent {
  final String ideaId;
  final String projectDescription;

  const GenerateToDoList(this.ideaId, this.projectDescription);

  @override
  List<Object> get props => [ideaId, projectDescription];
}
