import 'package:equatable/equatable.dart';
import '../src/NotificationModel.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;

  const NotificationLoaded(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String error;

  const NotificationError(this.error);

  @override
  List<Object?> get props => [error];
}

class NotificationUpdated extends NotificationState {}

class NotificationDeleted extends NotificationState {}
