import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'states_event.dart';
import 'states_page_state.dart';

class StatesBloc extends Bloc<StatesEvent, StatesPageState> {
  final FirebaseFirestore _firestore;

  // StatesBloc(this._firestore) : super(StatesLoading()) {
  //   on<LoadAllProjectsRequests>(_onLoadAllProjectsRequests);
  // }

  // Future<void> _onLoadAllProjectsRequests(
  //     LoadAllProjectsRequests event, Emitter<StatesPageState> emit) async {
  //   try {
  //     emit(StatesLoading());

  //     // Fetch all join requests for the given user.
  //     final joinRequestsSnapshot = await _firestore
  //         .collection('join_requests')
  //         .where('userId', isEqualTo: event.requesterId)
  //         .get();

  //     if (joinRequestsSnapshot.docs.isEmpty) {
  //       emit(ProjectsLoaded([]));
  //       return;
  //     }

  //     // Collect the ideaIds from the join requests.
  //     List<String> ideaIds = joinRequestsSnapshot.docs
  //         .map((doc) => doc['ideaId'] as String)
  //         .toList();

  //     // Fetch idea data for the collected ideaIds.
  //     final ideasSnapshot = await _firestore
  //         .collection('ideas')
  //         .where(FieldPath.documentId, whereIn: ideaIds)
  //         .get();

  //     // Map ideaIds to their respective titles.
  //     Map<String, String> ideaTitles = {
  //       for (var doc in ideasSnapshot.docs) doc.id: doc.data()['title'] ?? 'Unknown Project'
  //     };

  //     // Build the list of project requests.
  //     List<Map<String, dynamic>> requests = joinRequestsSnapshot.docs.map((doc) {
  //       final data = doc.data();
  //       final ideaId = data['ideaId'] as String;
  //       return {
  //         'ideaTitle': ideaTitles[ideaId] ?? 'Unknown Idea',
  //         'status': data['status'] ?? 'pending',
  //         'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
  //       };
  //     }).toList();

  //     // Emit the loaded projects with their respective requests.
  //     emit(ProjectsLoaded(requests));
  //   } catch (e) {
  //     emit(StatesError(e.toString()));
  //   }
  // }
  StatesBloc(this._firestore) : super(StatesLoading()) {
    on<LoadStates>(_onLoadStates);
  }

  Future<void> _onLoadStates(
      LoadStates event, Emitter<StatesPageState> emit) async {
    try {
      emit(StatesLoading());

      // Query join_requests for the logged-in user
      final joinRequestsSnapshot = await _firestore
          .collection('join_requests')
          .where('userId', isEqualTo: event.requesterId)
          .get();

      if (joinRequestsSnapshot.docs.isEmpty) {
        emit(StatesLoaded([])); // No requests found
        return;
      }

      List<Map<String, dynamic>> requests = [];

      for (var doc in joinRequestsSnapshot.docs) {
        final requestData = doc.data();

        // Fetch the idea title from the 'ideas' collection
        final ideaSnapshot = await _firestore
            .collection('ideas')
            .doc(requestData['ideaId'])
            .get();

        final ideaData = ideaSnapshot.data();
        final ideaTitle = ideaData?['title'] ?? 'Unknown Idea'; // Handle missing title

        // Add the request along with the idea title to the list
        requests.add({
          'ideaTitle': ideaTitle,
          'status': requestData['status'] ?? "pending",
          'timestamp': ((requestData['timestamp'] ?? Timestamp.now()) as Timestamp).toDate(),
        });
      }

      emit(StatesLoaded(requests));
    } catch (e) {
      print('Error fetching join requests: $e');
      emit(StatesError(e.toString()));
    }
  }
}
