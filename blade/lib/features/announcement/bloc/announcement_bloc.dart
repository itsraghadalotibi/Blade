import 'package:flutter_bloc/flutter_bloc.dart';
import '../src/announcement_repository.dart';
import '../src/announcement_model.dart';

part 'announcement_event.dart';
part 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final AnnouncementRepository repository;

  AnnouncementBloc({required this.repository}) : super(AnnouncementInitial()) {
    // Register the event handler for FetchAnnouncements
    on<FetchAnnouncements>((event, emit) async {
      emit(AnnouncementLoading());
      try {
        final ideas = await repository.fetchIdeas();
        emit(AnnouncementLoaded(ideas: ideas));
      } catch (e) {
        emit(AnnouncementError(message: e.toString()));
      }
    });
  }
}
