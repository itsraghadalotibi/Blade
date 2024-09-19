import 'package:flutter_bloc/flutter_bloc.dart';
import '../../src/models/post_model.dart';
import '../../src/repositories/post_repo.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;  // Add PostRepository

  PostBloc({required this.postRepository}) : super(const PostStepState(0)) {
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
      // Create a PostModel using the data from SubmitStep event
      final post = PostModel(
        id: event.id,  // You can generate the ID or pass it from the event
        ideaName: event.ideaName,
        ideaDescription: event.ideaDescription,
        number: event.number,
        tags: event.tags,
        userId: event.userId, // The user ID of the person creating the post
      );

      // Call repository to submit the post
      await postRepository.createPost(post);

      // Emit success state after successful submission
      emit(const PostSuccessState());
    } catch (error) {
      // Emit failure state if any error occurs
      emit(PostFailureState(error.toString()));
    }
  }
}
