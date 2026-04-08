import 'dart:async';
import '../../shared/data/entities.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import 'package:ngo_volunteer_management/domain/entities/donation.entity.dart';
// ─────────────────────────────────────────────────────────────────────────────
// AUTH
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class IAuthRepository {
  /// Returns [UserEntity] if credentials match, null otherwise.
  Future<UserEntity?> login({
    required String email,
    required String password,
  });

  /// Real-time stream of the authentication state (useful for Firebase Auth)
  Stream<UserEntity?> watchAuthState();

  Future<void> logout();
}

// ─────────────────────────────────────────────────────────────────────────────
// VOLUNTEERS
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class IVolunteerRepository {
  Future<List<VolunteerEntity>> getAll();
  Stream<List<VolunteerEntity>> watchAll(); // Real-time Firebase support
  
  Future<VolunteerEntity?>      getById(int id);
  Stream<VolunteerEntity?>      watchById(int id);
  
  Future<VolunteerEntity>       add(VolunteerEntity volunteer);
  Future<VolunteerEntity>       update(VolunteerEntity volunteer);
  Future<void>                  delete(int id);
}

// ─────────────────────────────────────────────────────────────────────────────
// MEMBERS
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class IMemberRepository {
  Future<List<MemberEntity>> getAll();
  Stream<List<MemberEntity>> watchAll(); // Real-time Firebase support
  
  Future<MemberEntity?>      getById(int id);
  Stream<MemberEntity?>      watchById(int id);
  
  Future<MemberEntity>       add(MemberEntity member);
  Future<MemberEntity>       update(MemberEntity member);
  Future<void>               delete(int id);
}

// ─────────────────────────────────────────────────────────────────────────────
// TASKS
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class ITaskRepository {
  Future<List<TaskEntity>> getAll();
  Stream<List<TaskEntity>> watchAll(); // Real-time Firebase support
  
  Future<List<TaskEntity>> getByAssignee(int assigneeId, AssigneeType type);
  Stream<List<TaskEntity>> watchByAssignee(int assigneeId, AssigneeType type);
  
  Future<TaskEntity>       add(TaskEntity task);
  Future<TaskEntity>       update(TaskEntity task);

  /// Convenience: approve / reject in one call.
  Future<TaskEntity> updateStatus(int taskId, TaskStatus status);
}

// ─────────────────────────────────────────────────────────────────────────────
// DONATIONS
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class IDonationRepository {
  Future<List<DonationEntity>> getAll();
  Stream<List<DonationEntity>> watchAll(); // Real-time Firebase support
  
  Future<DonationEntity>       add(DonationEntity donation);

  /// Marks a donation as receipt-generated and stores the receipt number.
  Future<DonationEntity> generateReceipt(int donationId, String receiptNumber);
}

// ─────────────────────────────────────────────────────────────────────────────
// GENERAL REQUESTS
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class IGeneralRequestRepository {
  Future<List<GeneralRequestEntity>> getAll();
  Stream<List<GeneralRequestEntity>> watchAll(); // Real-time Firebase support
  
  Future<GeneralRequestEntity>       add(GeneralRequestEntity request);
  Future<GeneralRequestEntity>       updateStatus(
    int id,
    RequestStatus status,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// MOU REQUESTS
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class IMouRequestRepository {
  Future<List<MouRequestEntity>> getAll();
  Stream<List<MouRequestEntity>> watchAll(); // Real-time Firebase support
  
  Future<MouRequestEntity>       add(MouRequestEntity request);
  Future<MouRequestEntity>       updateStatus(
    int id,
    RequestStatus status,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// JOINING LETTER REQUESTS
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class IJoiningLetterRepository {
  Future<List<JoiningLetterRequestEntity>> getAll();
  Stream<List<JoiningLetterRequestEntity>> watchAll(); // Real-time Firebase support
  
  Future<JoiningLetterRequestEntity>       add(JoiningLetterRequestEntity request);
  Future<JoiningLetterRequestEntity>       approve(
    int id, {
    required String generatedBy,
    required String tenure,
  });
  Future<JoiningLetterRequestEntity> reject(int id);
}

// ─────────────────────────────────────────────────────────────────────────────
// DOCUMENTS
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class IDocumentRepository {
  Future<List<DocumentEntity>> getAll();
  Stream<List<DocumentEntity>> watchAll(); // Real-time Firebase support
  
  Future<List<DocumentEntity>> getByCategory(String category);
  Stream<List<DocumentEntity>> watchByCategory(String category);
}

// ─────────────────────────────────────────────────────────────────────────────
// MEETINGS
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class IMeetingRepository {
  Future<List<MeetingEntity>> getAll();
  Stream<List<MeetingEntity>> watchAll(); // Real-time Firebase support
  
  Future<MeetingEntity>       addMeeting(MeetingEntity meeting);

  Future<MeetingEntity>       addSummary(
    int meetingId, {
    required String summary,
    required String addedBy,
  });
}