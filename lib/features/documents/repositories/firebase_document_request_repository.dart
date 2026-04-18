import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/domain/entities/document_request.entity.dart';
import 'package:ngo_volunteer_management/features/documents/repositories/document_request_repository.dart';

class FirebaseDocumentRequestRepository implements IDocumentRequestRepository {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('document_requests');

  @override
  Stream<List<DocumentRequestEntity>> watchAll() {
    return _collection
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DocumentRequestEntity.fromMap(data, doc.id);
      }).toList();
    });
  }

  @override
  Future<List<DocumentRequestEntity>> getAll() async {
    final querySnapshot =
        await _collection.orderBy('requestedAt', descending: true).get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return DocumentRequestEntity.fromMap(data, doc.id);
    }).toList();
  }

  @override
  Future<DocumentRequestEntity> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Document Request not found');
    }
    return DocumentRequestEntity.fromMap(
        doc.data() as Map<String, dynamic>, doc.id);
  }

  @override
  Future<void> add(DocumentRequestEntity request) async {
    // Generate UUID if empty or let Firestore auto-generate. Let Firestore auto-generate ID.
    final data = request.toMap();
    data.remove('id'); // Remove local pseudo-ID
    await _collection.add(data);
  }

  @override
  Future<void> update(DocumentRequestEntity request) async {
    if (request.id.isEmpty) throw Exception("Cannot update without ID");
    await _collection.doc(request.id).update(request.toMap());
  }

  @override
  Future<void> updateStatus(
      String id, DocumentRequestStatus status,
      {String? approvedBy, String? certificateNo,
       String? organisation, String? internshipArea, String? internshipDuration}) async {
    final data = <String, dynamic>{
      'status': status.name,
      if (status == DocumentRequestStatus.approved) 'approvedAt': DateTime.now().toIso8601String(),
    };
    if (approvedBy != null) data['approvedBy'] = approvedBy;
    if (certificateNo != null) data['certificateNo'] = certificateNo;
    if (organisation != null) data['organisation'] = organisation;
    if (internshipArea != null) data['internshipArea'] = internshipArea;
    if (internshipDuration != null) data['internshipDuration'] = internshipDuration;

    await _collection.doc(id).update(data);
  }
}
