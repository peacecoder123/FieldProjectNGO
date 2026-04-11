import 'package:equatable/equatable.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VOLUNTEER
// ─────────────────────────────────────────────────────────────────────────────

class VolunteerEntity extends Equatable {
  const VolunteerEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.joinDate,
    required this.status,
    required this.assignedAdmin,
    required this.taskIds,
    required this.tenure,
    required this.skills,
    required this.avatar,
    this.mentorId,
    this.mentorName,
  });

  final String       id;
  final String       name;
  final String       email;
  final String       phone;
  final String       address;
  final String       joinDate;
  final PersonStatus status;
  final String       assignedAdmin;
  final List<String> taskIds;
  final String       tenure;
  final List<String> skills;
  final String       avatar;
  final String?       mentorId;
  final String?       mentorName;


  VolunteerEntity copyWith({
    String?       id,
    String?       name,
    String?       email,
    String?       phone,
    String?       address,
    String?       joinDate,
    PersonStatus? status,
    String?       assignedAdmin,
    List<String>? taskIds,
    String?       tenure,
    List<String>? skills,
    String?       avatar,
    String?       mentorId,
    String?       mentorName,
  }) =>
      VolunteerEntity(
        id:            id            ?? this.id,
        name:          name          ?? this.name,
        email:         email         ?? this.email,
        phone:         phone         ?? this.phone,
        address:       address       ?? this.address,
        joinDate:      joinDate      ?? this.joinDate,
        status:        status        ?? this.status,
        assignedAdmin: assignedAdmin ?? this.assignedAdmin,
        taskIds:       taskIds       ?? this.taskIds,
        tenure:        tenure        ?? this.tenure,
        skills:        skills        ?? this.skills,
        avatar:        avatar        ?? this.avatar,
        mentorId:      mentorId      ?? this.mentorId,
        mentorName:    mentorName    ?? this.mentorName,
      );

  @override
  List<Object?> get props =>
      [id, name, email, phone, address, joinDate, status,
       assignedAdmin, taskIds, tenure, skills, avatar, mentorId, mentorName];
}

// ─────────────────────────────────────────────────────────────────────────────
// MEMBER
// ─────────────────────────────────────────────────────────────────────────────

class MemberEntity extends Equatable {
  const MemberEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.joinDate,
    required this.renewalDate,
    required this.status,
    required this.membershipType,
    required this.taskIds,
    required this.isPaid,
    required this.avatar,
  });

  final String         id;
  final String         name;
  final String         email;
  final String         phone;
  final String         address;
  final String         joinDate;
  final String         renewalDate;
  final PersonStatus   status;
  final MembershipType membershipType;
  final List<String>   taskIds;
  final bool           isPaid;
  final String         avatar;

  MemberEntity copyWith({
    String?         id,
    String?         name,
    String?         email,
    String?         phone,
    String?         address,
    String?         joinDate,
    String?         renewalDate,
    PersonStatus?   status,
    MembershipType? membershipType,
    List<String>?   taskIds,
    bool?           isPaid,
    String?         avatar,
  }) =>
      MemberEntity(
        id:             id             ?? this.id,
        name:           name           ?? this.name,
        email:          email          ?? this.email,
        phone:          phone          ?? this.phone,
        address:        address        ?? this.address,
        joinDate:       joinDate       ?? this.joinDate,
        renewalDate:    renewalDate    ?? this.renewalDate,
        status:         status         ?? this.status,
        membershipType: membershipType ?? this.membershipType,
        taskIds:        taskIds        ?? this.taskIds,
        isPaid:         isPaid         ?? this.isPaid,
        avatar:         avatar         ?? this.avatar,
      );

  @override
  List<Object?> get props =>
      [id, name, email, phone, address, joinDate, renewalDate,
       status, membershipType, taskIds, isPaid, avatar];
}

// ─────────────────────────────────────────────────────────────────────────────
// TASK
// ─────────────────────────────────────────────────────────────────────────────

class TaskEntity extends Equatable {
  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.assignedToId,
    required this.assignedToName,
    required this.assignedToType,
    required this.status,
    required this.requiresUpload,
    required this.createdAt,
    this.uploadedImage,
    this.submittedAt,
    this.geotag,
    this.approvedBy,
    this.approvedAt,
  });

  final String       id;
  final String       title;
  final String       description;
  final String       deadline;
  final String       assignedToId;
  final String       assignedToName;
  final AssigneeType assignedToType;
  final TaskStatus   status;
  final bool         requiresUpload;
  final String       createdAt;
  final String?      uploadedImage;
  final String?      submittedAt;
  final String?      geotag;
  final String?      approvedBy;
  final String?      approvedAt;

  TaskEntity copyWith({
    String?       id,
    String?       title,
    String?       description,
    String?       deadline,
    String?       assignedToId,
    String?       assignedToName,
    AssigneeType? assignedToType,
    TaskStatus?   status,
    bool?         requiresUpload,
    String?       createdAt,
    String?       uploadedImage,
    String?       submittedAt,
    String?       geotag,
    String?       approvedBy,
    String?       approvedAt,
  }) =>
      TaskEntity(
        id:             id             ?? this.id,
        title:          title          ?? this.title,
        description:    description    ?? this.description,
        deadline:       deadline       ?? this.deadline,
        assignedToId:   assignedToId   ?? this.assignedToId,
        assignedToName: assignedToName ?? this.assignedToName,
        assignedToType: assignedToType ?? this.assignedToType,
        status:         status         ?? this.status,
        requiresUpload: requiresUpload ?? this.requiresUpload,
        createdAt:      createdAt      ?? this.createdAt,
        uploadedImage:  uploadedImage  ?? this.uploadedImage,
        submittedAt:    submittedAt    ?? this.submittedAt,
        geotag:         geotag         ?? this.geotag,
        approvedBy:     approvedBy     ?? this.approvedBy,
        approvedAt:     approvedAt     ?? this.approvedAt,
      );

  @override
  List<Object?> get props =>
      [id, title, description, deadline, assignedToId, assignedToName,
       assignedToType, status, requiresUpload, createdAt,
       uploadedImage, submittedAt, geotag, approvedBy, approvedAt];
}

// ─────────────────────────────────────────────────────────────────────────────
// GENERAL REQUEST  (joining-letter | certificate)
// ─────────────────────────────────────────────────────────────────────────────

class GeneralRequestEntity extends Equatable {
  const GeneralRequestEntity({
    required this.id,
    required this.requestType,
    required this.requesterName,
    required this.requesterType,
    required this.requestDate,
    required this.status,
    required this.details,
    this.approvedBy,
    this.approvedAt,
  });

  final String             id;
  final GeneralRequestType requestType;
  final String             requesterName;
  final String             requesterType;   // 'volunteer' | 'member'
  final String             requestDate;
  final RequestStatus      status;
  final String             details;
  final String?            approvedBy;
  final String?            approvedAt;

  GeneralRequestEntity copyWith({
    String?             id,
    GeneralRequestType? requestType,
    String?             requesterName,
    String?             requesterType,   // 'volunteer' | 'member'
    String?             requestDate,
    RequestStatus?      status,
    String?             details,
    String?             approvedBy,
    String?             approvedAt,
  }) =>
      GeneralRequestEntity(
        id:            id            ?? this.id,
        requestType:   requestType   ?? this.requestType,
        requesterName: requesterName ?? this.requesterName,
        requesterType: requesterType ?? this.requesterType,
        requestDate:   requestDate   ?? this.requestDate,
        status:        status        ?? this.status,
        details:       details       ?? this.details,
        approvedBy:    approvedBy    ?? this.approvedBy,
        approvedAt:    approvedAt    ?? this.approvedAt,
      );

  @override
  List<Object?> get props =>
      [id, requestType, requesterName, requesterType,
       requestDate, status, details, approvedBy, approvedAt];
}

// ─────────────────────────────────────────────────────────────────────────────
// MOU REQUEST (hospital / medical)
// ─────────────────────────────────────────────────────────────────────────────

class MouRequestEntity extends Equatable {
  const MouRequestEntity({
    required this.id,
    required this.patientName,
    required this.patientAge,
    required this.disease,
    required this.hospital,
    required this.requestDate,
    required this.status,
    required this.requesterName,
    required this.phone,
    required this.address,
    required this.bloodGroup,
    this.approvedBy,
    this.approvedAt,
  });

  final String        id;
  final String        patientName;
  final int           patientAge;
  final String        disease;
  final String        hospital;
  final String        requestDate;
  final RequestStatus status;
  final String        requesterName;
  final String        phone;
  final String        address;
  final String        bloodGroup;
  final String?       approvedBy;
  final String?       approvedAt;

  MouRequestEntity copyWith({
    String?        id,
    String?        patientName,
    int?           patientAge,
    String?        disease,
    String?        hospital,
    String?        requestDate,
    RequestStatus? status,
    String?        requesterName,
    String?        phone,
    String?        address,
    String?        bloodGroup,
    String?        approvedBy,
    String?        approvedAt,
  }) =>
      MouRequestEntity(
        id:            id            ?? this.id,
        patientName:   patientName   ?? this.patientName,
        patientAge:    patientAge    ?? this.patientAge,
        disease:       disease       ?? this.disease,
        hospital:      hospital      ?? this.hospital,
        requestDate:   requestDate   ?? this.requestDate,
        status:        status        ?? this.status,
        requesterName: requesterName ?? this.requesterName,
        phone:         phone         ?? this.phone,
        address:       address       ?? this.address,
        bloodGroup:    bloodGroup    ?? this.bloodGroup,
        approvedBy:    approvedBy    ?? this.approvedBy,
        approvedAt:    approvedAt    ?? this.approvedAt,
      );

  @override
  List<Object?> get props =>
      [id, patientName, patientAge, disease, hospital, requestDate,
       status, requesterName, phone, address, bloodGroup, approvedBy, approvedAt];
}

// ─────────────────────────────────────────────────────────────────────────────
// JOINING LETTER REQUEST
// ─────────────────────────────────────────────────────────────────────────────

class JoiningLetterRequestEntity extends Equatable {
  const JoiningLetterRequestEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.requestDate,
    required this.status,
    required this.tenure,
    this.isNewMember = false,
    this.generatedBy,
  });

  final String            id;
  final String            name;
  final JoiningLetterType type;
  final String            requestDate;
  final RequestStatus     status;
  final String            tenure;
  final bool              isNewMember;
  final String?           generatedBy;

  JoiningLetterRequestEntity copyWith({
    String?            id,
    String?            name,
    JoiningLetterType? type,
    String?            requestDate,
    RequestStatus?     status,
    String?            tenure,
    bool?              isNewMember,
    String?            generatedBy,
  }) =>
      JoiningLetterRequestEntity(
        id:          id          ?? this.id,
        name:        name        ?? this.name,
        type:        type        ?? this.type,
        requestDate: requestDate ?? this.requestDate,
        status:      status      ?? this.status,
        tenure:      tenure      ?? this.tenure,
        isNewMember: isNewMember ?? this.isNewMember,
        generatedBy: generatedBy ?? this.generatedBy,
      );

  @override
  List<Object?> get props =>
      [id, name, type, requestDate, status, tenure, isNewMember, generatedBy];
}

// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// DOCUMENT
// ─────────────────────────────────────────────────────────────────────────────

class DocumentEntity extends Equatable {
  const DocumentEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.fileType,
    required this.size,
    required this.uploadDate,
    this.downloadUrl,
  });

  final String           id;
  final String           title;
  final String           category;
  final DocumentFileType fileType;
  final String           size;
  final String           uploadDate;
  final String?          downloadUrl;

  DocumentEntity copyWith({
    String?           id,
    String?           title,
    String?           category,
    DocumentFileType? fileType,
    String?           size,
    String?           uploadDate,
    String?          downloadUrl,
  }) =>
      DocumentEntity(
        id:          id          ?? this.id,
        title:       title       ?? this.title,
        category:    category    ?? this.category,
        fileType:    fileType    ?? this.fileType,
        size:        size        ?? this.size,
        uploadDate:  uploadDate  ?? this.uploadDate,
        downloadUrl: downloadUrl ?? this.downloadUrl,
      );

  @override
  List<Object?> get props =>
      [id, title, category, fileType, size, uploadDate, downloadUrl];
}

// ─────────────────────────────────────────────────────────────────────────────
// MEETING
// ─────────────────────────────────────────────────────────────────────────────

class MeetingEntity extends Equatable {
  const MeetingEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.attendees,
    required this.status,
    this.summary,
    this.addedBy,
    this.link,
    this.summaryAssignedTo,
  });

  final String        id;
  final String        title;
  final String        date;
  final String        time;
  final List<String>  attendees;
  final MeetingStatus status;
  final String?       summary;
  final String?       addedBy;
  final String?       link;
  final String?       summaryAssignedTo; // 'Admin' or 'Member'

  MeetingEntity copyWith({
    String?        id,
    String?        title,
    String?        date,
    String?        time,
    List<String>?  attendees,
    MeetingStatus? status,
    String?        summary,
    String?        addedBy,
    String?        link,
    String?        summaryAssignedTo,
  }) =>
      MeetingEntity(
        id:                 id                 ?? this.id,
        title:              title              ?? this.title,
        date:               date               ?? this.date,
        time:               time               ?? this.time,
        attendees:          attendees          ?? this.attendees,
        status:             status             ?? this.status,
        summary:            summary            ?? this.summary,
        addedBy:            addedBy            ?? this.addedBy,
        link:               link               ?? this.link,
        summaryAssignedTo:  summaryAssignedTo  ?? this.summaryAssignedTo,
      );

  @override
  List<Object?> get props =>
      [id, title, date, time, attendees, status, summary, addedBy, link, summaryAssignedTo];
}

// ─────────────────────────────────────────────────────────────────────────────
// MONTHLY DONATION CHART POINT
// ─────────────────────────────────────────────────────────────────────────────

class MonthlyDonationPoint extends Equatable {
  const MonthlyDonationPoint({
    required this.month,
    required this.amount,
  });

  final String month;
  final int    amount;

  @override
  List<Object?> get props => [month, amount];
}