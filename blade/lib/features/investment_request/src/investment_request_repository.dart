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

  // Fetch investment requests for a project
  Future<List<InvestmentRequestModel>> getInvestmentRequestsByProject(
      String projectId) async {
    final querySnapshot = await _investmentRequests
        .where('projectId', isEqualTo: projectId)
        .get();

    return querySnapshot.docs
        .map((doc) =>
            InvestmentRequestModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
