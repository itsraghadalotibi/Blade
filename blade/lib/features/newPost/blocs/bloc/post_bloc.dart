import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../announcement/src/announcement_model.dart';
import '../../../announcement/src/announcement_repository.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final AnnouncementRepository announcementRepository;

  PostBloc({required this.announcementRepository}) : super(const PostStepState(0)) {
    on<NextStep>(_onNextStep);
    on<PreviousStep>(_onPreviousStep);
    on<SubmitStep>(_onSubmitStep);
  }

  // Handle "Next" step navigation
  void _onNextStep(NextStep event, Emitter<PostState> emit) {
    final currentState = state;
    if (currentState is PostStepState && currentState.currentStep < 2) {
      emit(PostStepState(currentState.currentStep + 1));
    }
  }

  // Handle "Previous" step navigation
  void _onPreviousStep(PreviousStep event, Emitter<PostState> emit) {
    final currentState = state;
    if (currentState is PostStepState && currentState.currentStep > 0) {
      emit(PostStepState(currentState.currentStep - 1));
    }
  }

  // Handle form submission
  Future<void> _onSubmitStep(SubmitStep event, Emitter<PostState> emit) async {
    emit(const SubmissionState()); // Emit loading state when submission starts

    try {
      // Create an Idea using the data from SubmitStep event
      final idea = Idea(
        title: event.ideaName,
        description: event.ideaDescription,
        maxMembers: int.parse(event.number),
        members: [event.userId],  // Add the creator's user ID as the first member
        skills: event.tags,  // Pass the selected skills
      );

      // Call repository to submit the idea
      await announcementRepository.createIdea(idea, event.userId);

      // Emit success state after successful submission
      emit(const PostSuccessState());
    } catch (error) {
      // Emit failure state if any error occurs
      emit(PostFailureState(error.toString()));
    }
  }
}
