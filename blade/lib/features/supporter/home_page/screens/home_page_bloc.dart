// home_page_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_page_repository.dart';
import 'home_page_event.dart';
import 'home_page_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserRepository userRepository;
  final ProjectRepository projectRepository;

  HomeBloc({required this.userRepository, required this.projectRepository}) : super(HomeLoading()) {
    on<LoadHomeData>((event, emit) async {
      try {
        final currentUser = await userRepository.getCurrentUser();
        final collaborators = await userRepository.getCollaborators();
        final completedProjects = await projectRepository.getCompletedProjects();

        if (currentUser != null) {
          emit(HomeLoaded(
            currentUser: currentUser,
            collaborators: collaborators,
            completedProjects: completedProjects,
          ));
        } else {
          emit(HomeError('User not found'));
        }
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });

    on<SearchProjectEvent>((event, emit) async {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;

        // Filter projects based on the search query
        final filteredProjects = currentState.completedProjects.where((project) {
          return project.title.toLowerCase().contains(event.query.toLowerCase());
        }).toList();

        emit(HomeLoaded(
          currentUser: currentState.currentUser,
          collaborators: currentState.collaborators,
          completedProjects: filteredProjects,
        ));
      }
    });
  }
}
