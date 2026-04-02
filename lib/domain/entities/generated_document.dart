// lib/domain/entities/generated_document.dart

import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';

/// The output of the template engine after resolving a [DocumentTemplate]
/// with concrete field values.
///
/// Contains the fully rendered [generatedContent] (all placeholders replaced),
/// along with the original [fieldValues] and any [metadata] stamps.
@immutable
class GeneratedDocument {
  final String id;
  final String templateId;
  final DocumentType documentType;
  final String generatedContent;
  final Map<String, String> fieldValues;
  final String generatedAt;
  final Map<String, String> metadata;
  final bool signatureIncluded;

  const GeneratedDocument({
    required this.id,
    required this.templateId,
    required this.documentType,
    required this.generatedContent,
    required this.fieldValues,
    required this.generatedAt,
    this.metadata = const {},
    this.signatureIncluded = false,
  });

  /// Convert to a map for serialisation / Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'templateId': templateId,
      'documentType': documentType.name,
      'generatedContent': generatedContent,
      'fieldValues': fieldValues,
      'generatedAt': generatedAt,
      'metadata': metadata,
      'signatureIncluded': signatureIncluded,
    };
  }

  /// Construct from a serialised map.
  factory GeneratedDocument.fromMap(Map<String, dynamic> map) {
    return GeneratedDocument(
      id: map['id'] ?? '',
      templateId: map['templateId'] ?? '',
      documentType: DocumentType.fromString(map['documentType'] ?? ''),
      generatedContent: map['generatedContent'] ?? '',
      fieldValues: Map<String, String>.from(map['fieldValues'] ?? {}),
      generatedAt: map['generatedAt'] ?? '',
      metadata: Map<String, String>.from(map['metadata'] ?? {}),
      signatureIncluded: map['signatureIncluded'] ?? false,
    );
  }

  GeneratedDocument copyWith({
    String? id,
    String? templateId,
    DocumentType? documentType,
    String? generatedContent,
    Map<String, String>? fieldValues,
    String? generatedAt,
    Map<String, String>? metadata,
    bool? signatureIncluded,
  }) {
    return GeneratedDocument(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      documentType: documentType ?? this.documentType,
      generatedContent: generatedContent ?? this.generatedContent,
      fieldValues: fieldValues ?? this.fieldValues,
      generatedAt: generatedAt ?? this.generatedAt,
      metadata: metadata ?? this.metadata,
      signatureIncluded: signatureIncluded ?? this.signatureIncluded,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneratedDocument &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'GeneratedDocument(id: $id, type: $documentType, '
      'template: $templateId, generated: $generatedAt)';
}
