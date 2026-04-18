import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';

enum DocumentRequestStatus { pending, approved, rejected }

@immutable
class DocumentRequestEntity {
  final String id;
  final String userId;
  final String userName;
  final DocumentType documentType;
  final DocumentRequestStatus status;
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  // Certificate details set at approval time
  final String? certificateNo;
  final String? organisation;
  final String? internshipArea;
  final String? internshipDuration;

  const DocumentRequestEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.documentType,
    this.status = DocumentRequestStatus.pending,
    required this.requestedAt,
    this.approvedAt,
    this.approvedBy,
    this.certificateNo,
    this.organisation,
    this.internshipArea,
    this.internshipDuration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'documentType': documentType.name,
      'status': status.name,
      'requestedAt': requestedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'approvedBy': approvedBy,
      'certificateNo': certificateNo,
      'organisation': organisation,
      'internshipArea': internshipArea,
      'internshipDuration': internshipDuration,
    };
  }

  factory DocumentRequestEntity.fromMap(Map<String, dynamic> map, String docId) {
    return DocumentRequestEntity(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      documentType: DocumentType.fromString(map['documentType'] ?? ''),
      status: DocumentRequestStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DocumentRequestStatus.pending,
      ),
      requestedAt: DateTime.parse(map['requestedAt']),
      approvedAt: map['approvedAt'] != null ? DateTime.parse(map['approvedAt']) : null,
      approvedBy: map['approvedBy'],
      certificateNo: map['certificateNo'],
      organisation: map['organisation'],
      internshipArea: map['internshipArea'],
      internshipDuration: map['internshipDuration'],
    );
  }

  DocumentRequestEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    DocumentType? documentType,
    DocumentRequestStatus? status,
    DateTime? requestedAt,
    DateTime? approvedAt,
    String? approvedBy,
    String? certificateNo,
    String? organisation,
    String? internshipArea,
    String? internshipDuration,
  }) {
    return DocumentRequestEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      documentType: documentType ?? this.documentType,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      certificateNo: certificateNo ?? this.certificateNo,
      organisation: organisation ?? this.organisation,
      internshipArea: internshipArea ?? this.internshipArea,
      internshipDuration: internshipDuration ?? this.internshipDuration,
    );
  }
}
