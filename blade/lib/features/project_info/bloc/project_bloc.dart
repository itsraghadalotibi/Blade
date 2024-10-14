import 'package:bloc/bloc.dart';
import '../../announcement/src/announcement_repository.dart';
import 'project_event.dart'; // Import the events
import 'project_state.dart'; // Import the states

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final AnnouncementRepository repository;
  final String currentUserId;

  ProjectBloc(this.repository, this.currentUserId) : super(ProjectLoading()) {
    on<FetchProjectDetails>(_onFetchProjectDetails);
    on<JoinProject>(_onJoinProject);
    on<LeaveProject>(_onLeaveProject);
    on<UpdateProjectStatus>(_onUpdateProjectStatus);
  }

  Future<void> _onFetchProjectDetails(FetchProjectDetails event, Emitter<ProjectState> emit) async {
    try {
      final idea = await repository.getIdeaById(event.ideaId);
      
      // Ensure the idea object and its members list are not null
      if (idea != null) {
        final members = idea.members;
        final bool isOwner = members.isNotEmpty && members[0] == currentUserId;
        final bool isMember = members.contains(currentUserId);
        emit(ProjectLoaded(idea: idea, isMember: isMember, isOwner: isOwner));
      } else {
        emit(const ProjectError('Project not found.'));
      }
    } catch (e) {
      emit(const ProjectError('Error fetching project details.'));
    }
  }

  Future<void> _onJoinProject(JoinProject event, Emitter<ProjectState> emit) async {
    try {
      await repository.addMemberToIdea(event.ideaId, currentUserId);
      final idea = await repository.getIdeaById(event.ideaId); // Refetch the idea to get updated member list
      
      if (idea != null) {
        final members = idea.members;
        final bool isOwner = members.isNotEmpty && members[0] == currentUserId;
        final bool isMember = members.contains(currentUserId);
        emit(ProjectLoaded(idea: idea, isMember: isMember, isOwner: isOwner));
      } else {
        emit(const ProjectError('Project not found.'));
      }
    } catch (e) {
      emit(const ProjectError('Error joining project.'));
    }
  }

  Future<void> _onLeaveProject(LeaveProject event, Emitter<ProjectState> emit) async {
    try {
      await repository.removeMemberFromIdea(event.ideaId, currentUserId);
      final idea = await repository.getIdeaById(event.ideaId); // Refetch the idea to get updated member list
      
      if (idea != null) {
        final members = idea.members;
        final bool isOwner = members.isNotEmpty && members[0] == currentUserId;
        final bool isMember = members.contains(currentUserId);
        emit(ProjectLoaded(idea: idea, isMember: isMember, isOwner: isOwner));
      } else {
        emit(const ProjectError('Project not found.'));
      }
    } catch (e) {
      emit(const ProjectError('Error leaving project.'));
    }
  }

  Future<void> _onUpdateProjectStatus(
      UpdateProjectStatus event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      await repository.updateIdeaStatus(event.ideaId, event.newStatus);
      final updatedIdea = await repository.getIdeaById(event.ideaId);
      if (updatedIdea != null) {
        final isOwner = updatedIdea.members.isNotEmpty && updatedIdea.members[0] == currentUserId;
        final isMember = updatedIdea.members.contains(currentUserId);
        emit(ProjectStatusUpdated(updatedIdea));
        emit(ProjectLoaded(
          idea: updatedIdea,
          isOwner: isOwner,
          isMember: isMember,
        ));
      } else {
        emit(ProjectError('Project not found after status update.'));
      }
    } catch (e) {
      emit(ProjectError('Failed to update project status: $e'));
    }
  }
  
}
