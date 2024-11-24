// src/repositories/investment_request_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import 'investment_request_model.dart';

class InvestmentRequestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _investmentRequests =>
      _firestore.collection('investment_requests');

  // Create an investment request
  Future<void> createInvestmentRequest(InvestmentRequestModel request) async {
    await _investmentRequests.doc(request.id).set(request.toMap());
  }

  // Fetch investment requests for a specific project (Collaborator)
  Future<List<InvestmentRequestModel>> getInvestmentRequests(
      String projectId) async {
    final querySnapshot = await _investmentRequests
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) =>
            InvestmentRequestModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Fetch investment requests for a specific supporter (Supporter)
  Future<List<InvestmentRequestModel>> getInvestmentRequestsBySupporter(
      String supporterId) async {
    final querySnapshot = await _investmentRequests
        .where('supporterId', isEqualTo: supporterId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) =>
            InvestmentRequestModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
  Future<List<InvestmentRequestModel>> getInvestmentRequestsBySupporterForProject(
    String supporterId, String projectId) async {
  final querySnapshot = await _investmentRequests
      .where('supporterId', isEqualTo: supporterId)
      .where('projectId', isEqualTo: projectId)
      .orderBy('createdAt', descending: true)
      .get();

  return querySnapshot.docs
      .map((doc) =>
          InvestmentRequestModel.fromMap(doc.data() as Map<String, dynamic>))
      .toList();
}
  Future<void> cancelInvestmentRequest(String requestId) async {
    await _investmentRequests.doc(requestId).update({'status': 'Cancelled'});
  }

  Future<void> updateRequestStatus(String requestId, String status, {String? reasonForRejection}) async {
    final requestRef = _firestore.collection('investment_requests').doc(requestId);
    final data = {
      'status': status,
      'reasonForRejection': reasonForRejection,
    }..removeWhere((key, value) => value == null); // Only include non-null values
    await requestRef.update(data);
  }

  Future<List<InvestmentRequestModel>> getInvestmentRequestsForUserProjects(String userId) async {
  // Fetch projects where the user is a member
  final projectsSnapshot = await FirebaseFirestore.instance
      .collection('ideas')
      .where('members', arrayContains: userId)
      .get();

  final projectIds = projectsSnapshot.docs.map((doc) => doc.id).toList();

  // Handle Firestore limitation of 10 elements in `whereIn`
  List<InvestmentRequestModel> allRequests = [];
  int batchSize = 10;
  for (int i = 0; i < projectIds.length; i += batchSize) {
    final batchIds = projectIds.sublist(
      i,
      i + batchSize > projectIds.length ? projectIds.length : i + batchSize,
    );

    final requestsSnapshot = await _investmentRequests
        .where('projectId', whereIn: batchIds)
        .orderBy('createdAt', descending: true)
        .get();

    final requests = requestsSnapshot.docs
        .map((doc) => InvestmentRequestModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    allRequests.addAll(requests);
  }

  return allRequests;
}
}
