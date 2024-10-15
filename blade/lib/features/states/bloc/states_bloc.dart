import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'states_event.dart';
import 'states_page_state.dart';

class StatesBloc extends Bloc<StatesEvent, StatesPageState> {
  final FirebaseFirestore _firestore;

  StatesBloc(this._firestore) : super(StatesLoading()) {
    on<LoadAllProjectsRequests>(_onLoadAllProjectsRequests);
  }

  Future<void> _onLoadAllProjectsRequests(
      LoadAllProjectsRequests event, Emitter<StatesPageState> emit) async {
    try {
      emit(StatesLoading());

      final joinRequestsSnapshot = await _firestore
          .collection('join_requests')
          .where('userId', isEqualTo: event.requesterId)
          .get();

      if (joinRequestsSnapshot.docs.isEmpty) {
        emit(ProjectsLoaded([]));
        return;
      }

      Map<String, List<Map<String, dynamic>>> projectRequests = {};

      for (var doc in joinRequestsSnapshot.docs) {
        final requestData = doc.data();
        final ideaId = requestData['ideaId'] as String?;

        if (ideaId == null) continue;

        projectRequests.putIfAbsent(ideaId, () => []).add({
          'ideaTitle': requestData['ideaTitle'] ?? 'No Title',
          'status': requestData['status'] ?? 'Pending',
          'timestamp': (requestData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        });
      }

      final ideaIds = projectRequests.keys.toList();
      final ideasSnapshot = await _firestore
          .collection('ideas')
          .where(FieldPath.documentId, whereIn: ideaIds)
          .get();

      List<Map<String, dynamic>> projects = ideasSnapshot.docs.map((doc) {
        final title = doc.data()['title'] as String? ?? 'Unknown Project';
        return {'title': title, 'requests': projectRequests[doc.id] ?? []};
      }).toList();

      emit(ProjectsLoaded(projects));
    } catch (e) {
      emit(StatesError(e.toString()));
    }
  }
}