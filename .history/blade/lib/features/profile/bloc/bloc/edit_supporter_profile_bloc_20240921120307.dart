import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'edit_supporter_profile_event.dart';
part 'edit_supporter_profile_state.dart';

class EditSupporterProfileBloc extends Bloc<EditSupporterProfileEvent, EditSupporterProfileState> {
  EditSupporterProfileBloc() : super(EditSupporterProfileInitial()) {
    on<EditSupporterProfileEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
