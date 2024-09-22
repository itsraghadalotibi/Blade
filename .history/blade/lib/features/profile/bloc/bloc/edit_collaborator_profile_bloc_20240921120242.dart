import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'edit_collaborator_profile_event.dart';
part 'edit_collaborator_profile_state.dart';

class EditCollaboratorProfileBloc extends Bloc<EditCollaboratorProfileEvent, EditCollaboratorProfileState> {
  EditCollaboratorProfileBloc() : super(EditCollaboratorProfileInitial()) {
    on<EditCollaboratorProfileEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
