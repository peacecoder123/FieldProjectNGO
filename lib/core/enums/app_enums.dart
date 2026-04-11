library app_enums;

/// Mirrors the TypeScript union types from the React source.
/// Using sealed enums gives us exhaustive switch support in Dart 3.

// ── User roles ────────────────────────────────────────────────────────────────

enum UserRole {
  superAdmin,
  admin,
  member,
  volunteer;

  String get displayName => switch (this) {
    UserRole.superAdmin => 'Super Admin',
    UserRole.admin      => 'Admin',
    UserRole.member     => 'Member',
    UserRole.volunteer  => 'Volunteer',
  };

  /// Route path segments matching [AppRouter]
  String get routePath => switch (this) {
    UserRole.superAdmin => '/superadmin',
    UserRole.admin      => '/admin',
    UserRole.member     => '/member',
    UserRole.volunteer  => '/volunteer',
  };
}

// ── Task status ───────────────────────────────────────────────────────────────

enum TaskStatus {
  pending,
  submitted,
  approved,
  rejected;

  String get displayName => switch (this) {
    TaskStatus.pending   => 'Pending',
    TaskStatus.submitted => 'Submitted',
    TaskStatus.approved  => 'Approved',
    TaskStatus.rejected  => 'Rejected',
  };

  static TaskStatus fromString(String value) =>
      TaskStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => TaskStatus.pending,
      );
}

// ── Request status (shared by general requests, MOU, joining letters) ─────────

enum RequestStatus {
  pending,
  approved,
  rejected;

  String get displayName => switch (this) {
    RequestStatus.pending  => 'Pending',
    RequestStatus.approved => 'Approved',
    RequestStatus.rejected => 'Rejected',
  };

  static RequestStatus fromString(String value) =>
      RequestStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => RequestStatus.pending,
      );
}

// ── Meeting status ────────────────────────────────────────────────────────────

enum MeetingStatus {
  upcoming,
  completed;

  static MeetingStatus fromString(String value) =>
      MeetingStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => MeetingStatus.upcoming,
      );
}

// ── Membership type (member-specific) ─────────────────────────────────────────

enum MembershipType {
  eightyG,    // 80G — tax-exempt
  nonEightyG; // non-80G

  String get displayLabel => switch (this) {
    MembershipType.eightyG    => '80G',
    MembershipType.nonEightyG => 'Non-80G',
  };

  static MembershipType fromString(String value) =>
      value == '80G' ? MembershipType.eightyG : MembershipType.nonEightyG;
}

// ── Volunteer/Member status ───────────────────────────────────────────────────

enum PersonStatus {
  active,
  inactive;

  String get displayName => switch (this) {
    PersonStatus.active   => 'Active',
    PersonStatus.inactive => 'Inactive',
  };

  static PersonStatus fromString(String value) =>
      PersonStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => PersonStatus.active,
      );
}

// ── Donation type ─────────────────────────────────────────────────────────────

enum DonationType {
  cash,
  online,
  cheque;

  static DonationType fromString(String value) =>
      DonationType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => DonationType.cash,
      );
}

// ── Request type ──────────────────────────────────────────────────────────────

enum GeneralRequestType {
  joiningLetter,
  certificate,
  medicalMou;

  String get displayLabel => switch (this) {
    GeneralRequestType.joiningLetter => 'Joining Letter',
    GeneralRequestType.certificate   => 'Certificate',
    GeneralRequestType.medicalMou    => 'Medical MOU',
  };
}

// ── Joining letter requester type ─────────────────────────────────────────────

enum JoiningLetterType {
  volunteer,
  member,
  newMember;

  String get displayLabel => switch (this) {
    JoiningLetterType.volunteer  => 'Volunteer',
    JoiningLetterType.member     => 'Member',
    JoiningLetterType.newMember  => 'New Member',
  };
}

// ── Assignee type (tasks can belong to volunteer or member) ───────────────────

enum AssigneeType {
  volunteer,
  member;

  static AssigneeType fromString(String value) =>
      AssigneeType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => AssigneeType.volunteer,
      );
}

// ── Document file types ───────────────────────────────────────────────────────

enum DocumentFileType {
  pdf,
  doc,
  xlsx,
  jpg,
  png;

  String get displayLabel => name.toUpperCase();

  static DocumentFileType fromString(String value) =>
      DocumentFileType.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
        orElse: () => DocumentFileType.pdf,
      );
}

// ── Theme mode (mirrors React context dark/light) ────────────────────────────

enum AppThemeMode {
  light,
  dark;

  bool get isDark => this == AppThemeMode.dark;
}

// ── Certificate types (member certificate request) ────────────────────────────

enum CertificateType {
  participation,
  appreciation,
  membership,
  donation;

  String get displayLabel => switch (this) {
    CertificateType.participation => 'Certificate of Participation',
    CertificateType.appreciation  => 'Certificate of Appreciation',
    CertificateType.membership    => 'Membership Certificate',
    CertificateType.donation      => 'Donation Acknowledgement',
  };
}

// ── Payment mode ──────────────────────────────────────────────────────────────

enum PaymentMode {
  online,
  cash,
  cheque;

  String get displayLabel => switch (this) {
    PaymentMode.online  => 'Online',
    PaymentMode.cash    => 'Cash',
    PaymentMode.cheque  => 'Cheque',
  };
}

// ── Tenure type (joining letter modal) ────────────────────────────────────────

enum TenureType {
  monthly,
  annual;
}

// ── Document type (generated documents) ───────────────────────────────────────

enum DocumentType {
  donationReceipt,
  eightyGCertificate,
  joiningLetter,
  certificate,
  mouDocument;

  String get displayLabel => switch (this) {
    DocumentType.donationReceipt    => 'Donation Receipt',
    DocumentType.eightyGCertificate => '80G Certificate',
    DocumentType.joiningLetter      => 'Joining Letter',
    DocumentType.certificate        => 'Certificate',
    DocumentType.mouDocument        => 'MOU Document',
  };

  static DocumentType fromString(String value) =>
      DocumentType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => DocumentType.donationReceipt,
      );
}

// ── Template field type (dynamic fields in templates) ─────────────────────────

enum TemplateFieldType {
  text,
  number,
  date,
  currency,
  signature,
  boolean,
  dropdown;

  String get displayLabel => switch (this) {
    TemplateFieldType.text      => 'Text',
    TemplateFieldType.number    => 'Number',
    TemplateFieldType.date      => 'Date',
    TemplateFieldType.currency  => 'Currency',
    TemplateFieldType.signature => 'Signature',
    TemplateFieldType.boolean   => 'Yes/No',
    TemplateFieldType.dropdown  => 'Dropdown',
  };

  static TemplateFieldType fromString(String value) =>
      TemplateFieldType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => TemplateFieldType.text,
      );
}