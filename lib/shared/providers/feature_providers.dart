import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngo_volunteer_management/domain/entities/donation.entity.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';
import '../data/entities.dart';
import '../data/mock_repositories.dart';
import '../data/repositories.dart';

// Firebase repositories
import '../../features/payments/repositories/donation_repository.dart';
import '../../features/volunteers/repositories/firebase_volunteer_repository.dart';
import '../../features/members/repositories/firebase_member_repository.dart';
import '../../features/tasks/repositories/firebase_task_repository.dart';
import '../../features/requests/repositories/firebase_general_request_repository.dart';
import '../../features/requests/repositories/firebase_mou_request_repository.dart';
import '../../features/joining_letters/repositories/firebase_joining_letter_repository.dart';
import '../../features/meetings/repositories/firebase_meeting_repository.dart';
import '../../features/auth/repositories/firebase_auth_repository.dart';

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
final joiningLetterRepositoryProvider = Provider<IJoiningLetterRepository>(
  (_) => FirebaseJoiningLetterRepository(),
);
final documentRepositoryProvider = Provider<IDocumentRepository>(
  (_) => MockDocumentRepository(),
);
final meetingRepositoryProvider = Provider<IMeetingRepository>(
  (_) => FirebaseMeetingRepository(),
);

// ─────────────────────────────────────────────────────────────────────────────
// VOLUNTEER STATE
// ─────────────────────────────────────────────────────────────────────────────

class VolunteerNotifier extends StateNotifier<AsyncValue<List<VolunteerEntity>>> {
  VolunteerNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final IVolunteerRepository _repo;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getAll);
  }

  Future<void> refresh() => _load();

  Future<void> add(VolunteerEntity v) async {
    final created = await _repo.add(v);
    state = state.whenData((list) => [...list, created]);
  }

  Future<void> update(VolunteerEntity v) async {
    final updated = await _repo.update(v);
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }
}

final volunteerProvider = StateNotifierProvider<
    VolunteerNotifier, AsyncValue<List<VolunteerEntity>>>(
  (ref) => VolunteerNotifier(ref.watch(volunteerRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// MEMBER STATE
// ─────────────────────────────────────────────────────────────────────────────

class MemberNotifier extends StateNotifier<AsyncValue<List<MemberEntity>>> {
  MemberNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final IMemberRepository _repo;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getAll);
  }

  Future<void> refresh() => _load();

  Future<void> add(MemberEntity m) async {
    final created = await _repo.add(m);
    state = state.whenData((list) => [...list, created]);
  }

  Future<void> update(MemberEntity m) async {
    final updated = await _repo.update(m);
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }
}

final memberProvider =
    StateNotifierProvider<MemberNotifier, AsyncValue<List<MemberEntity>>>(
  (ref) => MemberNotifier(ref.watch(memberRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// TASK STATE
// ─────────────────────────────────────────────────────────────────────────────

class TaskNotifier extends StateNotifier<AsyncValue<List<TaskEntity>>> {
  TaskNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final ITaskRepository _repo;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getAll);
  }

  Future<void> refresh() => _load();

  Future<void> add(TaskEntity t) async {
    final created = await _repo.add(t);
    state = state.whenData((list) => [...list, created]);
  }

  Future<void> updateStatus(int taskId, TaskStatus status) async {
    final updated = await _repo.updateStatus(taskId, status);
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }

  Future<void> submit(int taskId, {String? imagePath}) async {
    final repo = _repo;
    final current = state.value?.firstWhere((t) => t.id == taskId);
    if (current == null) return;
    final updated = await repo.update(
      current.copyWith(
        status:        TaskStatus.submitted,
        submittedAt:   AppFormatters.today(),
        uploadedImage: imagePath ?? current.uploadedImage,
      ),
    );
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
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

  Future<void> generateReceipt(int id) async {
    try {
      final receiptNum = 'REC-${DateTime.now().year}-$id';
      await _repository.generateReceipt(id, receiptNum);
      // State updates automatically via the Stream
    } catch (e, st) {
      debugPrint("Firebase Update Error: $e");
      state = AsyncValue.error(e, st);
    }
  }
}

final donationProvider =
    StateNotifierProvider<DonationNotifier, AsyncValue<List<DonationEntity>>>(
  (ref) => DonationNotifier(ref.watch(donationRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// GENERAL REQUEST STATE
// ─────────────────────────────────────────────────────────────────────────────

class GeneralRequestNotifier
    extends StateNotifier<AsyncValue<List<GeneralRequestEntity>>> {
  GeneralRequestNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final IGeneralRequestRepository _repo;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getAll);
  }

  Future<void> refresh() => _load();

  Future<void> add(GeneralRequestEntity r) async {
    final created = await _repo.add(r);
    state = state.whenData((list) => [...list, created]);
  }

  Future<void> approve(int id) async {
    final updated = await _repo.updateStatus(id, RequestStatus.approved);
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }

  Future<void> reject(int id) async {
    final updated = await _repo.updateStatus(id, RequestStatus.rejected);
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
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
  MouRequestNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final IMouRequestRepository _repo;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getAll);
  }

  Future<void> refresh() => _load();

  Future<void> add(MouRequestEntity r) async {
    final created = await _repo.add(r);
    state = state.whenData((list) => [...list, created]);
  }

  Future<void> approve(int id) async {
    final updated = await _repo.updateStatus(id, RequestStatus.approved);
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }

  Future<void> reject(int id) async {
    final updated = await _repo.updateStatus(id, RequestStatus.rejected);
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
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
  JoiningLetterNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final IJoiningLetterRepository _repo;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getAll);
  }

  Future<void> refresh() => _load();

  Future<void> add(JoiningLetterRequestEntity r) async {
    final created = await _repo.add(r);
    state = state.whenData((list) => [...list, created]);
  }

  Future<void> approve(
    int id, {
    required String generatedBy,
    required String tenure,
  }) async {
    final updated = await _repo.approve(
      id,
      generatedBy: generatedBy,
      tenure:      tenure,
    );
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }

  Future<void> reject(int id) async {
    final updated = await _repo.reject(id);
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }
}

final joiningLetterProvider = StateNotifierProvider<JoiningLetterNotifier,
    AsyncValue<List<JoiningLetterRequestEntity>>>(
  (ref) => JoiningLetterNotifier(ref.watch(joiningLetterRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// DOCUMENT STATE
// ─────────────────────────────────────────────────────────────────────────────

final documentProvider =
    FutureProvider<List<DocumentEntity>>((ref) async {
  final repo = ref.watch(documentRepositoryProvider);
  return repo.getAll();
});

// ─────────────────────────────────────────────────────────────────────────────
// MEETING STATE
// ─────────────────────────────────────────────────────────────────────────────

class MeetingNotifier extends StateNotifier<AsyncValue<List<MeetingEntity>>> {
  MeetingNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final IMeetingRepository _repo;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.getAll);
  }

  Future<void> refresh() => _load();

  Future<void> addSummary(
    int meetingId, {
    required String summary,
    String? addedBy,
  }) async {
    final updated = await _repo.addSummary(
      meetingId,
      summary:  summary,
      addedBy:  addedBy ?? 'Member',
    );
    state = state.whenData(
      (list) => list.map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }
}

final meetingProvider =
    StateNotifierProvider<MeetingNotifier, AsyncValue<List<MeetingEntity>>>(
  (ref) => MeetingNotifier(ref.watch(meetingRepositoryProvider)),
);