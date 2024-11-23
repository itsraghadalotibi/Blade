import 'package:equatable/equatable.dart';
import '../src/ai_todo_model.dart';

abstract class AiTodoState extends Equatable {
  const AiTodoState();

  @override
  List<Object> get props => [];
}

class AiTodoInitial extends AiTodoState {}

class AiTodoLoading extends AiTodoState {}

class AiTodoLoaded extends AiTodoState {
  final List<ToDoStep> steps;

  const AiTodoLoaded(this.steps);

  @override
  List<Object> get props => [steps];
}

class AiTodoError extends AiTodoState {
  final String message;

  const AiTodoError(this.message);

  @override
  List<Object> get props => [message];
}
