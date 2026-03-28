import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import 'entities.dart';

/// In-memory seed data.
///
/// Exact Dart port of `src/app/data/mockData.ts`.
/// Every field name, value, and relationship is preserved so the Flutter UI
/// renders identically to the React original.
///
/// When a real API is ready, replace [MockDataSource] with a concrete
/// implementation of each repository interface — zero business-logic changes
/// required.
abstract final class MockDataSource {
  MockDataSource._();

  // ── Demo users (one per role) ─────────────────────────────────────────────

  static const List<UserEntity> users = [
    UserEntity(
      id: 0, role: UserRole.superAdmin,
      name: 'Vikram Bose', email: 'vikram@hopeconnect.org', avatar: 'VB',
    ),
    UserEntity(
      id: 1, role: UserRole.admin,
      name: 'Priya Sharma', email: 'priya@hopeconnect.org', avatar: 'PS',
    ),
    UserEntity(
      id: 2, role: UserRole.member,
      name: 'Dr. Anjali Mehta', email: 'anjali@hopeconnect.org', avatar: 'AM',
    ),
    UserEntity(
      id: 3, role: UserRole.volunteer,
      name: 'Rahul Sharma', email: 'rahul@hopeconnect.org', avatar: 'RS',
    ),
  ];

  // ── Volunteers ────────────────────────────────────────────────────────────

  static final List<VolunteerEntity> volunteers = [
    const VolunteerEntity(
      id: 1, name: 'Rahul Sharma', email: 'rahul.sharma@email.com',
      phone: '9876543210', address: 'Bandra, Mumbai',
      joinDate: '2024-01-15', status: PersonStatus.active,
      assignedAdmin: 'Priya Sharma',
      taskIds: [1, 2], tenure: 'Jan 2025', skills: ['Teaching', 'Healthcare'],
      avatar: 'RS',
    ),
    const VolunteerEntity(
      id: 2, name: 'Sneha Kulkarni', email: 'sneha.k@email.com',
      phone: '9123456780', address: 'Pune, Maharashtra',
      joinDate: '2024-03-10', status: PersonStatus.active,
      assignedAdmin: 'Arjun Kapoor',
      taskIds: [3], tenure: 'Mar 2025', skills: ['Cooking', 'Event Management'],
      avatar: 'SK',
    ),
    const VolunteerEntity(
      id: 3, name: 'Aditya Verma', email: 'aditya.v@email.com',
      phone: '9988776655', address: 'Andheri, Mumbai',
      joinDate: '2023-11-20', status: PersonStatus.inactive,
      assignedAdmin: 'Priya Sharma',
      taskIds: [], tenure: 'Nov 2024', skills: ['Photography', 'Design'],
      avatar: 'AV',
    ),
    const VolunteerEntity(
      id: 4, name: 'Meera Nair', email: 'meera.n@email.com',
      phone: '9871234560', address: 'Thane, Mumbai',
      joinDate: '2024-06-05', status: PersonStatus.active,
      assignedAdmin: 'Arjun Kapoor',
      taskIds: [4, 5], tenure: 'Jun 2025',
      skills: ['Counselling', 'Communication'],
      avatar: 'MN',
    ),
    const VolunteerEntity(
      id: 5, name: 'Karan Mehta', email: 'karan.m@email.com',
      phone: '9765432100', address: 'Dadar, Mumbai',
      joinDate: '2024-02-28', status: PersonStatus.active,
      assignedAdmin: 'Priya Sharma',
      taskIds: [6], tenure: 'Feb 2025',
      skills: ['IT Support', 'Data Entry'],
      avatar: 'KM',
    ),
  ];

  // ── Members ───────────────────────────────────────────────────────────────

  static final List<MemberEntity> members = [
    const MemberEntity(
      id: 1, name: 'Dr. Anjali Mehta', email: 'anjali.mehta@email.com',
      phone: '9871234567', address: 'Colaba, Mumbai',
      joinDate: '2022-04-01', renewalDate: '2026-04-01',
      status: PersonStatus.active,
      membershipType: MembershipType.eightyG,
      taskIds: [7, 8], isPaid: true, avatar: 'AM',
    ),
    const MemberEntity(
      id: 2, name: 'Suresh Patil', email: 'suresh.p@email.com',
      phone: '9823456789', address: 'Nagpur, Maharashtra',
      joinDate: '2021-08-15', renewalDate: '2025-08-15',
      status: PersonStatus.active,
      membershipType: MembershipType.nonEightyG,
      taskIds: [9], isPaid: false, avatar: 'SP',
    ),
    const MemberEntity(
      id: 3, name: 'Kavita Rao', email: 'kavita.r@email.com',
      phone: '9934567890', address: 'Vashi, Navi Mumbai',
      joinDate: '2023-01-10', renewalDate: '2026-01-10',
      status: PersonStatus.active,
      membershipType: MembershipType.eightyG,
      taskIds: [], isPaid: true, avatar: 'KR',
    ),
    const MemberEntity(
      id: 4, name: 'Neha Joshi', email: 'neha.j@email.com',
      phone: '9845678901', address: 'Borivali, Mumbai',
      joinDate: '2024-11-20', renewalDate: '2025-11-20',
      status: PersonStatus.inactive,
      membershipType: MembershipType.nonEightyG,
      taskIds: [], isPaid: false, avatar: 'NJ',
    ),
  ];

  // ── Tasks ─────────────────────────────────────────────────────────────────

  static final List<TaskEntity> tasks = [
    // Volunteer tasks
    const TaskEntity(
      id: 1, title: 'Food Drive Distribution',
      description: 'Coordinate food distribution at Dharavi community centre. '
          'Manage volunteers and ensure orderly queues.',
      deadline: '2025-04-15', assignedToId: 1,
      assignedToName: 'Rahul Sharma', assignedToType: AssigneeType.volunteer,
      status: TaskStatus.submitted, requiresUpload: true,
      uploadedImage: 'food_drive.jpg',
      submittedAt: '2025-04-10', createdAt: '2025-03-20',
    ),
    const TaskEntity(
      id: 2, title: 'Health Camp Setup',
      description: 'Set up medical equipment and registration desks at Govandi.',
      deadline: '2025-05-01', assignedToId: 1,
      assignedToName: 'Rahul Sharma', assignedToType: AssigneeType.volunteer,
      status: TaskStatus.approved, requiresUpload: false,
      createdAt: '2025-03-25',
    ),
    const TaskEntity(
      id: 3, title: 'Cooking Workshop',
      description: 'Teach basic nutrition to 30 women at Dharavi skill centre.',
      deadline: '2025-04-20', assignedToId: 2,
      assignedToName: 'Sneha Kulkarni', assignedToType: AssigneeType.volunteer,
      status: TaskStatus.pending, requiresUpload: true,
      createdAt: '2025-03-28',
    ),
    const TaskEntity(
      id: 4, title: 'Counselling Session',
      description: 'One-on-one counselling for 10 youth at Thane NGO centre.',
      deadline: '2025-03-30', assignedToId: 4,
      assignedToName: 'Meera Nair', assignedToType: AssigneeType.volunteer,
      status: TaskStatus.rejected, requiresUpload: false,
      createdAt: '2025-03-01',
    ),
    const TaskEntity(
      id: 5, title: 'Documentation Drive',
      description: 'Help families obtain Aadhaar cards and ration cards.',
      deadline: '2025-05-10', assignedToId: 4,
      assignedToName: 'Meera Nair', assignedToType: AssigneeType.volunteer,
      status: TaskStatus.pending, requiresUpload: false,
      createdAt: '2025-04-01',
    ),
    const TaskEntity(
      id: 6, title: 'Database Update',
      description: 'Update beneficiary records in the NGO management system.',
      deadline: '2025-04-05', assignedToId: 5,
      assignedToName: 'Karan Mehta', assignedToType: AssigneeType.volunteer,
      status: TaskStatus.approved, requiresUpload: false,
      createdAt: '2025-03-15',
    ),
    // Member tasks
    const TaskEntity(
      id: 7, title: 'Medical Camp Report',
      description: 'Submit detailed report of the Q1 medical camp activities '
          'including patient count and diagnoses.',
      deadline: '2025-04-30', assignedToId: 1,
      assignedToName: 'Dr. Anjali Mehta', assignedToType: AssigneeType.member,
      status: TaskStatus.pending, requiresUpload: true,
      createdAt: '2025-04-01',
    ),
    const TaskEntity(
      id: 8, title: 'Donor Outreach',
      description: 'Contact 5 new potential donors for the annual fundraiser.',
      deadline: '2025-05-15', assignedToId: 1,
      assignedToName: 'Dr. Anjali Mehta', assignedToType: AssigneeType.member,
      status: TaskStatus.submitted, requiresUpload: false,
      submittedAt: '2025-04-12', createdAt: '2025-04-02',
    ),
    const TaskEntity(
      id: 9, title: 'Community Survey',
      description: 'Conduct needs-assessment survey in Nagpur ward 12.',
      deadline: '2025-04-25', assignedToId: 2,
      assignedToName: 'Suresh Patil', assignedToType: AssigneeType.member,
      status: TaskStatus.approved, requiresUpload: false,
      createdAt: '2025-03-20',
    ),
  ];

  // ── Donations ─────────────────────────────────────────────────────────────

  static final List<DonationEntity> donations = [
    const DonationEntity(
      id: 1, donorName: 'TechCorp India Pvt Ltd',
      amount: 500000, date: '2025-03-15',
      type: DonationType.online, receiptGenerated: true,
      receiptNumber: 'RCP-2025-001',
      purpose: 'Annual CSR Contribution', is80G: true,
    ),
    const DonationEntity(
      id: 2, donorName: 'Ramesh Gupta',
      amount: 25000, date: '2025-03-20',
      type: DonationType.cash, receiptGenerated: false,
      purpose: 'Food Drive Support', is80G: false,
    ),
    const DonationEntity(
      id: 3, donorName: 'Sunrise Foundation',
      amount: 150000, date: '2025-02-28',
      type: DonationType.cheque, receiptGenerated: true,
      receiptNumber: 'RCP-2025-002',
      purpose: 'Medical Camp Funding', is80G: true,
    ),
    const DonationEntity(
      id: 4, donorName: 'Prabhavati Devi Trust',
      amount: 75000, date: '2025-02-10',
      type: DonationType.online, receiptGenerated: true,
      receiptNumber: 'RCP-2025-003',
      purpose: 'Education Fund', is80G: true,
    ),
    const DonationEntity(
      id: 5, donorName: 'Anonymous',
      amount: 10000, date: '2025-03-25',
      type: DonationType.cash, receiptGenerated: false,
      purpose: 'General Fund', is80G: false,
    ),
    const DonationEntity(
      id: 6, donorName: 'Mumbai Lions Club',
      amount: 200000, date: '2025-01-30',
      type: DonationType.cheque, receiptGenerated: true,
      receiptNumber: 'RCP-2025-004',
      purpose: 'Scholarship Program', is80G: true,
    ),
  ];

  // ── Monthly donation chart data ────────────────────────────────────────────

  static const List<MonthlyDonationPoint> monthlyDonations = [
    MonthlyDonationPoint(month: 'Oct', amount: 320000),
    MonthlyDonationPoint(month: 'Nov', amount: 450000),
    MonthlyDonationPoint(month: 'Dec', amount: 680000),
    MonthlyDonationPoint(month: 'Jan', amount: 410000),
    MonthlyDonationPoint(month: 'Feb', amount: 520000),
    MonthlyDonationPoint(month: 'Mar', amount: 760000),
  ];

  // ── General requests ──────────────────────────────────────────────────────

  static final List<GeneralRequestEntity> generalRequests = [
    const GeneralRequestEntity(
      id: 1, requestType: GeneralRequestType.joiningLetter,
      requesterName: 'Rahul Sharma', requesterType: 'volunteer',
      requestDate: '2025-03-10', status: RequestStatus.pending,
      details: 'Requesting joining letter for March 2025 volunteer tenure.',
    ),
    const GeneralRequestEntity(
      id: 2, requestType: GeneralRequestType.certificate,
      requesterName: 'Dr. Anjali Mehta', requesterType: 'member',
      requestDate: '2025-03-15', status: RequestStatus.approved,
      details: 'Certificate of Appreciation for Q1 medical camp contribution.',
    ),
    const GeneralRequestEntity(
      id: 3, requestType: GeneralRequestType.joiningLetter,
      requesterName: 'Sneha Kulkarni', requesterType: 'volunteer',
      requestDate: '2025-03-18', status: RequestStatus.pending,
      details: 'Requesting joining letter for April 2025 volunteer tenure.',
    ),
    const GeneralRequestEntity(
      id: 4, requestType: GeneralRequestType.certificate,
      requesterName: 'Meera Nair', requesterType: 'volunteer',
      requestDate: '2025-03-20', status: RequestStatus.rejected,
      details: 'Certificate of Participation – Food Drive March 2025.',
    ),
  ];

  // ── MOU Requests ──────────────────────────────────────────────────────────

  static final List<MouRequestEntity> mouRequests = [
    const MouRequestEntity(
      id: 1, patientName: 'Ramesh Kumar', patientAge: 58,
      disease: 'Cardiac Surgery', hospital: 'KEM Hospital Mumbai',
      requestDate: '2025-03-12', status: RequestStatus.pending,
      requesterName: 'Dr. Anjali Mehta',
      phone: '9876543200', address: 'Worli, Mumbai', bloodGroup: 'B+',
    ),
    const MouRequestEntity(
      id: 2, patientName: 'Sunita Devi', patientAge: 42,
      disease: 'Kidney Dialysis', hospital: 'Hinduja Hospital',
      requestDate: '2025-02-28', status: RequestStatus.approved,
      requesterName: 'Dr. Anjali Mehta',
      phone: '9823456701', address: 'Dharavi, Mumbai', bloodGroup: 'O+',
    ),
  ];

  // ── Joining letter requests ───────────────────────────────────────────────

  static final List<JoiningLetterRequestEntity> joiningLetterRequests = [
    const JoiningLetterRequestEntity(
      id: 1, name: 'Rahul Sharma',
      type: JoiningLetterType.volunteer,
      requestDate: '2025-03-10', status: RequestStatus.pending,
      tenure: 'March 2025', isNewMember: false,
    ),
    const JoiningLetterRequestEntity(
      id: 2, name: 'Sneha Kulkarni',
      type: JoiningLetterType.volunteer,
      requestDate: '2025-03-18', status: RequestStatus.approved,
      tenure: 'April 2025', isNewMember: false, generatedBy: 'Priya Sharma',
    ),
    const JoiningLetterRequestEntity(
      id: 3, name: 'Neha Joshi',
      type: JoiningLetterType.newMember,
      requestDate: '2025-03-22', status: RequestStatus.pending,
      tenure: 'FY 2025-26', isNewMember: true,
    ),
    const JoiningLetterRequestEntity(
      id: 4, name: 'Dr. Anjali Mehta',
      type: JoiningLetterType.member,
      requestDate: '2025-03-05', status: RequestStatus.approved,
      tenure: 'FY 2025-26', isNewMember: false, generatedBy: 'Arjun Kapoor',
    ),
  ];

  // ── Documents ─────────────────────────────────────────────────────────────

  static final List<DocumentEntity> documents = [
    const DocumentEntity(
      id: 1, title: 'NGO Registration Certificate',
      category: 'Legal', fileType: DocumentFileType.pdf,
      size: '2.4 MB', uploadDate: '2020-06-01',
    ),
    const DocumentEntity(
      id: 2, title: '80G Exemption Certificate',
      category: 'Tax', fileType: DocumentFileType.pdf,
      size: '1.1 MB', uploadDate: '2021-03-15',
    ),
    const DocumentEntity(
      id: 3, title: 'Annual Report FY 2024-25',
      category: 'Reports', fileType: DocumentFileType.pdf,
      size: '5.8 MB', uploadDate: '2025-04-01',
    ),
    const DocumentEntity(
      id: 4, title: 'Donation Ledger Q1 2025',
      category: 'Financial', fileType: DocumentFileType.xlsx,
      size: '890 KB', uploadDate: '2025-04-05',
    ),
    const DocumentEntity(
      id: 5, title: 'Board Resolution 2024',
      category: 'Governance', fileType: DocumentFileType.doc,
      size: '340 KB', uploadDate: '2024-12-10',
    ),
    const DocumentEntity(
      id: 6, title: 'Volunteer Policy Handbook',
      category: 'HR', fileType: DocumentFileType.pdf,
      size: '1.6 MB', uploadDate: '2024-09-20',
    ),
    const DocumentEntity(
      id: 7, title: 'KEM Hospital MOU Agreement',
      category: 'Partnerships', fileType: DocumentFileType.pdf,
      size: '760 KB', uploadDate: '2025-01-15',
    ),
    const DocumentEntity(
      id: 8, title: 'Food Drive Project Plan',
      category: 'Projects', fileType: DocumentFileType.doc,
      size: '420 KB', uploadDate: '2025-02-28',
    ),
    const DocumentEntity(
      id: 9, title: 'Volunteer ID Photos',
      category: 'HR', fileType: DocumentFileType.jpg,
      size: '12.3 MB', uploadDate: '2025-03-01',
    ),
    const DocumentEntity(
      id: 10, title: 'FCRA Compliance Report',
      category: 'Legal', fileType: DocumentFileType.pdf,
      size: '3.2 MB', uploadDate: '2025-03-10',
    ),
  ];

  // ── Meetings ──────────────────────────────────────────────────────────────

  static final List<MeetingEntity> meetings = [
    const MeetingEntity(
      id: 1, title: 'Monthly Core Committee Meeting',
      date: '2025-04-20', time: '10:00 AM',
      attendees: ['Dr. Anjali Mehta', 'Suresh Patil', 'Kavita Rao', 'Priya Sharma'],
      status: MeetingStatus.upcoming,
    ),
    const MeetingEntity(
      id: 2, title: 'Q1 Review & Planning Session',
      date: '2025-03-28', time: '11:00 AM',
      attendees: ['Dr. Anjali Mehta', 'Kavita Rao', 'Vikram Bose', 'Priya Sharma'],
      status: MeetingStatus.completed,
      summary: 'Reviewed Q1 targets: food drives achieved 94% reach. '
          'Medical camp treated 320 patients. Decided to increase volunteer '
          'intake by 20% in Q2. Budget approved for new equipment purchase.',
      addedBy: 'Dr. Anjali Mehta',
    ),
    const MeetingEntity(
      id: 3, title: 'Fundraising Strategy Meeting',
      date: '2025-03-10', time: '3:00 PM',
      attendees: ['Dr. Anjali Mehta', 'Suresh Patil', 'Arjun Kapoor'],
      status: MeetingStatus.completed,
      summary: 'Identified 3 new corporate sponsors. Annual gala dinner '
          'planned for December 2025. Online crowdfunding campaign to launch in May.',
      addedBy: 'Suresh Patil',
    ),
    const MeetingEntity(
      id: 4, title: 'Emergency Budget Review',
      date: '2025-05-05', time: '2:00 PM',
      attendees: ['Dr. Anjali Mehta', 'Kavita Rao', 'Vikram Bose'],
      status: MeetingStatus.upcoming,
    ),
  ];
}