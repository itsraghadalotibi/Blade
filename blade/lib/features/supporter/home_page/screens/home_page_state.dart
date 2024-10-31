import 'package:equatable/equatable.dart';
import '../../../announcement/src/announcement_model.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => []; // Use Object? to support nullable types
}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final Collaborator? currentUser; // Change to nullable
  final List<Collaborator> collaborators;
  final List<Idea> completedProjects; // Keeping this as List<Idea>

  HomeLoaded({
    required this.currentUser,
    required this.collaborators,
    required this.completedProjects,
  });

  @override
  List<Object?> get props => [currentUser, collaborators, completedProjects]; // Use Object? here too
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);

  @override
  List<Object?> get props => [message]; // Use Object? here too
}
