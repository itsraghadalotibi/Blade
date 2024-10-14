// announcement_event.dart
part of 'announcement_bloc.dart';

abstract class AnnouncementEvent {}

class FetchAnnouncements extends AnnouncementEvent {
  final String currentUserId; // Add currentUserId

  FetchAnnouncements({required this.currentUserId});
}
