// home_page_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_page_repository.dart';
import 'home_page_event.dart';
import 'home_page_state.dart';
import '../../../announcement/src/announcement_model.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserRepository userRepository;
  final ProjectRepository projectRepository;

  List<Idea> _allCompletedProjects = [];

  HomeBloc({required this.userRepository, required this.projectRepository}) : super(HomeLoading()) {
    on<LoadHomeData>((event, emit) async {
      try {
        final currentUser = await userRepository.getCurrentUser();
        final collaborators = await userRepository.getCollaborators();
        final completedProjects = await projectRepository.getCompletedProjects();
        _allCompletedProjects = completedProjects; // Cache original list

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

        final filteredProjects = _allCompletedProjects.where((project) {
          return project.title.toLowerCase().contains(event.query.toLowerCase());
        }).toList();

        emit(HomeLoaded(
          currentUser: currentState.currentUser,
          collaborators: currentState.collaborators,
          completedProjects: filteredProjects,
        ));
      }
    });

    on<ClearSearchEvent>((event, emit) async {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        
        emit(HomeLoaded(
          currentUser: currentState.currentUser,
          collaborators: currentState.collaborators,
          completedProjects: _allCompletedProjects,
        ));
      }
    });
  }
}
