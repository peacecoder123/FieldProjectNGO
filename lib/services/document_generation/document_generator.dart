// lib/services/document_generation/document_generator.dart


import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/domain/entities/template_field.dart';
import 'package:ngo_volunteer_management/domain/entities/document_template.dart';
import 'package:ngo_volunteer_management/domain/entities/generated_document.dart';
import 'package:uuid/uuid.dart';

/// The core dynamic template engine.
///
/// Responsible for:
/// 1. Providing built-in templates for each [DocumentType]
/// 2. Validating field values against template field definitions
/// 3. Resolving templates by replacing `{{placeholder}}` tokens with values
///
/// Designed to be extended in Step 5 with signature logic & tax metadata.
class DocumentGenerator {
  static const _uuid = Uuid();

  // ─────────────────────────────────────────────────────────────────────────
  // PUBLIC API
  // ─────────────────────────────────────────────────────────────────────────

  /// Resolves a [template] by replacing all `{{key}}` placeholders with the
  /// corresponding values from [fieldValues].
  ///
  /// Throws [ArgumentError] if required fields are missing or invalid.
  GeneratedDocument resolveTemplate(
    DocumentTemplate template,
    Map<String, String> fieldValues,
  ) {
    // 1. Validate
    final errors = validateFieldValues(template.fields, fieldValues);
    if (errors.isNotEmpty) {
      throw ArgumentError(
        'Template validation failed:\n${errors.join('\n')}',
      );
    }

    // 2. Apply defaults for missing optional fields
    final resolvedValues = <String, String>{};
    for (final field in template.fields) {
      if (fieldValues.containsKey(field.key)) {
        resolvedValues[field.key] = fieldValues[field.key]!;
      } else if (field.defaultValue != null) {
        resolvedValues[field.key] = field.defaultValue!;
      }
    }

    // 3. Replace placeholders
    final content = _replacePlaceholders(template.bodyTemplate, resolvedValues);

    // 4. Build output
    return GeneratedDocument(
      id: _uuid.v4(),
      templateId: template.id,
      documentType: template.documentType,
      generatedContent: content,
      fieldValues: resolvedValues,
      generatedAt: DateTime.now().toIso8601String(),
      metadata: Map<String, String>.from(template.metadata),
      signatureIncluded: template.includeSignature,
    );
  }

  /// Returns the built-in [DocumentTemplate] for the given [type].
  DocumentTemplate getTemplateForType(DocumentType type) {
    return switch (type) {
      DocumentType.donationReceipt    => _donationReceiptTemplate(),
      DocumentType.eightyGCertificate => _eightyGCertificateTemplate(),
      DocumentType.joiningLetter      => _joiningLetterTemplate(),
      DocumentType.certificate        => _certificateTemplate(),
      DocumentType.mouDocument        => _mouDocumentTemplate(),
    };
  }

  /// Validates [fieldValues] against [fields] definitions.
  ///
  /// Returns a list of human-readable error strings.
  /// An empty list means all values are valid.
  List<String> validateFieldValues(
    List<TemplateField> fields,
    Map<String, String> fieldValues,
  ) {
    final errors = <String>[];

    for (final field in fields) {
      final value = fieldValues[field.key];

      // Required check
      if (field.isRequired && (value == null || value.trim().isEmpty)) {
        errors.add('Field "${field.label}" is required.');
        continue;
      }

      // Skip further validation if value is absent and optional
      if (value == null || value.trim().isEmpty) continue;

      // Type-specific validation
      switch (field.type) {
        case TemplateFieldType.number:
          if (int.tryParse(value) == null && double.tryParse(value) == null) {
            errors.add('Field "${field.label}" must be a valid number.');
          }
          break;

        case TemplateFieldType.currency:
          if (double.tryParse(value.replaceAll(',', '')) == null) {
            errors.add('Field "${field.label}" must be a valid currency amount.');
          }
          break;

        case TemplateFieldType.date:
          if (DateTime.tryParse(value) == null) {
            errors.add(
              'Field "${field.label}" must be a valid date (ISO 8601).',
            );
          }
          break;

        case TemplateFieldType.boolean:
          if (value != 'true' && value != 'false') {
            errors.add('Field "${field.label}" must be true or false.');
          }
          break;

        case TemplateFieldType.dropdown:
          if (field.dropdownOptions != null &&
              !field.dropdownOptions!.contains(value)) {
            errors.add(
              'Field "${field.label}" must be one of: '
              '${field.dropdownOptions!.join(', ')}.',
            );
          }
          break;

        case TemplateFieldType.text:
        case TemplateFieldType.signature:
          // No extra validation needed for text/signature at this stage.
          break;
      }

      // Regex pattern validation (if provided)
      if (field.validationPattern != null) {
        final regex = RegExp(field.validationPattern!);
        if (!regex.hasMatch(value)) {
          errors.add(
            'Field "${field.label}" does not match the required pattern.',
          );
        }
      }
    }

    return errors;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PLACEHOLDER RESOLUTION
  // ─────────────────────────────────────────────────────────────────────────

  /// Replaces all `{{key}}` tokens in [template] with values from [values].
  /// Un-matched placeholders are left as-is (for debugging visibility).
  String _replacePlaceholders(
    String template,
    Map<String, String> values,
  ) {
    return template.replaceAllMapped(
      RegExp(r'\{\{(\w+)\}\}'),
      (match) {
        final key = match.group(1)!;
        return values[key] ?? match.group(0)!;
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILT-IN TEMPLATES
  // ─────────────────────────────────────────────────────────────────────────

  DocumentTemplate _donationReceiptTemplate() {
    return const DocumentTemplate(
      id: 'tpl_donation_receipt',
      name: 'Donation Receipt',
      documentType: DocumentType.donationReceipt,
      includeSignature: true,
      metadata: {'version': '1.0'},
      fields: [
        TemplateField(
          key: 'receipt_number',
          label: 'Receipt Number',
          type: TemplateFieldType.text,
        ),
        TemplateField(
          key: 'donor_name',
          label: 'Donor Name',
          type: TemplateFieldType.text,
        ),
        TemplateField(
          key: 'amount',
          label: 'Donation Amount',
          type: TemplateFieldType.currency,
        ),
        TemplateField(
          key: 'date',
          label: 'Donation Date',
          type: TemplateFieldType.date,
        ),
        TemplateField(
          key: 'payment_mode',
          label: 'Payment Mode',
          type: TemplateFieldType.dropdown,
          dropdownOptions: ['cash', 'online', 'cheque'],
        ),
        TemplateField(
          key: 'purpose',
          label: 'Purpose',
          type: TemplateFieldType.text,
        ),
        TemplateField(
          key: 'donor_address',
          label: 'Donor Address',
          type: TemplateFieldType.text,
          isRequired: false,
          defaultValue: '',
        ),
      ],
      bodyTemplate: '''
═══════════════════════════════════════════════════════
                    DONATION RECEIPT
                  HopeConnect Foundation
═══════════════════════════════════════════════════════

Receipt No : {{receipt_number}}
Date       : {{date}}

Received with thanks from:
  Name    : {{donor_name}}
  Address : {{donor_address}}

A sum of ₹{{amount}} (Rupees Only)

Payment Mode : {{payment_mode}}
Purpose      : {{purpose}}

───────────────────────────────────────────────────────
This receipt is issued subject to realisation of
the cheque/draft, if applicable.

Authorised Signatory: ________________________
═══════════════════════════════════════════════════════
''',
    );
  }

  DocumentTemplate _eightyGCertificateTemplate() {
    return const DocumentTemplate(
      id: 'tpl_80g_certificate',
      name: '80G Tax Exemption Certificate',
      documentType: DocumentType.eightyGCertificate,
      includeSignature: true,
      metadata: {
        'compliance': '80G',
        'version': '1.0',
      },
      fields: [
        TemplateField(
          key: 'receipt_number',
          label: 'Receipt Number',
          type: TemplateFieldType.text,
        ),
        TemplateField(
          key: 'donor_name',
          label: 'Donor Name',
          type: TemplateFieldType.text,
        ),
        TemplateField(
          key: 'donor_pan',
          label: 'Donor PAN',
          type: TemplateFieldType.text,
          isRequired: false,
          defaultValue: 'N/A',
        ),
        TemplateField(
          key: 'donor_address',
          label: 'Donor Address',
          type: TemplateFieldType.text,
          isRequired: false,
          defaultValue: '',
        ),
        TemplateField(
          key: 'amount',
          label: 'Donation Amount',
          type: TemplateFieldType.currency,
        ),
        TemplateField(
          key: 'date',
          label: 'Donation Date',
          type: TemplateFieldType.date,
        ),
        TemplateField(
          key: 'payment_mode',
          label: 'Payment Mode',
          type: TemplateFieldType.dropdown,
          dropdownOptions: ['cash', 'online', 'cheque'],
        ),
        TemplateField(
          key: 'purpose',
          label: 'Purpose',
          type: TemplateFieldType.text,
        ),
        TemplateField(
          key: 'assessment_year',
          label: 'Assessment Year',
          type: TemplateFieldType.text,
          isRequired: false,
          defaultValue: '',
        ),
        TemplateField(
          key: 'exemption_order_no',
          label: '80G Exemption Order No.',
          type: TemplateFieldType.text,
          isRequired: false,
          defaultValue: '',
        ),
      ],
      bodyTemplate: '''
═══════════════════════════════════════════════════════
      CERTIFICATE UNDER SECTION 80G OF THE
             INCOME TAX ACT, 1961
           HopeConnect Foundation
═══════════════════════════════════════════════════════

Receipt No       : {{receipt_number}}
Date             : {{date}}
Assessment Year  : {{assessment_year}}

80G Order No.    : {{exemption_order_no}}

───────────────────────────────────────────────────────
DONOR DETAILS
───────────────────────────────────────────────────────
Name    : {{donor_name}}
PAN     : {{donor_pan}}
Address : {{donor_address}}

───────────────────────────────────────────────────────
DONATION DETAILS
───────────────────────────────────────────────────────
Amount       : ₹{{amount}}
Payment Mode : {{payment_mode}}
Purpose      : {{purpose}}

This is to certify that the above donation has been
received and the donor is entitled to deduction under
Section 80G of the Income Tax Act, 1961.

Authorised Signatory: ________________________

Date: {{date}}
═══════════════════════════════════════════════════════
''',
    );
  }

  DocumentTemplate _joiningLetterTemplate() {
    return const DocumentTemplate(
      id: 'tpl_joining_letter',
      name: 'Joining Letter',
      documentType: DocumentType.joiningLetter,
      includeSignature: true,
      metadata: {'version': '1.0'},
      fields: [
        TemplateField(
          key: 'name',
          label: 'Name',
          type: TemplateFieldType.text,
        ),
        TemplateField(
          key: 'date',
          label: 'Date',
          type: TemplateFieldType.date,
        ),
        TemplateField(
          key: 'role',
          label: 'Role',
          type: TemplateFieldType.dropdown,
          dropdownOptions: ['Volunteer', 'Member'],
        ),
        TemplateField(
          key: 'tenure',
          label: 'Tenure',
          type: TemplateFieldType.text,
        ),
      ],
      bodyTemplate: '''
═══════════════════════════════════════════════════════
                   JOINING LETTER
                HopeConnect Foundation
═══════════════════════════════════════════════════════

Date: {{date}}

Dear {{name}},

We are pleased to confirm your association with
HopeConnect Foundation as a {{role}}.

Your tenure with us is: {{tenure}}.

We look forward to your valuable contribution.

Warm regards,

Authorised Signatory: ________________________
HopeConnect Foundation
═══════════════════════════════════════════════════════
''',
    );
  }

  DocumentTemplate _certificateTemplate() {
    return const DocumentTemplate(
      id: 'tpl_certificate',
      name: 'Certificate',
      documentType: DocumentType.certificate,
      includeSignature: true,
      metadata: {'version': '1.0'},
      fields: [
        TemplateField(
          key: 'name',
          label: 'Recipient Name',
          type: TemplateFieldType.text,
        ),
        TemplateField(
          key: 'date',
          label: 'Date',
          type: TemplateFieldType.date,
        ),
        TemplateField(
          key: 'certificate_type',
          label: 'Certificate Type',
          type: TemplateFieldType.dropdown,
          dropdownOptions: [
            'Participation',
            'Appreciation',
            'Membership',
            'Donation',
          ],
        ),
        TemplateField(
          key: 'details',
          label: 'Details',
          type: TemplateFieldType.text,
          isRequired: false,
          defaultValue: '',
        ),
      ],
      bodyTemplate: '''
═══════════════════════════════════════════════════════
            CERTIFICATE OF {{certificate_type}}
                HopeConnect Foundation
═══════════════════════════════════════════════════════

Date: {{date}}

This is to certify that

  {{name}}

has been awarded this Certificate of {{certificate_type}}
in recognition of their contribution.

{{details}}

Authorised Signatory: ________________________
HopeConnect Foundation
═══════════════════════════════════════════════════════
''',
    );
  }

  DocumentTemplate _mouDocumentTemplate() {
    return const DocumentTemplate(
      id: 'tpl_mou_document',
      name: 'MOU Document',
      documentType: DocumentType.mouDocument,
      includeSignature: true,
      metadata: {'version': '1.0'},
      fields: [
        TemplateField(
          key: 'patient_name',
          label: 'Patient Name',
          type: TemplateFieldType.text,
        ),
        TemplateField(
          key: 'patient_age',
          label: 'Patient Age',
          type: TemplateFieldType.number,
        ),
        TemplateField(
          key: 'disease',
          label: 'Disease / Condition',
          type: TemplateFieldType.text,
        ),
        TemplateField(
          key: 'hospital',
          label: 'Hospital',
          type: TemplateFieldType.text,
        ),
        TemplateField(
          key: 'requester_name',
          label: 'Requester Name',
          type: TemplateFieldType.text,
        ),
        TemplateField(
          key: 'date',
          label: 'Date',
          type: TemplateFieldType.date,
        ),
        TemplateField(
          key: 'phone',
          label: 'Phone',
          type: TemplateFieldType.text,
          isRequired: false,
          defaultValue: '',
        ),
        TemplateField(
          key: 'blood_group',
          label: 'Blood Group',
          type: TemplateFieldType.text,
          isRequired: false,
          defaultValue: '',
        ),
      ],
      bodyTemplate: '''
═══════════════════════════════════════════════════════
        MEMORANDUM OF UNDERSTANDING (MOU)
     Medical Assistance — HopeConnect Foundation
═══════════════════════════════════════════════════════

Date: {{date}}

PATIENT INFORMATION
───────────────────────────────────────────────────────
Name        : {{patient_name}}
Age         : {{patient_age}}
Condition   : {{disease}}
Blood Group : {{blood_group}}
Hospital    : {{hospital}}

REQUESTED BY
───────────────────────────────────────────────────────
Name  : {{requester_name}}
Phone : {{phone}}

This document serves as an undertaking for medical
assistance provided through HopeConnect Foundation.

Authorised Signatory: ________________________
HopeConnect Foundation
═══════════════════════════════════════════════════════
''',
    );
  }
}
