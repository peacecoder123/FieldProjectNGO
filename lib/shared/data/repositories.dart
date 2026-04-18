import 'dart:async';
import '../../shared/data/entities.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import 'package:ngo_volunteer_management/domain/entities/donation.entity.dart';

abstract interface class IAuthRepository {
  Future<UserEntity?> login({required String email, required String password});
  Future<UserEntity?> loginWithGoogle();
  Stream<UserEntity?> watchAuthState();
  Future<void> logout();
  Future<void> resetPassword(String email);
  
  /// Syncs device FCM token with Firestore user document
  Future<void> updateFcmToken(String userId, String? token);
}

abstract interface class IVolunteerRepository {
  Future<List<VolunteerEntity>> getAll();
  Stream<List<VolunteerEntity>> watchAll();
  Future<VolunteerEntity?> getById(String id);
  Stream<VolunteerEntity?> watchById(String id);
  Future<VolunteerEntity> add(VolunteerEntity volunteer);
  Future<VolunteerEntity> update(VolunteerEntity volunteer);
  Future<void> delete(String id);
}

abstract interface class IMemberRepository {
  Future<List<MemberEntity>> getAll();
  Stream<List<MemberEntity>> watchAll();
  Future<MemberEntity?> getById(String id);
  Stream<MemberEntity?> watchById(String id);
  Future<MemberEntity> add(MemberEntity member);
  Future<MemberEntity> update(MemberEntity member);
  Future<void> delete(String id);
}

abstract interface class ITaskRepository {
  Future<List<TaskEntity>> getAll();
  Stream<List<TaskEntity>> watchAll();
  Future<List<TaskEntity>> getByAssignee(String assigneeId, AssigneeType type);
  Stream<List<TaskEntity>> watchByAssignee(String assigneeId, AssigneeType type);
  Future<TaskEntity> add(TaskEntity task);
  Future<TaskEntity> update(TaskEntity task);
  Future<TaskEntity> updateStatus(String taskId, TaskStatus status, {String? approvedBy});
}

abstract interface class IDonationRepository {
  Future<List<DonationEntity>> getAll();
  Stream<List<DonationEntity>> watchAll(); // Real-time Firebase support
  
  Future<DonationEntity>       add(DonationEntity donation);
  Future<DonationEntity>       update(DonationEntity donation);
  Future<void>                 updatePaymentStatus(String donationId, PaymentStatus status);

  /// Marks a donation as receipt-generated and stores the receipt number.
  Future<DonationEntity> generateReceipt(String donationId, String receiptNumber);
}

abstract interface class IGeneralRequestRepository {
  Future<List<GeneralRequestEntity>> getAll();
  Stream<List<GeneralRequestEntity>> watchAll();
  Future<GeneralRequestEntity> add(GeneralRequestEntity request);
  Future<GeneralRequestEntity> updateStatus(String id, RequestStatus status, {String? approvedBy});
}

abstract interface class IMouRequestRepository {
  Future<List<MouRequestEntity>> getAll();
  Stream<List<MouRequestEntity>> watchAll();
  Future<MouRequestEntity> add(MouRequestEntity request);
  Future<MouRequestEntity> updateStatus(String id, RequestStatus status, {String? approvedBy});
}

abstract interface class IHospitalRepository {
  Future<List<HospitalEntity>> getAll();
  Stream<List<HospitalEntity>> watchAll();
  Future<HospitalEntity> add(HospitalEntity hospital);
  Future<void> delete(String id);
}

abstract interface class IJoiningLetterRepository {
  Future<List<JoiningLetterRequestEntity>> getAll();
  Stream<List<JoiningLetterRequestEntity>> watchAll();
  Future<JoiningLetterRequestEntity> add(JoiningLetterRequestEntity request);
  Future<JoiningLetterRequestEntity> approve(String id, {required String generatedBy, required String tenure});
  Future<JoiningLetterRequestEntity> partiallyApprove(String id);
  Future<JoiningLetterRequestEntity> reject(String id);
}

abstract interface class IDocumentRepository {
  Future<List<DocumentEntity>> getAll();
  Stream<List<DocumentEntity>> watchAll();
  Future<List<DocumentEntity>> getByCategory(String category);
  Stream<List<DocumentEntity>> watchByCategory(String category);
}

abstract interface class IMeetingRepository {
  Future<List<MeetingEntity>> getAll();
  Stream<List<MeetingEntity>> watchAll(); // Real-time Firebase support
  
  Future<MeetingEntity>       addMeeting(MeetingEntity meeting);

  Future<MeetingEntity>       addSummary(
    String meetingId, {
    required String summary,
    required String addedBy,
  });

  Future<MeetingEntity>       markCompleted(String meetingId, {required String summaryAssignedTo});
}