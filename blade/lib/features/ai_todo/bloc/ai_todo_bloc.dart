// ai_todo_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'ai_todo_event.dart';
import 'ai_todo_state.dart';
import '../src/ai_todo_repository.dart';

class AiTodoBloc extends Bloc<AiTodoEvent, AiTodoState> {
  final AiTodoRepository repository;

  AiTodoBloc(this.repository) : super(AiTodoInitial()) {
    on<GenerateToDoList>((event, emit) async {
      emit(AiTodoLoading());
      try {
        final steps = await repository.generateToDoList(event.ideaId, event.projectDescription);
        emit(AiTodoLoaded(steps));
      } catch (e) {
        emit(AiTodoError("Failed to generate to-do list"));
      }
    });
  }
}
