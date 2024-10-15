import 'package:flutter_bloc/flutter_bloc.dart';
import '../screens/announcement_screen.dart';
import '../src/announcement_repository.dart';
import '../src/announcement_model.dart';

part 'announcement_event.dart';
part 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final AnnouncementRepository repository;

  AnnouncementBloc({required this.repository}) : super(AnnouncementInitial()) {
    on<FetchAnnouncements>((event, emit) async {
      // Listen to the stream of ideas
      emit(AnnouncementLoading());
      try {
        // Fetch ideas while excluding those owned by the current user
        final ideas = await repository.fetchIdeas(event.currentUserId);
        emit(AnnouncementLoaded(ideas: ideas));
      } catch (e) {
        emit(AnnouncementError(message: e.toString()));
      }
      // await emit.onEach<List<Idea>>(
      //   repository.streamIdeas(event.currentUserId),
      //   onData: (ideas) => emit(AnnouncementLoaded(ideas: ideas)),
      //   onError: (error, stackTrace) => emit(AnnouncementError(message: error.toString())),
      // );
    });
  }
}
