// home_page_state.dart

import 'package:equatable/equatable.dart';
import '../../../announcement/src/announcement_model.dart';

// Abstract HomeState class
abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Loading state
class HomeLoading extends HomeState {}

// Loaded state with collaborators, projects, filtered results, and selected tab
class HomeLoaded extends HomeState {
  final Collaborator? currentUser;
  final List<Collaborator> collaborators;
  final List<Idea> projects;
  final List<Collaborator> filteredCollaborators; // Filtered list of collaborators
  final List<Idea> filteredProjects; // Filtered list of projects
  final String selectedTab; // Active filter tab (either 'Projects' or 'Collaborators')

  HomeLoaded({
    required this.currentUser,
    required this.collaborators,
    required this.projects,
    required this.filteredCollaborators,
    required this.filteredProjects,
    required this.selectedTab,
  });

  // Copy method to update the properties of HomeLoaded state
  HomeLoaded copyWith({
    Collaborator? currentUser,
    List<Collaborator>? collaborators,
    List<Idea>? projects,
    List<Collaborator>? filteredCollaborators,
    List<Idea>? filteredProjects,
    String? selectedTab,
  }) {
    return HomeLoaded(
      currentUser: currentUser ?? this.currentUser,
      collaborators: collaborators ?? this.collaborators,
      projects: projects ?? this.projects,
      filteredCollaborators: filteredCollaborators ?? this.filteredCollaborators,
      filteredProjects: filteredProjects ?? this.filteredProjects,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }

  @override
  List<Object?> get props => [
        currentUser,
        collaborators,
        projects,
        filteredCollaborators,
        filteredProjects,
        selectedTab,
      ];
}

// Error state to handle any loading errors
class HomeError extends HomeState {
  final String message;

  HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
