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
  final bool isOwner;
  final bool isMember;

  const ProjectLoaded({
    required this.idea,
    required this.isOwner,
    required this.isMember,
  });

  @override
  List<Object?> get props => [idea, isOwner, isMember];
}

class ProjectStatusUpdated extends ProjectState {
  final Idea updatedIdea;

  const ProjectStatusUpdated(this.updatedIdea);

  @override
  List<Object?> get props => [updatedIdea];
}

class ProjectError extends ProjectState {
  final String message;

  const ProjectError(this.message);

  @override
  List<Object?> get props => [message];
}
