import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/domain/entities/donation.entity.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';
import '../data/entities.dart';
import '../data/repositories.dart';
import '../../services/notification_service.dart';

// Firebase repositories
import '../../features/payments/repositories/donation_repository.dart';
import '../../features/volunteers/repositories/firebase_volunteer_repository.dart';
import '../../features/members/repositories/firebase_member_repository.dart';
import '../../features/tasks/repositories/firebase_task_repository.dart';
import '../../features/requests/repositories/firebase_general_request_repository.dart';
import '../../features/requests/repositories/firebase_mou_request_repository.dart';
import '../../features/requests/repositories/firebase_hospital_repository.dart';
import '../../features/joining_letters/repositories/firebase_joining_letter_repository.dart';
import '../../features/meetings/repositories/firebase_meeting_repository.dart';
import '../../features/documents/repositories/document_request_repository.dart';
import '../../features/documents/repositories/firebase_document_request_repository.dart';
import '../../features/documents/repositories/firebase_document_storage_repository.dart';
import 'package:ngo_volunteer_management/domain/entities/document_request.entity.dart';
import '../../features/auth/repositories/firebase_auth_repository.dart';
import '../../features/requests/repositories/firebase_hospital_repository.dart';
import '../../features/admin/data/user_repository.dart';
import '../../features/auth/domain/entities/user_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REPOSITORY PROVIDERS — All wired to Firebase (Firestore)
// ─────────────────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<IAuthRepository>(
  (_) => FirebaseAuthRepository(),
);
final volunteerRepositoryProvider = Provider<IVolunteerRepository>(
  (_) => FirebaseVolunteerRepository(),
);
final memberRepositoryProvider = Provider<IMemberRepository>(
  (_) => FirebaseMemberRepository(),
);
final taskRepositoryProvider = Provider<ITaskRepository>(
  (_) => FirebaseTaskRepository(),
);

// ── Donations — Firebase Repository ──
final donationRepositoryProvider = Provider<IDonationRepository>(
  (_) => DonationRepository(),
);

final generalRequestRepositoryProvider = Provider<IGeneralRequestRepository>(
  (_) => FirebaseGeneralRequestRepository(),
);
final mouRequestRepositoryProvider = Provider<IMouRequestRepository>(
  (_) => FirebaseMouRequestRepository(),
);
final hospitalRepositoryProvider = Provider<IHospitalRepository>(
  (_) => FirebaseHospitalRepository(),
);
final joiningLetterRepositoryProvider = Provider<IJoiningLetterRepository>(
  (_) => FirebaseJoiningLetterRepository(),
);
// Document storage backed by Firebase Storage + Firestore
final documentStorageRepoProvider = Provider<FirebaseDocumentStorageRepository>(
  (_) => FirebaseDocumentStorageRepository(),
);

final meetingRepositoryProvider = Provider<IMeetingRepository>(
  (_) => FirebaseMeetingRepository(),
);
final documentRequestRepositoryProvider = Provider<IDocumentRequestRepository>(
  (_) => FirebaseDocumentRequestRepository(),
);
final userRepositoryProvider = Provider<UserRepository>(
  (_) => UserRepository(),
);

// ─────────────────────────────────────────────────────────────────────────────
// VOLUNTEER STATE (REAL-TIME STREAM)
// ─────────────────────────────────────────────────────────────────────────────

class VolunteerNotifier extends StateNotifier<AsyncValue<List<VolunteerEntity>>> {
  final IVolunteerRepository _repo;
  StreamSubscription<List<VolunteerEntity>>? _subscription;

  VolunteerNotifier(this._repo) : super(const AsyncValue.loading()) {
    _listen();
  }

  void _listen() {
    _subscription = _repo.watchAll().listen(
      (list) => state = AsyncValue.data(list),
      onError: (err, st) => state = AsyncValue.error(err, st),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> add(VolunteerEntity v) => _repo.add(v);
  Future<void> update(VolunteerEntity v) => _repo.update(v);
  Future<void> delete(String id) => _repo.delete(id);
}

final volunteerProvider = StateNotifierProvider<
    VolunteerNotifier, AsyncValue<List<VolunteerEntity>>>(
  (ref) => VolunteerNotifier(ref.watch(volunteerRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// MEMBER STATE (REAL-TIME STREAM)
// ─────────────────────────────────────────────────────────────────────────────

class MemberNotifier extends StateNotifier<AsyncValue<List<MemberEntity>>> {
  final IMemberRepository _repo;
  StreamSubscription<List<MemberEntity>>? _subscription;

  MemberNotifier(this._repo) : super(const AsyncValue.loading()) {
    _listen();
  }

  void _listen() {
    _subscription = _repo.watchAll().listen(
      (list) => state = AsyncValue.data(list),
      onError: (err, st) => state = AsyncValue.error(err, st),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> add(MemberEntity m) => _repo.add(m);
  Future<void> update(MemberEntity m) => _repo.update(m);
  Future<void> delete(String id) => _repo.delete(id);
}

final memberProvider =
    StateNotifierProvider<MemberNotifier, AsyncValue<List<MemberEntity>>>(
  (ref) => MemberNotifier(ref.watch(memberRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// TASK STATE (REAL-TIME STREAM)
// ─────────────────────────────────────────────────────────────────────────────

class TaskNotifier extends StateNotifier<AsyncValue<List<TaskEntity>>> {
  final ITaskRepository _repo;
  StreamSubscription<List<TaskEntity>>? _subscription;

  TaskNotifier(this._repo) : super(const AsyncValue.loading()) {
    _listen();
  }

  void _listen() {
    _subscription = _repo.watchAll().listen(
      (list) => state = AsyncValue.data(list),
      onError: (err, st) => state = AsyncValue.error(err, st),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> add(TaskEntity t) async {
    await _repo.add(t);
    _notify('New Task Assigned', 'A new task "${t.title}" has been assigned to you.');
  }

  Future<void> updateStatus(String taskId, TaskStatus status, {String? approvedBy}) async {
    await _repo.updateStatus(taskId, status, approvedBy: approvedBy);
    
    final t = state.value?.firstWhere((task) => task.id == taskId);
    if (t != null) {
      if (status == TaskStatus.waitingAdmin) {
        _notify('Task Partially Approved', 'Mentor has partially approved "${t.title}". Waiting for Admin.');
      } else if (status == TaskStatus.approved) {
        _notify('Task Approved', 'Your submission for "${t.title}" has been fully approved!');
      } else if (status == TaskStatus.rejected) {
        _notify('Task Rejected', 'Submission for "${t.title}" was rejected.');
      }
    }
  }

  void _notify(String title, String body) {
    PushNotificationService.instance.showNotification(title: title, body: body);
  }

  Future<void> submit(String taskId, {String? imagePath, String? geotag}) async {
    final current = state.value?.firstWhere((t) => t.id == taskId);
    if (current == null) return;
    await _repo.update(
      current.copyWith(
        status:        TaskStatus.submitted,
        submittedAt:   AppFormatters.today(),
        uploadedImage: imagePath ?? current.uploadedImage,
        geotag:        geotag ?? current.geotag,
      ),
    );
  }
}

final taskProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<List<TaskEntity>>>(
  (ref) => TaskNotifier(ref.watch(taskRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// DONATION STATE (FIREBASE REAL-TIME SYNC)
// ─────────────────────────────────────────────────────────────────────────────

class DonationNotifier extends StateNotifier<AsyncValue<List<DonationEntity>>> {
  final IDonationRepository _repository;
  StreamSubscription<List<DonationEntity>>? _subscription;

  DonationNotifier(this._repository) : super(const AsyncValue.loading()) {
    _listenToFirebase();
  }

  void _listenToFirebase() {
    _subscription = _repository.watchAll().listen(
      (donations) {
        state = AsyncValue.data(donations);
      },
      onError: (error, stackTrace) {
        debugPrint('Firebase Stream Error: $error');
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> add(DonationEntity donation) async {
    try {
      await _repository.add(donation);
      // State updates automatically via the Stream
    } catch (e, st) {
      debugPrint("Firebase Add Error: $e");
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> generateReceipt(String id) async {
    try {
      final receiptNum = 'REC-${DateTime.now().year}-$id';
      await _repository.generateReceipt(id, receiptNum);
      // State updates automatically via the Stream
    } catch (e, st) {
      debugPrint("Firebase Update Error: $e");
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updatePaymentStatus(String id, PaymentStatus status) async {
    try {
      await _repository.updatePaymentStatus(id, status);
      // State updates automatically via the Stream
    } catch (e, st) {
      debugPrint("Firebase Update Payment Status Error: $e");
      state = AsyncValue.error(e, st);
    }
  }
}

final donationProvider =
    StateNotifierProvider<DonationNotifier, AsyncValue<List<DonationEntity>>>(
  (ref) => DonationNotifier(ref.watch(donationRepositoryProvider)),
);

// ── Aggregation for Dashboard Charts ──
final monthlyDonationAggregationProvider = Provider<List<MonthlyDonationPoint>>((ref) {
  final donationsState = ref.watch(donationProvider);
  final donations = donationsState.value ?? [];
  
  // Filter for success/pending payments (mostly ignore failed, but let's just include success or all for a real app. For MVP, we'll do all except failed)
  final validDonations = donations.where((d) => d.paymentStatus != PaymentStatus.failed).toList();
  
  if (validDonations.isEmpty) return [];

  // Group by month-year
  final grouped = <String, int>{};
  for (final d in validDonations) {
    if (d.date.isEmpty) continue;
    // Assume date format: "dd MMM yyyy" or "dd/MM/yyyy"
    // Just a basic parsing for "MMM yyyy" or default to month if it's simpler
    // Real parsing:
    try {
      // Very naive splitting, assume "26 Mar 2026"  -> month="Mar"
      final parts = d.date.split(' ');
      if (parts.length >= 2) {
        final monthStr = parts[1]; // 'Mar'
        grouped[monthStr] = (grouped[monthStr] ?? 0) + d.amount;
      }
    } catch (_) {}
  }
  
  final result = grouped.entries.map((e) => MonthlyDonationPoint(month: e.key, amount: e.value)).toList();
  // We can sort them if needed, but for MVP it's OK.
  return result.isEmpty ? [const MonthlyDonationPoint(month: 'Mar', amount: 0)] : result;
});

// ─────────────────────────────────────────────────────────────────────────────
// GENERAL REQUEST STATE
// ─────────────────────────────────────────────────────────────────────────────

class GeneralRequestNotifier
    extends StateNotifier<AsyncValue<List<GeneralRequestEntity>>> {
  final IGeneralRequestRepository _repo;
  StreamSubscription<List<GeneralRequestEntity>>? _subscription;

  GeneralRequestNotifier(this._repo) : super(const AsyncValue.loading()) {
    _listen();
  }

  void _listen() {
    _subscription = _repo.watchAll().listen(
      (list) => state = AsyncValue.data(list),
      onError: (err, st) => state = AsyncValue.error(err, st),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> add(GeneralRequestEntity r) async {
    await _repo.add(r);
    _notify('Request Submitted', 'Your general request has been sent for review.');
  }

  Future<void> partiallyApprove(String id, {String? approvedBy}) async {
    await _repo.updateStatus(id, RequestStatus.waitingAdmin, approvedBy: approvedBy);
    _notify('Request Escalated', 'A request has been partially approved and sent to Admin.');
  }

  Future<void> approve(String id, {String? approvedBy}) async {
    await _repo.updateStatus(id, RequestStatus.approved, approvedBy: approvedBy);
    _notify('Request Approved', 'Your general request was approved!');
  }

  Future<void> reject(String id) async {
    await _repo.updateStatus(id, RequestStatus.rejected);
    _notify('Request Rejected', 'A request was rejected.');
  }

  void _notify(String title, String body) {
    PushNotificationService.instance.showNotification(title: title, body: body);
  }
}

final generalRequestProvider = StateNotifierProvider<GeneralRequestNotifier,
    AsyncValue<List<GeneralRequestEntity>>>(
  (ref) =>
      GeneralRequestNotifier(ref.watch(generalRequestRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// MOU REQUEST STATE
// ─────────────────────────────────────────────────────────────────────────────

class MouRequestNotifier
    extends StateNotifier<AsyncValue<List<MouRequestEntity>>> {
  final IMouRequestRepository _repo;
  StreamSubscription<List<MouRequestEntity>>? _subscription;

  MouRequestNotifier(this._repo) : super(const AsyncValue.loading()) {
    _listen();
  }

  void _listen() {
    _subscription = _repo.watchAll().listen(
      (list) => state = AsyncValue.data(list),
      onError: (err, st) => state = AsyncValue.error(err, st),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> add(MouRequestEntity r) async {
    await _repo.add(r);
    _notify('MOU Request Submitted', 'New MOU request for ${r.patientName}.');
  }

  Future<void> partiallyApprove(String id, {String? approvedBy}) async {
    await _repo.updateStatus(id, RequestStatus.waitingAdmin, approvedBy: approvedBy);
    _notify('MOU Escalated', 'MOU request partially approved.');
  }

  Future<void> approve(String id, {String? approvedBy}) async {
    await _repo.updateStatus(id, RequestStatus.approved, approvedBy: approvedBy);
    _notify('MOU Approved', 'MOU request completed.');
  }

  Future<void> reject(String id) async {
    await _repo.updateStatus(id, RequestStatus.rejected);
    _notify('MOU Rejected', 'MOU request was rejected.');
  }

  void _notify(String title, String body) {
    PushNotificationService.instance.showNotification(title: title, body: body);
  }
}

final mouRequestProvider = StateNotifierProvider<MouRequestNotifier,
    AsyncValue<List<MouRequestEntity>>>(
  (ref) => MouRequestNotifier(ref.watch(mouRequestRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// JOINING LETTER STATE
// ─────────────────────────────────────────────────────────────────────────────

class JoiningLetterNotifier
    extends StateNotifier<AsyncValue<List<JoiningLetterRequestEntity>>> {
  final IJoiningLetterRepository _repo;
  StreamSubscription<List<JoiningLetterRequestEntity>>? _subscription;

  JoiningLetterNotifier(this._repo) : super(const AsyncValue.loading()) {
    _listen();
  }

  void _listen() {
    _subscription = _repo.watchAll().listen(
      (list) => state = AsyncValue.data(list),
      onError: (err, st) => state = AsyncValue.error(err, st),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> add(JoiningLetterRequestEntity r) async {
    await _repo.add(r);
    _notify('Letter Request Submitted', 'New joining letter request from ${r.name}.');
  }

  Future<void> partiallyApprove(String id) async {
    await _repo.partiallyApprove(id);
    _notify('Letter Request Escalated', 'A joining letter request is waiting for Admin approval.');
  }

  Future<void> approve(
    String id, {
    required String generatedBy,
    required String tenure,
  }) async {
    await _repo.approve(
      id,
      generatedBy: generatedBy,
      tenure:      tenure,
    );
    _notify('Letter Generated', 'Your official joining letter is ready for download!');
  }

  Future<void> reject(String id) async {
    await _repo.reject(id);
    _notify('Letter Request Rejected', 'Your joining letter request was rejected.');
  }

  void _notify(String title, String body) {
    PushNotificationService.instance.showNotification(title: title, body: body);
  }
}

final joiningLetterProvider = StateNotifierProvider<JoiningLetterNotifier,
    AsyncValue<List<JoiningLetterRequestEntity>>>(
  (ref) => JoiningLetterNotifier(ref.watch(joiningLetterRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// DOCUMENT STATE
// ─────────────────────────────────────────────────────────────────────────────

/// Live stream of all documents from Firestore (metadata) + Firebase Storage (files)
final documentStorageProvider = StreamProvider<List<DocumentEntity>>((ref) {
  final repo = ref.watch(documentStorageRepoProvider);
  return repo.watchAll();
});

// ─────────────────────────────────────────────────────────────────────────────
// MEETING STATE
// ─────────────────────────────────────────────────────────────────────────────

class MeetingNotifier extends StateNotifier<AsyncValue<List<MeetingEntity>>> {
  final IMeetingRepository _repo;
  StreamSubscription<List<MeetingEntity>>? _subscription;

  MeetingNotifier(this._repo) : super(const AsyncValue.loading()) {
    _listen();
  }

  void _listen() {
    _subscription = _repo.watchAll().listen(
      (list) => state = AsyncValue.data(list),
      onError: (err, st) => state = AsyncValue.error(err, st),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> add(MeetingEntity meeting) => _repo.addMeeting(meeting);

  Future<void> addSummary(
    String meetingId, {
    required String summary,
    String? addedBy,
  }) => _repo.addSummary(
      meetingId,
      summary:  summary,
      addedBy:  addedBy ?? 'Member',
    );

  // Re-added markCompleted from merged3, but updated with String ID and removed manual state refresh
  Future<void> markCompleted(String meetingId, {required String summaryAssignedTo}) async {
    await _repo.markCompleted(meetingId, summaryAssignedTo: summaryAssignedTo);
  }
}

final meetingProvider =
    StateNotifierProvider<MeetingNotifier, AsyncValue<List<MeetingEntity>>>(
  (ref) => MeetingNotifier(ref.watch(meetingRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// DOCUMENT REQUEST STATE
// ─────────────────────────────────────────────────────────────────────────────

class DocumentRequestNotifier
    extends StateNotifier<AsyncValue<List<DocumentRequestEntity>>> {
  DocumentRequestNotifier(this._repository) : super(const AsyncValue.loading()) {
    _listenToFirebase();
  }

  final IDocumentRequestRepository _repository;
  StreamSubscription<List<DocumentRequestEntity>>? _subscription;

  void _listenToFirebase() {
    _subscription = _repository.watchAll().listen(
      (requests) {
        state = AsyncValue.data(requests);
      },
      onError: (error, stackTrace) {
        debugPrint('Firebase Stream Error (DocumentRequest): $error');
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> add(DocumentRequestEntity r) async {
    await _repository.add(r);
  }

  Future<void> approve(String id, {
    required String approvedBy,
    String? certificateNo,
    String? organisation,
    String? internshipArea,
    String? internshipDuration,
  }) async {
    final certNo = certificateNo ?? 'JF/CERT/${DateTime.now().year}/$id';
    await _repository.updateStatus(id, DocumentRequestStatus.approved,
        approvedBy: approvedBy,
        certificateNo: certNo,
        organisation: organisation,
        internshipArea: internshipArea,
        internshipDuration: internshipDuration);
  }

  Future<void> reject(String id) async {
    await _repository.updateStatus(id, DocumentRequestStatus.rejected);
  }
}

final documentRequestProvider = StateNotifierProvider<DocumentRequestNotifier,
    AsyncValue<List<DocumentRequestEntity>>>(
  (ref) => DocumentRequestNotifier(ref.watch(documentRequestRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// USER MANAGEMENT STATE
// ─────────────────────────────────────────────────────────────────────────────

class UserManagementNotifier extends StateNotifier<AsyncValue<List<UserEntity>>> {
  final UserRepository _repository;
  StreamSubscription<List<UserEntity>>? _subscription;

  UserManagementNotifier(this._repository) : super(const AsyncValue.loading()) {
    _listen();
  }

  void _listen() {
    _subscription = _repository.watchUsers().listen(
      (users) {
        state = AsyncValue.data(users);
      },
      onError: (err, st) => state = AsyncValue.error(err, st),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> addUser(UserEntity user) => _repository.addUser(user);
  Future<void> updateUser(UserEntity user) => _repository.updateUser(user);
  Future<void> removeUser(String email) => _repository.removeUser(email);
}

// ─────────────────────────────────────────────────────────────────────────────
// HOSPITAL STATE (REAL-TIME STREAM)
// ─────────────────────────────────────────────────────────────────────────────

class HospitalNotifier extends StateNotifier<AsyncValue<List<HospitalEntity>>> {
  HospitalNotifier(this._repo) : super(const AsyncValue.loading()) {
    _listen();
  }

  final IHospitalRepository _repo;
  StreamSubscription<List<HospitalEntity>>? _subscription;

  void _listen() {
    _subscription = _repo.watchAll().listen(
      (list) => state = AsyncValue.data(list),
      onError: (err, st) => state = AsyncValue.error(err, st),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> add(HospitalEntity h) => _repo.add(h);
  Future<void> delete(String id) => _repo.delete(id);
}

final hospitalProvider =
    StateNotifierProvider<HospitalNotifier, AsyncValue<List<HospitalEntity>>>(
  (ref) => HospitalNotifier(ref.watch(hospitalRepositoryProvider)),
);

final usersManagementProvider = StateNotifierProvider<UserManagementNotifier, AsyncValue<List<UserEntity>>>(
  (ref) => UserManagementNotifier(ref.watch(userRepositoryProvider)),
);