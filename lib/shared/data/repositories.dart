import '../../shared/data/entities.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import '../../features/auth/domain/entities/user_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AUTH
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class IAuthRepository {
  /// Returns [UserEntity] if credentials match, null otherwise.
  Future<UserEntity?> login({
    required String email,
    required String password,
  });

  Future<void> logout();
}

// ─────────────────────────────────────────────────────────────────────────────
// VOLUNTEERS
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class IVolunteerRepository {
  Future<List<VolunteerEntity>> getAll();
  Future<VolunteerEntity?>      getById(int id);
  Future<VolunteerEntity>       add(VolunteerEntity volunteer);
  Future<VolunteerEntity>       update(VolunteerEntity volunteer);
  Future<void>                  delete(int id);
}

// ─────────────────────────────────────────────────────────────────────────────
// MEMBERS
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class IMemberRepository {
  Future<List<MemberEntity>> getAll();
  Future<MemberEntity?>      getById(int id);
  Future<MemberEntity>       add(MemberEntity member);
  Future<MemberEntity>       update(MemberEntity member);
  Future<void>               delete(int id);
}

// ─────────────────────────────────────────────────────────────────────────────
// TASKS
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class ITaskRepository {
  Future<List<TaskEntity>> getAll();
  Future<List<TaskEntity>> getByAssignee(int assigneeId, AssigneeType type);
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
  Future<DonationEntity>       add(DonationEntity donation);

  /// Marks a donation as receipt-generated and stores the receipt number.
  Future<DonationEntity> generateReceipt(int donationId, String receiptNumber);
}

// ─────────────────────────────────────────────────────────────────────────────
// GENERAL REQUESTS
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class IGeneralRequestRepository {
  Future<List<GeneralRequestEntity>> getAll();
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
  Future<List<DocumentEntity>> getByCategory(String category);
}

// ─────────────────────────────────────────────────────────────────────────────
// MEETINGS
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class IMeetingRepository {
  Future<List<MeetingEntity>> getAll();
  Future<MeetingEntity>       addSummary(
    int meetingId, {
    required String summary,
    required String addedBy,
  });
}