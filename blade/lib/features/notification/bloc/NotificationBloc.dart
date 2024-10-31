import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_event.dart';
import 'notification_state.dart';
import '../src/NotificationModel.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FirebaseFirestore firestore;

  NotificationBloc({required this.firestore}) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<DeleteNotification>(_onDeleteNotification);
  }

  Future<void> _onLoadNotifications(
      LoadNotifications event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final querySnapshot = await firestore
          .collection('notifications')
          .where('userId', isEqualTo: event.userId)
          .orderBy('timestamp', descending: true)
          .get();

      final notifications = querySnapshot.docs.map((doc) {
        return NotificationModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkNotificationAsRead(
      MarkNotificationAsRead event, Emitter<NotificationState> emit) async {
    try {
      await firestore
          .collection('notifications')
          .doc(event.notificationId)
          .update({
        'read': true,
      });
      emit(NotificationUpdated());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onDeleteNotification(
      DeleteNotification event, Emitter<NotificationState> emit) async {
    try {
      await firestore
          .collection('notifications')
          .doc(event.notificationId)
          .delete();
      emit(NotificationDeleted());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
