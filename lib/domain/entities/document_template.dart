// lib/domain/entities/document_template.dart

import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/domain/entities/template_field.dart';

/// A reusable document template that defines dynamic fields and a body
/// containing `{{placeholder}}` tokens that get resolved at generation time.
///
/// Example [bodyTemplate]:
/// ```
/// Receipt No: {{receipt_number}}
/// Date: {{date}}
/// Received from {{donor_name}} a sum of ₹{{amount}} towards {{purpose}}.
/// ```
@immutable
class DocumentTemplate {
  final String id;
  final String name;
  final DocumentType documentType;
  final List<TemplateField> fields;
  final String bodyTemplate;
  final bool includeSignature;
  final Map<String, String> metadata;

  const DocumentTemplate({
    required this.id,
    required this.name,
    required this.documentType,
    required this.fields,
    required this.bodyTemplate,
    this.includeSignature = false,
    this.metadata = const {},
  });

  /// Convert to a map for serialisation / Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'documentType': documentType.name,
      'fields': fields.map((f) => f.toMap()).toList(),
      'bodyTemplate': bodyTemplate,
      'includeSignature': includeSignature,
      'metadata': metadata,
    };
  }

  /// Construct from a serialised map.
  factory DocumentTemplate.fromMap(Map<String, dynamic> map) {
    return DocumentTemplate(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      documentType: DocumentType.fromString(map['documentType'] ?? ''),
      fields: (map['fields'] as List<dynamic>?)
              ?.map((f) => TemplateField.fromMap(f as Map<String, dynamic>))
              .toList() ??
          [],
      bodyTemplate: map['bodyTemplate'] ?? '',
      includeSignature: map['includeSignature'] ?? false,
      metadata: Map<String, String>.from(map['metadata'] ?? {}),
    );
  }

  DocumentTemplate copyWith({
    String? id,
    String? name,
    DocumentType? documentType,
    List<TemplateField>? fields,
    String? bodyTemplate,
    bool? includeSignature,
    Map<String, String>? metadata,
  }) {
    return DocumentTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      documentType: documentType ?? this.documentType,
      fields: fields ?? this.fields,
      bodyTemplate: bodyTemplate ?? this.bodyTemplate,
      includeSignature: includeSignature ?? this.includeSignature,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentTemplate &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DocumentTemplate(id: $id, name: $name, type: $documentType, '
      'fields: ${fields.length})';
}
