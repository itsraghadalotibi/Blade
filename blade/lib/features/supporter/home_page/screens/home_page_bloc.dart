import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_page_repository.dart';
import 'home_page_event.dart';
import 'home_page_state.dart';
import '../../../announcement/src/announcement_model.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserRepository userRepository;
  final ProjectRepository projectRepository;

  List<Idea> _allProjects = [];

  HomeBloc({required this.userRepository, required this.projectRepository}) : super(HomeLoading()) {
    on<LoadHomeData>((event, emit) async {
      try {
        final currentUser = await userRepository.getCurrentUser();
        final collaborators = await userRepository.getCollaborators();
        final projects = await projectRepository.getProjects();
        _allProjects = projects;

        emit(HomeLoaded(
          currentUser: currentUser,
          collaborators: collaborators,
          projects: projects,
        ));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });

    on<SearchProjectEvent>((event, emit) async {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        final filteredProjects = _allProjects.where((project) {
          return project.title.toLowerCase().contains(event.query.toLowerCase());
        }).toList();

        emit(HomeLoaded(
          currentUser: currentState.currentUser,
          collaborators: currentState.collaborators,
          projects: filteredProjects,
        ));
      }
    });

    on<ClearSearchEvent>((event, emit) async {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(HomeLoaded(
          currentUser: currentState.currentUser,
          collaborators: currentState.collaborators,
          projects: _allProjects,
        ));
      }
    });
  }
}
