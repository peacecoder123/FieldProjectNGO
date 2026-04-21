import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/domain/entities/donation.entity.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';
import '../data/entities.dart';
import '../data/repositories.dart';
import 'package:flutter/foundation.dart';
import '../../features/documents/services/pdf_generator_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
import 'app_providers.dart';
import '../../features/auth/repositories/firebase_auth_repository.dart';
import '../../features/admin/data/user_repository.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/documents/services/pdf_generator_service.dart';

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

final volunteerProvider = StateNotifierProvider.autoDispose<
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
    StateNotifierProvider.autoDispose<MemberNotifier, AsyncValue<List<MemberEntity>>>(
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
  }

  Future<void> updateStatus(String taskId, TaskStatus status, {String? approvedBy}) async {
    await _repo.updateStatus(taskId, status, approvedBy: approvedBy);
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
    StateNotifierProvider.autoDispose<TaskNotifier, AsyncValue<List<TaskEntity>>>(
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
    StateNotifierProvider.autoDispose<DonationNotifier, AsyncValue<List<DonationEntity>>>(
  (ref) => DonationNotifier(ref.watch(donationRepositoryProvider)),
);

// ── Aggregation for Dashboard Charts ──
final monthlyDonationAggregationProvider = Provider<List<MonthlyDonationPoint>>((ref) {
  final donationsState = ref.watch(donationProvider);
  final donations = donationsState.value ?? [];
  final validDonations = donations.where((d) => d.paymentStatus != PaymentStatus.failed).toList();
  
  if (validDonations.isEmpty) {
    return [];
  }

  final grouped = <String, int>{};
  final monthFormat = DateFormat('MMM yyyy');
  
  for (final d in validDonations) {
    if (d.date.isEmpty) continue;
    try {
      DateTime? dt;
      // Try parsing ISO format first
      if (d.date.contains('-')) {
        dt = DateTime.tryParse(d.date);
      } else {
        // Fallback for "26 Mar 2026"
        final parts = d.date.split(' ');
        if (parts.length >= 3) {
          final day = int.tryParse(parts[0]);
          final month = _monthMap[parts[1].toLowerCase()];
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            dt = DateTime(year, month, day);
          }
        }
      }

      if (dt != null) {
        final key = monthFormat.format(dt);
        grouped[key] = (grouped[key] ?? 0) + d.amount;
      }
    } catch (_) {}
  }
  
  // Convert to points and sort chronologically
  final sortedKeys = grouped.keys.toList()..sort((a, b) {
    final da = monthFormat.parse(a);
    final db = monthFormat.parse(b);
    return da.compareTo(db);
  });

  return sortedKeys.map((k) => MonthlyDonationPoint(month: k.split(' ')[0], amount: grouped[k]!)).toList();
});

const _monthMap = {
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
  'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
};

// ─────────────────────────────────────────────────────────────────────────────
// GENERAL REQUEST STATE
// ─────────────────────────────────────────────────────────────────────────────

class GeneralRequestNotifier
    extends StateNotifier<AsyncValue<List<GeneralRequestEntity>>> {
  final IGeneralRequestRepository _repo;
  final String? _currentUserId;
  StreamSubscription<List<GeneralRequestEntity>>? _subscription;

  GeneralRequestNotifier(this._repo, [this._currentUserId]) : super(const AsyncValue.loading()) {
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
    final entity = (_currentUserId != null && (r.requesterId == null || r.requesterId!.isEmpty))
        ? r.copyWith(requesterId: _currentUserId)
        : r;
    await _repo.add(entity);
  }

  Future<void> partiallyApprove(String id, {String? approvedBy}) async {
    await _repo.updateStatus(id, RequestStatus.waitingAdmin, approvedBy: approvedBy);
  }

  Future<void> approve(String id, {String? approvedBy}) async {
    await _repo.updateStatus(id, RequestStatus.approved, approvedBy: approvedBy);
  }

  Future<void> reject(String id) async {
    await _repo.updateStatus(id, RequestStatus.rejected);
  }


}

final generalRequestProvider = StateNotifierProvider.autoDispose<GeneralRequestNotifier,
    AsyncValue<List<GeneralRequestEntity>>>(
  (ref) {
    final repo = ref.watch(generalRequestRepositoryProvider);
    final user = ref.watch(currentUserProvider);
    return GeneralRequestNotifier(repo, user?.id);
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// MOU REQUEST STATE
// ─────────────────────────────────────────────────────────────────────────────

class MouRequestNotifier
    extends StateNotifier<AsyncValue<List<MouRequestEntity>>> {
  final IMouRequestRepository _repo;
  final FirebaseDocumentStorageRepository _storageRepo;
  final String? _currentUserId;
  StreamSubscription<List<MouRequestEntity>>? _subscription;

  MouRequestNotifier(this._repo, this._storageRepo, [this._currentUserId]) : super(const AsyncValue.loading()) {
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
    final entity = (_currentUserId != null && (r.requesterId == null || r.requesterId!.isEmpty))
        ? r.copyWith(requesterId: _currentUserId)
        : r;
    await _repo.add(entity);
  }

  Future<void> partiallyApprove(String id, {String? approvedBy}) async {
    await _repo.updateStatus(id, RequestStatus.waitingAdmin, approvedBy: approvedBy);
  }

  Future<void> approve(String id, {String? approvedBy, String? hospitalAddress}) async {
    // 1. Get the current request data
    final requests = state.value ?? [];
    final request = requests.where((r) => r.id == id).firstOrNull;
    if (request == null) return;

    String? certificateUrl;

    try {
      // 2. Generate PDF bytes
      final pdfBytes = await PdfGeneratorService.generateMouAcceptancePdf(
        patientName: request.patientName,
        hospitalName: request.hospital,
        address: hospitalAddress ?? request.address,
        date: AppFormatters.displayDate(DateTime.now().toIso8601String()),
      );

      // 3. Upload to Firebase Storage using the repository
      final fileName = 'MOU_Acceptance_${request.patientName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      certificateUrl = await _storageRepo.uploadBytes(
        bytes: pdfBytes,
        fileName: fileName,
        contentType: 'application/pdf',
      );
    } catch (e) {
      debugPrint('Error generating/uploading MOU PDF: $e');
    }

    // 4. Update Firestore with approval and the URL
    await _repo.updateStatus(
      id, 
      RequestStatus.approved, 
      approvedBy: approvedBy,
      certificateUrl: certificateUrl,
    );
  }

  Future<void> reject(String id) async {
    await _repo.updateStatus(id, RequestStatus.rejected);
  }


}

final mouRequestProvider = StateNotifierProvider.autoDispose<MouRequestNotifier,
    AsyncValue<List<MouRequestEntity>>>(
  (ref) {
    final repo = ref.watch(mouRequestRepositoryProvider);
    final storageRepo = ref.watch(documentStorageRepoProvider);
    final user = ref.watch(currentUserProvider);
    return MouRequestNotifier(repo, storageRepo, user?.id);
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// JOINING LETTER STATE
// ─────────────────────────────────────────────────────────────────────────────

class JoiningLetterNotifier
    extends StateNotifier<AsyncValue<List<JoiningLetterRequestEntity>>> {
  final IJoiningLetterRepository _repo;
  final String? _currentUserId;
  StreamSubscription<List<JoiningLetterRequestEntity>>? _subscription;

  JoiningLetterNotifier(this._repo, [this._currentUserId]) : super(const AsyncValue.loading()) {
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
    final entity = (_currentUserId != null && (r.requesterId == null || r.requesterId!.isEmpty))
        ? r.copyWith(requesterId: _currentUserId)
        : r;
    await _repo.add(entity);
  }

  Future<void> partiallyApprove(String id) async {
    await _repo.partiallyApprove(id);
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
  }

  Future<void> reject(String id) async {
    await _repo.reject(id);
  }


}

final joiningLetterProvider = StateNotifierProvider.autoDispose<JoiningLetterNotifier,
    AsyncValue<List<JoiningLetterRequestEntity>>>(
  (ref) {
    final repo = ref.watch(joiningLetterRepositoryProvider);
    final user = ref.watch(currentUserProvider);
    return JoiningLetterNotifier(repo, user?.id);
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// DOCUMENT STATE
// ─────────────────────────────────────────────────────────────────────────────

/// Live stream of all documents from Firestore (metadata) + Firebase Storage (files)
final documentStorageProvider = StreamProvider.autoDispose<List<DocumentEntity>>((ref) {
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
    List<String>? attendees,
  }) => _repo.addSummary(
      meetingId,
      summary:  summary,
      addedBy:  addedBy ?? 'Member',
      attendees: attendees,
    );

  // Re-added markCompleted from merged3, but updated with String ID and removed manual state refresh
  Future<void> markCompleted(String meetingId, {required String summaryAssignedTo}) async {
    await _repo.markCompleted(meetingId, summaryAssignedTo: summaryAssignedTo);
  }
}

final meetingProvider =
    StateNotifierProvider.autoDispose<MeetingNotifier, AsyncValue<List<MeetingEntity>>>(
  (ref) => MeetingNotifier(ref.watch(meetingRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// DOCUMENT REQUEST STATE
// ─────────────────────────────────────────────────────────────────────────────

class DocumentRequestNotifier
    extends StateNotifier<AsyncValue<List<DocumentRequestEntity>>> {
  final IDocumentRequestRepository _repository;
  final String? _currentUserId;
  StreamSubscription<List<DocumentRequestEntity>>? _subscription;

  DocumentRequestNotifier(this._repository, [this._currentUserId]) : super(const AsyncValue.loading()) {
    _listenToFirebase();
  }

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
    final entity = (_currentUserId != null && r.userId.isEmpty)
        ? r.copyWith(userId: _currentUserId)
        : r;
    await _repository.add(entity);
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

final documentRequestProvider = StateNotifierProvider.autoDispose<DocumentRequestNotifier,
    AsyncValue<List<DocumentRequestEntity>>>(
  (ref) {
    final repo = ref.watch(documentRequestRepositoryProvider);
    final user = ref.watch(currentUserProvider);
    return DocumentRequestNotifier(repo, user?.id);
  },
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
    StateNotifierProvider.autoDispose<HospitalNotifier, AsyncValue<List<HospitalEntity>>>(
  (ref) => HospitalNotifier(ref.watch(hospitalRepositoryProvider)),
);

final usersManagementProvider = StateNotifierProvider.autoDispose<UserManagementNotifier, AsyncValue<List<UserEntity>>>(
  (ref) => UserManagementNotifier(ref.watch(userRepositoryProvider)),
);