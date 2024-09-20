part of 'announcement_bloc.dart';

abstract class AnnouncementState {}

class AnnouncementInitial extends AnnouncementState {}

class AnnouncementLoading extends AnnouncementState {}

class AnnouncementLoaded extends AnnouncementState {
  final List<Idea> ideas;

  AnnouncementLoaded({required this.ideas});
}

class AnnouncementError extends AnnouncementState {
  final String message;

  AnnouncementError({required this.message});
}
