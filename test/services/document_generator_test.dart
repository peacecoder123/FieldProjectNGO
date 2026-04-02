// test/services/document_generator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/domain/entities/template_field.dart';
import 'package:ngo_volunteer_management/domain/entities/document_template.dart';
import 'package:ngo_volunteer_management/services/document_generation/document_generator.dart';

void main() {
  late DocumentGenerator generator;

  setUp(() {
    generator = DocumentGenerator();
  });

  // ─────────────────────────────────────────────────────────────────────────
  // getTemplateForType
  // ─────────────────────────────────────────────────────────────────────────

  group('getTemplateForType', () {
    test('returns a template for every DocumentType', () {
      for (final type in DocumentType.values) {
        final template = generator.getTemplateForType(type);
        expect(template.documentType, equals(type));
        expect(template.fields, isNotEmpty);
        expect(template.bodyTemplate, isNotEmpty);
      }
    });

    test('donation receipt template has expected fields', () {
      final template = generator.getTemplateForType(
        DocumentType.donationReceipt,
      );

      final fieldKeys = template.fields.map((f) => f.key).toList();
      expect(fieldKeys, contains('receipt_number'));
      expect(fieldKeys, contains('donor_name'));
      expect(fieldKeys, contains('amount'));
      expect(fieldKeys, contains('date'));
      expect(fieldKeys, contains('payment_mode'));
      expect(fieldKeys, contains('purpose'));
    });

    test('80G certificate template has compliance metadata', () {
      final template = generator.getTemplateForType(
        DocumentType.eightyGCertificate,
      );

      expect(template.metadata['compliance'], equals('80G'));
      expect(template.includeSignature, isTrue);

      final fieldKeys = template.fields.map((f) => f.key).toList();
      expect(fieldKeys, contains('donor_pan'));
      expect(fieldKeys, contains('assessment_year'));
      expect(fieldKeys, contains('exemption_order_no'));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // validateFieldValues
  // ─────────────────────────────────────────────────────────────────────────

  group('validateFieldValues', () {
    test('returns empty list for valid values', () {
      final fields = [
        const TemplateField(
          key: 'name',
          label: 'Name',
          type: TemplateFieldType.text,
        ),
        const TemplateField(
          key: 'amount',
          label: 'Amount',
          type: TemplateFieldType.currency,
        ),
      ];

      final errors = generator.validateFieldValues(fields, {
        'name': 'Alice',
        'amount': '5000',
      });

      expect(errors, isEmpty);
    });

    test('reports missing required fields', () {
      final fields = [
        const TemplateField(
          key: 'name',
          label: 'Name',
          type: TemplateFieldType.text,
        ),
        const TemplateField(
          key: 'amount',
          label: 'Amount',
          type: TemplateFieldType.currency,
        ),
      ];

      final errors = generator.validateFieldValues(fields, {
        'name': 'Alice',
        // 'amount' is missing
      });

      expect(errors, hasLength(1));
      expect(errors.first, contains('Amount'));
      expect(errors.first, contains('required'));
    });

    test('allows missing optional fields', () {
      final fields = [
        const TemplateField(
          key: 'name',
          label: 'Name',
          type: TemplateFieldType.text,
        ),
        const TemplateField(
          key: 'address',
          label: 'Address',
          type: TemplateFieldType.text,
          isRequired: false,
        ),
      ];

      final errors = generator.validateFieldValues(fields, {
        'name': 'Alice',
      });

      expect(errors, isEmpty);
    });

    test('validates number fields', () {
      final fields = [
        const TemplateField(
          key: 'age',
          label: 'Age',
          type: TemplateFieldType.number,
        ),
      ];

      // Valid number
      expect(
        generator.validateFieldValues(fields, {'age': '25'}),
        isEmpty,
      );

      // Invalid number
      final errors = generator.validateFieldValues(fields, {'age': 'abc'});
      expect(errors, hasLength(1));
      expect(errors.first, contains('number'));
    });

    test('validates currency fields', () {
      final fields = [
        const TemplateField(
          key: 'amount',
          label: 'Amount',
          type: TemplateFieldType.currency,
        ),
      ];

      // Valid
      expect(
        generator.validateFieldValues(fields, {'amount': '1,500.50'}),
        isEmpty,
      );

      // Invalid
      final errors = generator.validateFieldValues(
        fields,
        {'amount': 'not-money'},
      );
      expect(errors, hasLength(1));
      expect(errors.first, contains('currency'));
    });

    test('validates date fields', () {
      final fields = [
        const TemplateField(
          key: 'date',
          label: 'Date',
          type: TemplateFieldType.date,
        ),
      ];

      // Valid ISO date
      expect(
        generator.validateFieldValues(fields, {'date': '2026-03-31'}),
        isEmpty,
      );

      // Invalid date
      final errors = generator.validateFieldValues(
        fields,
        {'date': '31-March-2026'},
      );
      expect(errors, hasLength(1));
      expect(errors.first, contains('date'));
    });

    test('validates boolean fields', () {
      final fields = [
        const TemplateField(
          key: 'is_active',
          label: 'Active',
          type: TemplateFieldType.boolean,
        ),
      ];

      expect(
        generator.validateFieldValues(fields, {'is_active': 'true'}),
        isEmpty,
      );

      final errors = generator.validateFieldValues(
        fields,
        {'is_active': 'yes'},
      );
      expect(errors, hasLength(1));
      expect(errors.first, contains('true or false'));
    });

    test('validates dropdown fields against options', () {
      final fields = [
        const TemplateField(
          key: 'mode',
          label: 'Payment Mode',
          type: TemplateFieldType.dropdown,
          dropdownOptions: ['cash', 'online', 'cheque'],
        ),
      ];

      // Valid option
      expect(
        generator.validateFieldValues(fields, {'mode': 'cash'}),
        isEmpty,
      );

      // Invalid option
      final errors = generator.validateFieldValues(
        fields,
        {'mode': 'bitcoin'},
      );
      expect(errors, hasLength(1));
      expect(errors.first, contains('one of'));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // resolveTemplate
  // ─────────────────────────────────────────────────────────────────────────

  group('resolveTemplate', () {
    test('replaces all placeholders with values', () {
      final template = DocumentTemplate(
        id: 'test',
        name: 'Test Template',
        documentType: DocumentType.donationReceipt,
        fields: const [
          TemplateField(key: 'name', label: 'Name', type: TemplateFieldType.text),
          TemplateField(key: 'amount', label: 'Amount', type: TemplateFieldType.currency),
        ],
        bodyTemplate: 'Hello {{name}}, you donated ₹{{amount}}.',
      );

      final result = generator.resolveTemplate(template, {
        'name': 'Alice',
        'amount': '5000',
      });

      expect(result.generatedContent, equals('Hello Alice, you donated ₹5000.'));
      expect(result.documentType, equals(DocumentType.donationReceipt));
      expect(result.templateId, equals('test'));
      expect(result.fieldValues['name'], equals('Alice'));
      expect(result.fieldValues['amount'], equals('5000'));
    });

    test('applies default values for missing optional fields', () {
      final template = DocumentTemplate(
        id: 'test',
        name: 'Test',
        documentType: DocumentType.certificate,
        fields: const [
          TemplateField(key: 'name', label: 'Name', type: TemplateFieldType.text),
          TemplateField(
            key: 'address',
            label: 'Address',
            type: TemplateFieldType.text,
            isRequired: false,
            defaultValue: 'N/A',
          ),
        ],
        bodyTemplate: '{{name}} lives at {{address}}.',
      );

      final result = generator.resolveTemplate(template, {
        'name': 'Bob',
      });

      expect(result.generatedContent, equals('Bob lives at N/A.'));
    });

    test('throws ArgumentError for missing required fields', () {
      final template = DocumentTemplate(
        id: 'test',
        name: 'Test',
        documentType: DocumentType.donationReceipt,
        fields: const [
          TemplateField(key: 'name', label: 'Name', type: TemplateFieldType.text),
        ],
        bodyTemplate: 'Hello {{name}}.',
      );

      expect(
        () => generator.resolveTemplate(template, {}),
        throwsArgumentError,
      );
    });

    test('preserves template metadata in output', () {
      final template = DocumentTemplate(
        id: 'test',
        name: 'Test',
        documentType: DocumentType.eightyGCertificate,
        fields: const [
          TemplateField(key: 'name', label: 'Name', type: TemplateFieldType.text),
        ],
        bodyTemplate: '{{name}}',
        metadata: const {'compliance': '80G', 'version': '1.0'},
        includeSignature: true,
      );

      final result = generator.resolveTemplate(template, {'name': 'Alice'});

      expect(result.metadata['compliance'], equals('80G'));
      expect(result.metadata['version'], equals('1.0'));
      expect(result.signatureIncluded, isTrue);
    });

    test('works with real donation receipt template', () {
      final template = generator.getTemplateForType(
        DocumentType.donationReceipt,
      );

      final result = generator.resolveTemplate(template, {
        'receipt_number': 'REC-001',
        'donor_name': 'Priya Sharma',
        'amount': '10000',
        'date': '2026-03-31',
        'payment_mode': 'online',
        'purpose': 'Education Fund',
      });

      expect(result.generatedContent, contains('REC-001'));
      expect(result.generatedContent, contains('Priya Sharma'));
      expect(result.generatedContent, contains('10000'));
      expect(result.generatedContent, contains('Education Fund'));
      expect(result.signatureIncluded, isTrue);
    });

    test('works with real 80G certificate template', () {
      final template = generator.getTemplateForType(
        DocumentType.eightyGCertificate,
      );

      final result = generator.resolveTemplate(template, {
        'receipt_number': '80G-001',
        'donor_name': 'Rahul Verma',
        'amount': '25000',
        'date': '2026-03-31',
        'payment_mode': 'cheque',
        'purpose': 'General Donation',
      });

      expect(result.generatedContent, contains('80G-001'));
      expect(result.generatedContent, contains('Rahul Verma'));
      expect(result.generatedContent, contains('SECTION 80G'));
      expect(result.metadata['compliance'], equals('80G'));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Entity serialisation
  // ─────────────────────────────────────────────────────────────────────────

  group('entity serialisation', () {
    test('TemplateField round-trips through toMap/fromMap', () {
      const field = TemplateField(
        key: 'donor_name',
        label: 'Donor Name',
        type: TemplateFieldType.text,
        isRequired: true,
        dropdownOptions: null,
      );

      final map = field.toMap();
      final restored = TemplateField.fromMap(map);

      expect(restored.key, equals(field.key));
      expect(restored.label, equals(field.label));
      expect(restored.type, equals(field.type));
      expect(restored.isRequired, equals(field.isRequired));
    });

    test('DocumentTemplate round-trips through toMap/fromMap', () {
      final template = generator.getTemplateForType(
        DocumentType.donationReceipt,
      );

      final map = template.toMap();
      final restored = DocumentTemplate.fromMap(map);

      expect(restored.id, equals(template.id));
      expect(restored.name, equals(template.name));
      expect(restored.documentType, equals(template.documentType));
      expect(restored.fields.length, equals(template.fields.length));
      expect(restored.includeSignature, equals(template.includeSignature));
    });
  });
}
