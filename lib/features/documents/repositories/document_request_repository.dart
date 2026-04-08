import 'package:ngo_volunteer_management/domain/entities/document_request.entity.dart';

abstract class IDocumentRequestRepository {
  Stream<List<DocumentRequestEntity>> watchAll();
  Future<List<DocumentRequestEntity>> getAll();
  Future<DocumentRequestEntity> getById(String id);
  Future<void> add(DocumentRequestEntity request);
  Future<void> update(DocumentRequestEntity request);
  Future<void> updateStatus(String id, DocumentRequestStatus status, {String? approvedBy, String? certificateNo});
}
