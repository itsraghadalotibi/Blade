import 'package:equatable/equatable.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

class FetchProjectDetails extends ProjectEvent {
  final String ideaId;

  const FetchProjectDetails(this.ideaId);

  @override
  List<Object?> get props => [ideaId];
}

class JoinProject extends ProjectEvent {
  final String ideaId;
  const JoinProject(this.ideaId);
}

class LeaveProject extends ProjectEvent {
  final String ideaId;
  const LeaveProject(this.ideaId);
}

class UpdateProjectStatus extends ProjectEvent {
  final String ideaId;
  final String newStatus;
  
  const UpdateProjectStatus(this.ideaId, this.newStatus);

  @override
  List<Object?> get props => [ideaId, newStatus];
}
