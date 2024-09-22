import 'package:equatable/equatable.dart';

// Events for PostBloc
abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

class NextStep extends PostEvent {}

class PreviousStep extends PostEvent {}

// Add necessary fields to SubmitStep event to pass data to the BLoC
class SubmitStep extends PostEvent {
  final String id;
  final String ideaName;
  final String ideaDescription;
  final String number;
  final List<String> tags;
  final String userId;  // Link the post to the user who submitted it

  const SubmitStep({
    required this.id,
    required this.ideaName,
    required this.ideaDescription,
    required this.number,
    required this.tags,
    required this.userId,
  });

  @override
  List<Object> get props => [id, ideaName, ideaDescription, number, tags, userId];
}
