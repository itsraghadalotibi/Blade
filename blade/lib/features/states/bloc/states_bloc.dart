import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'states_event.dart';
import 'states_page_state.dart';

class StatesBloc extends Bloc<StatesEvent, StatesPageState> {
  final FirebaseFirestore _firestore;

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
          'status': requestData['status'],
          'timestamp': (requestData['timestamp'] as Timestamp).toDate(),
        });
      }

      emit(StatesLoaded(requests));
    } catch (e) {
      print('Error fetching join requests: $e');
      emit(StatesError(e.toString()));
    }
  }
}

