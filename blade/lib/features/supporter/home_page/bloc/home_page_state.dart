// Updated HomeState in home_page_state.dart

import 'package:equatable/equatable.dart';
import '../../../announcement/src/announcement_model.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final Collaborator? currentUser;
  final List<Collaborator> collaborators;
  final List<Idea> projects; // Updated to general term "projects"

  HomeLoaded({
    required this.currentUser,
    required this.collaborators,
    required this.projects,
  });

  @override
  List<Object?> get props => [currentUser, collaborators, projects];
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
