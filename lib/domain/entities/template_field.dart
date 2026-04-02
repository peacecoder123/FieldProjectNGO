// lib/domain/entities/template_field.dart

import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';

/// Represents a single dynamic field definition within a document template.
///
/// Each field has a [key] used as a placeholder token (e.g. `{{donor_name}}`),
/// a human-readable [label], a [type] for validation, and optional config
/// like [defaultValue], [dropdownOptions], and [validationPattern].
@immutable
class TemplateField {
  final String key;
  final String label;
  final TemplateFieldType type;
  final bool isRequired;
  final String? defaultValue;
  final List<String>? dropdownOptions;
  final String? validationPattern;

  const TemplateField({
    required this.key,
    required this.label,
    required this.type,
    this.isRequired = true,
    this.defaultValue,
    this.dropdownOptions,
    this.validationPattern,
  });

  /// Convert to a map for serialisation / Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'label': label,
      'type': type.name,
      'isRequired': isRequired,
      'defaultValue': defaultValue,
      'dropdownOptions': dropdownOptions,
      'validationPattern': validationPattern,
    };
  }

  /// Construct from a serialised map.
  factory TemplateField.fromMap(Map<String, dynamic> map) {
    return TemplateField(
      key: map['key'] ?? '',
      label: map['label'] ?? '',
      type: TemplateFieldType.fromString(map['type'] ?? 'text'),
      isRequired: map['isRequired'] ?? true,
      defaultValue: map['defaultValue'],
      dropdownOptions: map['dropdownOptions'] != null
          ? List<String>.from(map['dropdownOptions'])
          : null,
      validationPattern: map['validationPattern'],
    );
  }

  TemplateField copyWith({
    String? key,
    String? label,
    TemplateFieldType? type,
    bool? isRequired,
    String? defaultValue,
    List<String>? dropdownOptions,
    String? validationPattern,
  }) {
    return TemplateField(
      key: key ?? this.key,
      label: label ?? this.label,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      defaultValue: defaultValue ?? this.defaultValue,
      dropdownOptions: dropdownOptions ?? this.dropdownOptions,
      validationPattern: validationPattern ?? this.validationPattern,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateField &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          label == other.label &&
          type == other.type &&
          isRequired == other.isRequired;

  @override
  int get hashCode => Object.hash(key, label, type, isRequired);

  @override
  String toString() => 'TemplateField(key: $key, label: $label, type: $type)';
}
