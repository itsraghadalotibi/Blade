import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:equatable/equatable.dart';

abstract class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final Idea idea;
  final bool isMember;
  final bool isOwner;

  const ProjectLoaded({
    required this.idea,
    required this.isMember,
    required this.isOwner,
  });

  // Adding copyWith method to update specific fields
  ProjectLoaded copyWith({
    Idea? idea,
    bool? isMember,
    bool? isOwner,
  }) {
    return ProjectLoaded(
      idea: idea ?? this.idea,
      isMember: isMember ?? this.isMember,
      isOwner: isOwner ?? this.isOwner,
    );
  }

  @override
  List<Object?> get props => [idea, isMember, isOwner];
}

class ProjectError extends ProjectState {
  final String message;

  const ProjectError(this.message);

  @override
  List<Object?> get props => [message];
}
