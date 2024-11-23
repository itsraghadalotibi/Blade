import 'package:flutter_bloc/flutter_bloc.dart';
import '../src/home_page_repository.dart';
import 'home_page_event.dart';
import 'home_page_state.dart';
import '../../../announcement/src/announcement_model.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserRepository userRepository;
  final ProjectRepository projectRepository;

  List<Idea> _allProjects = [];
  List<Collaborator> _allCollaborators = [];

  HomeBloc({required this.userRepository, required this.projectRepository}) : super(HomeLoading()) {
    on<LoadHomeData>((event, emit) async {
      try {
        final currentUser = await userRepository.getCurrentUser();
        final collaborators = await userRepository.getCollaborators();
        final projects = await projectRepository.getProjects();

        // Store fetched data in local variables for future filtering
        _allProjects = projects;
        _allCollaborators = collaborators;

        emit(HomeLoaded(
          currentUser: currentUser,
          collaborators: collaborators,
          projects: projects,
          filteredProjects: projects, // Set default filtered projects as all projects
          filteredCollaborators: collaborators, // Set default filtered collaborators as all collaborators
          selectedTab: 'Projects', // Default to 'Projects' tab
        ));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });

    on<SearchEvent>((event, emit) {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;

        // Filter projects and collaborators based on search query
        List<Idea> filteredProjects = _allProjects.where((project) =>
          project.title.toLowerCase().contains(event.query.toLowerCase())).toList();
        
        List<Collaborator> filteredCollaborators = _allCollaborators.where((collaborator) =>
          '${collaborator.firstName} ${collaborator.lastName}'.toLowerCase().contains(event.query.toLowerCase())).toList();

        // Emit a new state with updated filtered lists
        emit(currentState.copyWith(
          filteredProjects: filteredProjects,
          filteredCollaborators: filteredCollaborators,
        ));
      }
    });

    on<FilterTabChangedEvent>((event, emit) {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        // Update selectedTab in the state
        emit(currentState.copyWith(selectedTab: event.selectedTab));
      }
    });

    on<ClearSearchEvent>((event, emit) {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        // Reset filtered lists to the original unfiltered lists
        emit(currentState.copyWith(
          filteredProjects: _allProjects,
          filteredCollaborators: _allCollaborators,
        ));
      }
    });
  }
}
