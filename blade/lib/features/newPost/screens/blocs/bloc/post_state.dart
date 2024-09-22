import 'package:equatable/equatable.dart';

// States for PostBloc
abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object> get props => [];
}

//  PostStepState to manage current step in the stepper
class PostStepState extends PostState {
  final int currentStep;

  const PostStepState(this.currentStep);

  @override
  List<Object> get props => [currentStep];
}

// State for when the post is being submitted (loading)
class SubmissionState extends PostState {
  const SubmissionState();
}

// State for when the post is submitted successfully
class PostSuccessState extends PostState {
  const PostSuccessState();
}

// State for when there is an error during post submission
class PostFailureState extends PostState {
  final String error;

  const PostFailureState(this.error);

  @override
  List<Object> get props => [error];
}
